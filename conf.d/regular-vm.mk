ifeq (vm,$(IMAGE_CLASS))

ifeq (,$(filter-out i586 x86_64,$(ARCH)))
BASE_TARGET := use/bootloader/grub use/kernel use/firmware
DESKTOP_TARGET :=
else
BASE_TARGET :=
DESKTOP_TARGET := use/x11-reduced-resources
endif

ifeq (,$(filter-out armh aarch64,$(ARCH)))
BASE_TARGET += use/bootloader/uboot use/kernel use/firmware
DESKTOP_TARGET += use/no-sleep use/x11/armsoc
endif

vm/.regular-base: $(BASE_TARGET)
ifneq (,$(filter-out i586 x86_64,$(ARCH)))
	@$(call add,DEFAULT_SERVICES_DISABLE,multipathd)
endif
	@:

vm/regular-jeos-systemd: profile/jeos-systemd \
	vm/.regular-base; @:

vm/regular-jeos-sysv: profile/jeos-sysv vm/.regular-base; @:

vm/.regular-desktop: vm/.regular-base use/browser/firefox/esr \
	use/oem $(DESKTOP_TARGET)
ifeq (,$(filter-out armh aarch64,$(ARCH)))
	@$(call add,THE_LISTS,remote-access)
	@$(call add,THE_PACKAGES,blueberry mpv)
endif
	@:

vm/regular-lxde: profile/regular-lxde vm/.regular-desktop; @:
vm/regular-lxde-sysv: profile/regular-lxde-sysv vm/.regular-desktop; @:
vm/regular-lxqt: profile/regular-lxqt vm/.regular-desktop; @:
vm/regular-mate: profile/regular-mate vm/.regular-desktop; @:
vm/regular-xfce: profile/regular-xfce vm/.regular-desktop; @:
vm/regular-icewm: profile/regular-icewm vm/.regular-desktop; @:

endif
