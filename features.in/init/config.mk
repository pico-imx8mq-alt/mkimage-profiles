+sysvinit: use/init/sysv; @:
+systemd: use/init/systemd/full; @:
+elogind: use/init/sysv/elogind; @:

# NB: the list name MUST be identical to init package name
use/init: use/pkgpriorities
	@$(call add_feature)
	@$(call add,THE_LISTS,$$(INIT_TYPE))
	@$(call add,PINNED_PACKAGES,$$(INIT_TYPE))

# THE_LISTS is too late when BASE_PACKAGES have pulled in
# the wrong syslogd-daemon provider already
use/init/sysv: use/init
	@$(call set,INIT_TYPE,sysvinit)
	@$(call add,BASE_PACKAGES,rsyslog-classic)

use/init/sysv/polkit: use/init/sysv
	@$(call add,THE_PACKAGES,polkit-sysvinit)

use/init/sysv/consolekit: use/init/sysv
	@$(call add,THE_PACKAGES,ConsoleKit2-service ConsoleKit2-x11)

use/init/sysv/elogind: use/init/sysv
	@$(call add,THE_PACKAGES,elogind bash-completion-elogind)
	@$(call add,DEFAULT_SERVICES_ENABLE,elogind)

### i-f should be dropped as soon as rootfs scripts are effective there
use/init/systemd: use/init
	@$(call set,INIT_TYPE,systemd)
	@$(call add,INSTALL2_PACKAGES,installer-feature-journald-tty)
ifneq (,$(filter-out e2k%,$(ARCH)))
	@$(call add,DEFAULT_SERVICES_DISABLE,acpid)
endif

use/init/systemd/full: use/init/systemd
	@$(call add,THE_PACKAGES,bash-completion-systemd chkconfig)
ifeq (,$(filter-out i586 x86_64,$(ARCH)))
	@$(call add,THE_PACKAGES,vconsole-setup-kludge)
endif

# http://www.freedesktop.org/wiki/Software/systemd/Debugging
use/init/systemd/debug: use/init/systemd use/services
	@$(call add,THE_PACKAGES,systemd-shutdown-debug-script)
	@$(call add,SERVICES_ENABLE,debug-shell)
	@$(call add,STAGE2_BOOTARGS,systemd.log_level=debug)
	@$(call add,STAGE2_BOOTARGS,systemd.log_target=kmsg)
	@$(call add,STAGE2_BOOTARGS,log_buf_len=1M enforcing=0)

# set multi-user target by default
use/init/systemd/multiuser: use/init/systemd
	@$(call add,STAGE2_BOOTARGS,systemd.unit=multi-user.target)
