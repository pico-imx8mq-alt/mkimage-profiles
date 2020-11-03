postprocess-picoimx8mq:
	@dd if=$(WORKDIR)/chroot/.work/chroot/usr/share/pico-imx8mq-bootimage/flash.bin of="$(IMAGEDIR)/$(IMAGE_OUTFILE)" bs=1K seek=33 conv=notrunc
