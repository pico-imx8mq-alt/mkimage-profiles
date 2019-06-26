# step 4: build the virtual machine image

IMAGE_PACKAGES = $(DOT_BASE) \
		 $(SYSTEM_PACKAGES) \
		 $(COMMON_PACKAGES) \
		 $(BASE_PACKAGES) \
		 $(THE_PACKAGES) \
		 $(call list,$(BASE_LISTS) $(THE_LISTS))

IMAGE_PACKAGES_REGEXP = $(THE_PACKAGES_REGEXP) \
                        $(BASE_PACKAGES_REGEXP)

# intermediate chroot archive
VM_TARBALL := $(IMAGE_OUTDIR)/$(IMAGE_NAME).tar
VM_RAWDISK := $(IMAGE_OUTDIR)/$(IMAGE_NAME).raw
VM_FSTYPE ?= ext4
VM_SIZE ?= 0

VM_GZIP_COMMAND ?= gzip
VM_XZ_COMMAND ?= xz -T0

check-sudo:
	@if ! type -t sudo >&/dev/null; then \
		echo "** error: sudo not available, see doc/vm.txt" >&2; \
	fi

check-qemu:
	@if ! type -t qemu-img >&/dev/null; then \
		echo "** error: qemu-img not available" >&2; \
		exit 1; \
	fi

tar2fs: check-sudo
	@if [ -x /usr/share/mkimage-profiles/bin/tar2fs ]; then \
		TOPDIR=/usr/share/mkimage-profiles; \
	fi; \
	if ! sudo $$TOPDIR/bin/tar2fs \
		"$(VM_TARBALL)" "$(VM_RAWDISK)" $(VM_SIZE) $(VM_FSTYPE); then \
		echo "** error: sudo tar2fs failed, see build log" >&2; \
		exit 1; \
	fi

prepare-image:
	@# need to copy $(BUILDDIR)/.work/chroot/.host/qemu* into chroot
	@#if qemu is used
	@(cd "$(BUILDDIR)/.work/chroot/"; \
		tar -rf "$(VM_TARBALL)" ./.host/qemu*) ||:

convert-image/tar:
	mv "$(VM_TARBALL)" "$(IMAGE_OUTPATH)"

convert-image/tar.gz:
	$(VM_GZIP_COMMAND) < "$(VM_TARBALL)" > "$(IMAGE_OUTPATH)"

convert-image/tar.xz:
	$(VM_XZ_COMMAND) < "$(VM_TARBALL)" > "$(IMAGE_OUTPATH)"

convert-image/img: tar2fs
	mv "$(VM_RAWDISK)" "$(IMAGE_OUTPATH)"

convert-image/qcow2 convert-image/qcow2c convert-image/vmdk \
	convert-image/vdi convert-image/vhd: check-qemu tar2fs
	@VM_COMPRESS=; \
	case "$(IMAGE_TYPE)" in \
	"vhd") VM_FORMAT="vpc";; \
	"qcow2c") VM_FORMAT="qcow2"; VM_COMPRESS="-c";; \
	*) VM_FORMAT="$(IMAGE_TYPE)"; \
	esac; \
	qemu-img convert $$VM_COMPRESS -O "$$VM_FORMAT" \
		"$(VM_RAWDISK)" "$(IMAGE_OUTPATH)"

post-convert:
	@rm -f "$(VM_RAWDISK)"; \
	if [ "0$(DEBUG)" -le 1 ]; then rm -f "$(VM_TARBALL)"; fi

convert-image: prepare-image convert-image/$(IMAGE_TYPE) post-convert; @:

run-image-scripts: GLOBAL_CLEANUP_PACKAGES := $(CLEANUP_PACKAGES)

# override
pack-image: MKI_PACK_RESULTS := tar:$(VM_TARBALL)

all: $(GLOBAL_DEBUG) \
	build-image copy-subdirs copy-tree run-image-scripts pack-image \
	convert-image postprocess $(GLOBAL_CLEAN_WORKDIR)
