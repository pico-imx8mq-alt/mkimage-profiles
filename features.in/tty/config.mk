use/tty:
	@$(call add_feature)
	@$(call xport,TTY_DEV)
	@$(call xport,TTY_RATE)
ifeq (distro,$(IMAGE_CLASS))
	@$(call add,INSTALL2_PACKAGES,installer-feature-serial-stage2)
	@$(call add,BASE_PACKAGES,installer-feature-serial-stage3)
endif

use/tty/S0 use/tty/SI0 use/tty/AMA0: use/tty/%: use/tty
	@$(call add,THE_PACKAGES,agetty)
	@$(call add,TTY_DEV,tty$*)
	@$(call set,TTY_RATE,115200)
	@$(call add,SYSLINUX_CFG,tty$*)
