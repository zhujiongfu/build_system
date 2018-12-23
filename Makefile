#
# based on linux Makefile
# Author: zhujiongfu<zhujiongfu@live.cn>
# Date: Sat Dec 22 09:42:55 CST 2018
#

VERSION = 1
PATCHLEVEL = 0

MAKEFLAGS += --include-dir=$(CURDIR)

CONFIG_SHELL := $(shell if [ -x "$$BASH" ]; then echo $$BASH; \
	  else if [ -x /bin/bash ]; then echo /bin/bash; \
	  else echo sh; fi ; fi)

ifeq ("$(origin V)", "command line")
  BUILD_VERBOSE = $(V) 
endif

ifndef BUILD_VERBOSE
  BUILD_VERBOSE = 0
endif
  
ifeq ($(strip $(BUILD_VERBOSE)),1)
  quiet =
  Q =
else
  quiet=quiet_
  Q = @
endif

# KBUILD_SRC is set in the invocation of make
# if KBUILD_SRC is not null, that is mean now it is
# involed by another Makefile
ifeq ($(KBUILD_SRC),)
ifeq ("$(origin O)", "command line")
  KBUILD_OUTPUT = $(O)
endif

PHONY := _all
_all:

$(CURDIR)/Makefile Makefile: ;

ifneq ($(words $(subst :, ,$(CURDIR))), 1)
  $(error main directory cannot contain spaces nor colons)
endif

endif

ifneq ($(KBUILD_OUTPUT),)
saved-output := $(KBUILD_OUTPUT)
KBUILD_OUTPUT := $(shell mkdir -p $(KBUILD_OUTPUT) && cd $(KBUILD_OUTPUT) \
							&& /bin/pwd)
$(if $(KBUILD_OUTPUT),, \
	$(error failed to create output directory "$(saved-output)"))

$(filter-out _all sub-make $(CURDIR)/Makefile, $(MAKECMDGOALS)) _all: sub-make
	@:

sub-make:
	$(Q)$(MAKE) -C $(KBUILD_OUTPUT) KBUILD_SRC=$(CURDIR) \
	-f $(CURDIR)/Makefile $(filter-out sub-make _all,$(MAKECMDGOALS))

skip-makefile := 1
endif

ifeq ($(KBUILD_SRC),)
        srctree = .
else
        ifeq ($(KBUILD_SRC)/,$(dir $(CURDIR)))
                srctree := ..
        else
                srctree := $(KBUILD_SRC)
        endif
endif

objtree := .
VPATH   := $(srctree)


export srctree objtree VPATH

OUT_BIN := $(objtree)/out/usr/bin
OUT_LIB := $(objtree)/out/usr/lib

$(shell [ -d $(LOCAL_PATH) ] || mkdir -p $(OUT_BIN))
$(shell [ -d $(LOCAL_PATH) ] || mkdir -p $(OUT_LIB))

ifeq ($(skip-makefile),)

# do not print "Entering directory ..."
MAKEFLAGS += --no-print-directory

KCONFIG_CONFIG	:= $(CURDIR)/.config
export KCONFIG_CONFIG

RM = rm
CC = gcc
CXX = g++
STRIP = strip
INSTALL = install

HOSTCC = gcc
HOSTCXX = g++
HOSTCFLAGS   := -Wall -Wmissing-prototypes -Wstrict-prototypes -O2 -fomit-frame-pointer -std=gnu89
HOSTCXXFLAGS = -O2

export srctree quiet CC CXX HOSTCC HOSTCXX HOSTCFLAGS HOSTCXXFLAGS

TARGETS_ALL :=
MODULES_ALL :=

LINUXINCLUDE    := -include include/generated/autoconf.h \
		   -I$(srctree)/include -Iinclude

c_flags := $(LINUXINCLUDE)
cxx_flags := $(LINUXINCLUDE)

all:

include scripts/Kbuild.include
include scripts/pkg-util.mk

# include $(sort $(wildcard */Makefile))

config-targets 	:= 0
dot-config 	:= 1

no-dot-config-targets := clean mrproper distclean \
			cscope gtags TAGS tags help% %docs check% coccicheck \
			headers_% archheaders archscripts %src-pkg

ifneq ($(filter no-dot-congit-targets,$(MAKECMDGOALS)),)
	ifeq ($(filter-out $(no-dot-config-targets), $(MAKECMDGOALS)),)
		dot-config := 0
	endif
endif

ifneq ($(filter config %config,$(MAKECMDGOALS)),)
	config-targets := 1
endif

ifeq ($(config-targets),1)
config: scripts_basic FORCE
	$(Q)$(MAKE) $(build)=scripts/kconfig $@
%config: scripts_basic FORCE
	$(Q)$(MAKE) $(build)=scripts/kconfig $@

else

PHONY += scripts
scripts: scripts_basic include/config/auto.conf include/config/tristate.conf
	$(Q)$(MAKE) $(build)=$(@)

ifeq ($(dot-config),1)

-include include/config/auto.conf
-include include/config/auto.conf.cmd

$(KCONFIG_CONFIG) include/config/auto.conf.cmd: ;

include/config/%.conf: $(KCONFIG_CONFIG) include/config/auto.conf.cmd
	$(Q)$(MAKE) -f $(srctree)/Makefile silentoldconfig

endif

endif # config-targets

scripts_basic: outputmakefile
	$(Q)$(MAKE) $(build)=scripts/basic

scripts/basic/%: scripts_basic

PHONY += outputmakefile

outputmakefile:
ifneq ($(KBUILD_SRC),)
	$(Q)ln -fsn $(srctree) source
	$(Q)$(CONFIG_SHELL) $(srctree)/scripts/mkmakefile \
	    $(srctree) $(objtree) $(VERSION) $(PATCHLEVEL)
endif

LOCAL_PATH := $(objtree)
include $(clear-vars)
module := top_test
module_subdirs := test/
module_link_libs := pthread ncurses
include $(build-execute)

include test/Makefile

_all: all
PHONY += all
all: include/config/auto.conf scripts_basic $(TARGETS_ALL)
	echo $(TARGETS_ALL)

install_objs := $(addsuffix -install,$(filter-out %/built-in.o,$(TARGETS_ALL)))
PHONY += install
install: $(install_objs)

clean_objs := $(addsuffix -clean,$(TARGETS_ALL))
PHONY += clean
clean: $(clean_objs)

endif 	# skip-makefile

PHONY += FORCE
FORCE:

.PHONY: $(PHONY)

