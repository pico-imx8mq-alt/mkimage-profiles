# regular build/usage images
ifeq (distro,$(IMAGE_CLASS))

# common ground
distro/.regular-bare: distro/.base +wireless use/efi/signed \
	use/memtest use/stage2/net-eth use/kernel/net
	@$(call try,SAVE_PROFILE,yes)

# graphical target (not enforcing xorg drivers or blobs)
distro/.regular-x11: distro/.regular-bare use/x11/wacom +vmguest \
	use/live/x11 use/live/install use/live/repo use/live/rw \
	use/luks use/branding use/browser/firefox/live use/browser/firefox/i18n
	@$(call add,LIVE_LISTS,$(call tags,(base || desktop) && regular))
	@$(call add,LIVE_LISTS,$(call tags,base rescue))
	@$(call add,LIVE_PACKAGES,gpm livecd-install-apt-cache)
	@$(call add,DEFAULT_SERVICES_ENABLE,gpm)

# common WM live/installer bits
mixin/regular-desktop: use/x11/xorg use/sound use/xdg-user-dirs
	@$(call add,THE_PACKAGES,installer-feature-desktop-other-fs-stage2)
	@$(call add,THE_PACKAGES,alterator-notes)
	@$(call add,THE_BRANDING,alterator graphics indexhtml notes)

# WM base target
distro/.regular-base: distro/.regular-x11 mixin/regular-desktop

# DE base target
# TODO: use/plymouth/live when luks+plymouth is done, see also #28255
distro/.regular-desktop: distro/.regular-base \
	use/syslinux/ui/gfxboot use/firmware/laptop use/efi/refind +systemd
	@$(call add,LIVE_LISTS,domain-client)
	@$(call add,THE_BRANDING,bootloader)
	@$(call set,KFLAVOURS,std-def)

distro/.regular-gtk: distro/.regular-desktop use/x11/lightdm/gtk +plymouth; @:
distro/.regular-sysv: distro/.regular-base +sysvinit; @:
distro/.regular-sysv-gtk: distro/.regular-sysv use/syslinux/ui/gfxboot \
	use/x11/gdm2.20; @:

distro/.regular-install: distro/.regular-bare +installer +sysvinit +power \
	use/branding use/bootloader/grub use/luks \
	use/install2/fs use/install2/vnc
	@$(call add,THE_LISTS,$(call tags,base regular))
	@$(call add,INSTALL2_BRANDING,alterator notes)
	@$(call add,THE_BRANDING,alterator)

# NB:
# - no +power or even use/power/acpi/button on intent
# - stock cleanup is not enough (or installer-common-stage3 deps soaring)
distro/regular-jeos: distro/.base +sysvinit \
	use/install2/packages use/install2/vmguest use/vmguest/base \
	use/branding use/bootloader/lilo use/syslinux/lateboot.cfg \
	use/install2/cleanup/everything use/install2/cleanup/kernel/everything \
	use/cleanup/x11-alterator use/net use/kernel/net use/stage2/net-eth \
	use/power/acpi/button
	@$(call set,KFLAVOURS,led-ws)	# led-vs might be nice here
	@$(call add,BASE_KMODULES,guest scsi vboxguest)
	@$(call set,INSTALLER,altlinux-generic)
	@$(call add,INSTALL2_BRANDING,alterator notes)
	@$(call add,THE_BRANDING,alterator) # just to be cleaned up later on
	@$(call add,THE_PACKAGES,apt basesystem dhcpcd openssh vim-console)
	@# a *lot* of stray things get pulled in by alterator modules
	@$(call add,CLEANUP_PACKAGES,libICE 'libX*' libxcb libfreetype)
	@$(call add,CLEANUP_PACKAGES,fontconfig 'glib2*' libffi 'libltdl*')
	@$(call add,CLEANUP_PACKAGES,liblcms libjpeg 'libpng*' 'libtiff*')
	@$(call add,CLEANUP_PACKAGES,avahi-autoipd bridge-utils) # i-c-stage3
	@$(call add,CLEANUP_PACKAGES,iw wpa_supplicant)
	@$(call add,CLEANUP_PACKAGES,openssl libpcsclite)
	@# fully fledged interactivesystem isn't needed here either
	@$(call add,CLEANUP_PACKAGES,interactivesystem 'groff*' man stmpclean)
	@$(call add,CLEANUP_PACKAGES,glibc-gconv-modules gettext)
	@$(call add,CLEANUP_PACKAGES,console-scripts console-vt-tools 'kbd*')
	@$(call add,CLEANUP_PACKAGES,libsystemd-journal libsystemd-login)
	@$(call add,CLEANUP_PACKAGES,dbus libdbus libcap-ng)

distro/.regular-install-x11: distro/.regular-install \
	mixin/regular-desktop +vmguest
	@$(call set,INSTALLER,altlinux-desktop)
	@$(call add,THE_LISTS,$(call tags,regular desktop))

distro/regular-icewm: distro/.regular-sysv-gtk use/browser/seamonkey/i18n +icewm
	@$(call add,LIVE_LISTS,$(call tags,regular icewm))
	@$(call add,LIVE_PACKAGES,gparted)
	@$(call set,KFLAVOURS,un-def)

mixin/regular-wmaker: use/efi/refind use/syslinux/ui/gfxboot use/x11/wmaker
	@$(call add,LIVE_PACKAGES,livecd-install-wmaker)
	@$(call add,LIVE_PACKAGES,installer-feature-no-xconsole-stage3)
	@$(call add,MAIN_PACKAGES,wmgtemp wmhdaps wmpomme wmxkbru xxkb)

