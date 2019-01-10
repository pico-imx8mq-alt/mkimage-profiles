
profile/base: profile/bare use/repo \
	use/net-eth use/net-ssh use/net/dhcp; @:
	@$(call add,BASE_PACKAGES,apt)
	@$(call add,BASE_PACKAGES,make-initrd)
	@$(call add,THE_PACKAGES,interactivesystem e2fsprogs)

profile/jeos-base: profile/base use/deflogin/root use/ntp/chrony
	@$(call add,THE_PACKAGES,vim-console)
	@$(call add,THE_LISTS,$(call tags,base regular))
	@$(call set,ROOTPW,alt)

profile/jeos-sysv: profile/jeos-base +sysvinit +power \
	use/net-eth/dhcp; @:

profile/jeos-systemd: profile/jeos-base +systemd \
	use/net-eth/networkd-dhcp; @

profile/regular-desktop: profile/base mixin/regular-x11 \
	mixin/regular-desktop
	@$(call add,THE_PACKAGES,mpv)

profile/regular-desktop-sysv: profile/regular-desktop \
	+elogind +power; @:

profile/regular-gtk: profile/regular-desktop use/x11/lightdm/gtk \
	+systemd; @:

profile/regular-qt: profile/regular-desktop use/x11/sddm +systemd; @:

profile/regular-gtk-sysv: profile/regular-desktop-sysv \
	use/x11/gdm2.20; @:

profile/regular-qt-sysv: profile/regular-desktop-sysv use/x11/sddm; @:

profile/regular-icewm: profile/regular-gtk-sysv mixin/regular-icewm; @:

profile/regular-lxde: profile/regular-gtk mixin/regular-lxde; @:

profile/regular-lxde-sysv: profile/regular-sysv mixin/regular-lxde; @:

profile/regular-lxqt: profile/regular-gtk mixin/regular-lxqt; @:

profile/regular-mate: profile/regular-gtk mixin/regular-mate \
	use/domain-client; @:

profile/regular-xfce: profile/regular-gtk mixin/regular-xfce \
	use/x11/xfce/full use/domain-client; @:
