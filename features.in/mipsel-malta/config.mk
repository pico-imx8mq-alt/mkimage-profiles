use/mipsel-malta: use/kernel
	@$(call add_feature)
	@$(call set,KFLAVOURS,un-malta)
	@$(call set,VM_FSTYPE,ext4)
	@$(call add,NET_ETH,eth0:dhcp)
