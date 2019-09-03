ifeq (distro,$(IMAGE_CLASS))

ifeq (,$(filter-out i586 x86_64,$(ARCH)))
distro/alt-server: server_groups_x86 = $(addprefix centaurus/,\
        emulators freenx-server \
	ipmi netinst sogo 80-desktop mate office pidgin vlc xorg)

ifeq (,$(filter-out x86_64,$(ARCH)))
distro/alt-server: server_groups_x86_64 = $(addprefix centaurus/,\
       ganeti freeipa-server v12n-server)
distro/alt-server: use/efi/refind use/memtest +efi
endif
endif

# FIXME: generalize vm-profile
distro/alt-server: distro/.base mixin/alt-server +vmguest \
	use/bootloader/grub use/rescue/base \
	use/docs/license
	@$(call add,MAIN_GROUPS,$(server_groups_x86))
	@$(call add,MAIN_GROUPS,$(server_groups_x86_64))
	@$(call add,MAIN_LISTS,centaurus/disk-dvd)
	@$(call add,MAIN_LISTS,centaurus/disk-server-light)
	@$(call add,INSTALL2_PACKAGES,installer-feature-desktop-suspend-stage2)
	@$(call add,INSTALL2_PACKAGES,strace)
	@$(call add,BASE_KMODULES,kvm virtualbox)
	@$(call add,CLEANUP_BASE_PACKAGES,acpid-events-power)
	@$(call add,RESCUE_BOOTARGS,nomodeset vga=0)
	@$(call add,EFI_BOOTARGS,lang=ru_RU)
distro/alt-server: monitoring = $(addprefix server-v/, 90-monitoring \
	zabbix-agent telegraf prometheus-node_exporter monit collectd nagios-nrpe)

ifeq (,$(filter-out e2k%,$(ARCH)))

distro/alt-server: distro/.e2k-installer mixin/alt-server
ifeq (,$(filter-out e2k,$(ARCH)))
	@$(call set,META_APP_ID,ALT Server for Elbrus-4.4)
endif
ifeq (,$(filter-out e2kv4,$(ARCH)))
	@$(call set,META_APP_ID,ALT Server for Elbrus-80x)
endif

endif

endif