# wdm can't do autologin so add standalone one for livecd
distro/regular-wmaker: distro/.regular-sysv \
	mixin/regular-wmaker use/live/autologin use/browser/seamonkey/i18n
	@$(call add,LIVE_PACKAGES,wdm)
	@$(call set,KFLAVOURS,led-ws)

# gdm2.20 can reboot/halt with both sysvinit and systemd, and is slim
mixin/regular-gnustep: use/x11/gnustep use/x11/gdm2.20 use/mediacheck \
	use/browser/firefox/classic +plymouth
	@$(call add,THE_BRANDING,graphics)

distro/regular-gnustep: distro/.regular-sysv \
	mixin/regular-wmaker mixin/regular-gnustep; @:
distro/regular-gnustep-systemd: distro/.regular-base +systemd \
	mixin/regular-wmaker mixin/regular-gnustep; @:

distro/regular-xfce: distro/.regular-gtk \
	use/x11/xfce use/domain-client/full use/browser/firefox/classic +nm; @:

distro/regular-lxde: distro/.regular-gtk use/x11/lxde use/fonts/infinality +nm
	@$(call add,LIVE_LISTS,$(call tags,desktop gvfs))

distro/regular-xmonad: distro/.regular-gtk use/x11/xmonad
	@$(call add,LIVE_PACKAGES,livecd-regular-xmonad)

distro/regular-mate: distro/.regular-gtk use/x11/mate use/domain-client/full +nm
	@$(call add,LIVE_LISTS,$(call tags,mobile mate))

distro/regular-e17: distro/.regular-gtk use/x11/e17 use/fonts/infinality; @:
distro/regular-e18: distro/.regular-gtk use/x11/e18 use/fonts/infinality; @:
distro/regular-e18-sysv: distro/.regular-sysv-gtk use/x11/e18; @:

distro/regular-cinnamon: distro/.regular-gtk \
	use/x11/cinnamon use/fonts/infinality +nm
	@$(call set,META_VOL_ID,ALT Linux $(IMAGE_NAME)) # see also #28271
	@$(call set,KFLAVOURS,un-def)

# not .regular-gtk due to gdm vs lightdm
distro/regular-gnome3: distro/.regular-desktop \
	use/x11/gnome3 use/browser/epiphany +plymouth +nm; @:

# reusable bits
mixin/regular-tde: use/syslinux/ui/gfxboot use/browser/firefox/classic \
	+tde +plymouth
	@$(call add,THE_PACKAGES,kdeedu)
	@$(call add,THE_LISTS,openscada)

distro/regular-tde: distro/.regular-desktop mixin/regular-tde +nm; @:

distro/regular-tde-sysv: distro/.regular-sysv mixin/regular-tde \
	use/net-eth/dhcp use/efi/refind; @:

distro/regular-kde4: distro/.regular-desktop use/x11/kde4 use/x11/kdm4 \
	use/browser/konqueror4 use/fonts/zerg use/domain-client/full \
	+pulse +plymouth +nm
	@$(call add,LIVE_LISTS,$(call tags,(regular || network) && kde4))
	@$(call add,LIVE_PACKAGES,rosa-imagewriter)

distro/regular-razorqt: distro/.regular-desktop +razorqt +plymouth; @:

distro/regular-lxqt: distro/.regular-desktop \
	use/x11/lxqt use/x11/lightdm/lxqt use/browser/qupzilla +plymouth; @:

distro/regular-sugar: distro/.regular-gtk use/x11/sugar; @:

# NB: never ever use/syslinux/ui/gfxboot here as gfxboot mangles
#     kernel cmdline resulting in method:disk instead of method:cdrom
#     which will change propagator's behaviour to probe additional
#     filesystems (ro but no loop) thus potentially writing to
#     an unrecovered filesystem's journal
distro/regular-rescue: distro/.regular-bare use/rescue/rw use/luks \
	use/branding use/efi/refind use/efi/shell use/efi/memtest86 \
	use/hdt use/syslinux/ui/menu use/syslinux/rescue_fm.cfg \
	use/syslinux/timeout/200 use/mediacheck test/rescue/no-x11
	@$(call set,KFLAVOURS,un-def)
	@$(call add,RESCUE_PACKAGES,gpm)

distro/regular-sysv-tde: distro/.regular-install-x11 \
	mixin/desktop-installer mixin/regular-tde \
	use/branding/complete use/branding/slideshow/once \
	use/net-eth/dhcp use/efi/refind use/efi/shell use/rescue/base
	@$(call set,KFLAVOURS,led-ws)
	@$(call add,RESCUE_LISTS,$(call tags,rescue misc))
	@$(call add,THE_LISTS,$(call tags,base desktop))
	@$(call add,THE_LISTS,$(call tags,regular tde))
	@$(call add,MAIN_PACKAGES,man-whatis usb-modeswitch)

distro/regular-server: distro/.regular-install use/server/mini use/rescue/base
	@$(call add,THE_LISTS,$(call tags,regular server))
	@$(call add,MAIN_PACKAGES,aptitude)
	@$(call set,INSTALLER,altlinux-server)

distro/regular-server-ovz: distro/regular-server \
	use/server/ovz use/server/groups/base; @:

distro/regular-server-hyperv: distro/regular-server
	@$(call set,KFLAVOURS,un-def)
	@$(call add,THE_PACKAGES,hyperv-daemons)

endif
