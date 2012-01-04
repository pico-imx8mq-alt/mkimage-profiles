# step 4 is kicked off here but actually done by image.in/Makefile
ANSI_OK   ?= 1;32
ANSI_FAIL ?= 1;31

ifndef MKIMAGE_PROFILES
$(error this makefile is designed to be included in toplevel one)
endif

# try not to bog down the system, both CPU and I/O wise
ifdef NICE
START := nice $(shell ionice -c3 echo "ionice -c3" 2>/dev/null)
endif

# in kilobytes (a kilometer is 1024 meters, you know)
LOWSPACE = 1024

# it's also nice to know how long and much it takes
START += time -f "%E %PCPU %Mk"

# /usr/bin/{i586,x86_64} are setarch(8) symlinks
START += $(ARCH)

# to be passed into distcfg.mk; suggestions are welcome
IMAGEDIR ?= $(shell \
	if [ -d "$$HOME/out" -a -w "$$HOME/out" ]; then \
		echo "$$HOME/out"; \
	else \
		dir="`dirname $(BUILDDIR)`/out"; \
		mkdir -p "$$dir" && echo "$$dir" || echo "/tmp"; \
	fi; \
)

# actual build starter
build-image: profile/populate
	@if [ -n "$(CHECK)" ]; then \
		echo "$(TIME) skipping actual image build (CHECK is set)"; \
		exit; \
	fi; \
	echo -n "$(TIME) starting image build"; \
	if [ -n "$(DEBUG)" ]; then \
		echo ": tail -f $(BUILDLOG)" $(SHORTEN); \
	else \
		echo " (coffee time)"; \
	fi; \
	if $(START) $(MAKE) -C $(BUILDDIR)/ $(LOG); then \
		echo "$(TIME) done (`tail -1 $(BUILDLOG) | cut -f1 -d.`)"; \
		tail -200 "$(BUILDLOG)" $(SHORTEN) \
		| GREP_COLOR="$(ANSI_OK)" GREP_OPTIONS="--color=auto" \
		  grep '^\*\* image: .*' ||:; \
	else \
		echo -n "$(TIME) failed, see log"; \
		if [ -z "$(DEBUG)" ]; then \
			echo ": $(BUILDLOG)" $(SHORTEN); \
			echo "$(TIME) (you might want to rerun with DEBUG=1)"; \
		else \
			echo " above"; \
		fi; \
		tail -200 "$(BUILDLOG)" \
		| GREP_COLOR="$(ANSI_FAIL)" GREP_OPTIONS="--color=auto" \
		  egrep "^((E:|[Ee]rror|[Ww]arning).*)|(.* Stop\.)$$"; \
		df -P $(BUILDDIR) | awk 'END { if ($$4 < $(LOWSPACE)) \
			{ print "NB: low space on "$$6" ("$$5" used)"}}'; \
	fi; \
	if [ -n "$(BELL)" ]; then echo -ne '\a' >&2; fi
