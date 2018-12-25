use/mipsel-mitx: use/kernel
	@$(call add_feature)
	@$(call set,KFLAVOURS,mitx-def)
	@$(call add,THE_PACKAGES,xorg-drv-btsm750)
#	@$(call set,KFLAVOURS,mitx-un)
