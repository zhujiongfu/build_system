#
# Author: zhujiongfu<zhujiongfu@live.cn>
# Date: Sat Dec 22 10:47:01 CST 2018
#

MODULE := $(call UPPERCASE,$(module))

ifneq ($(filter $(module),$(MODULES_ALL)),)
  $(error Package '$(module)' defined a second time in '$(LOCAL_PATH)';\
	  Previous definition was in '$(_$(module)_path)')
endif

_$(module)_path := $(LOCAL_PATH)
MODULES_ALL += $(module)

ifeq ($(CONFIG_$(MODULE)),y)

ifneq ($(KBUILD_SRC),)
_dummy := $(shell [ -d $(LOCAL_PATH) ] || mkdir -p $(LOCAL_PATH))
endif

_cobjs := $(addprefix $(LOCAL_PATH)/,$(module_cobjs))
_cobjs := $(filter-out %/,$(_cobjs))

_cxxobjs := $(addprefix $(LOCAL_PATH)/, $(module_cxxobjs))
_cxxobjs := $(filter-out %/,$(_cxxobjs))

_subdirs := $(addprefix $(LOCAL_PATH)/,$(module_subdirs))
_subdirs := $(addsuffix built-in.o,$(_subdirs))

_target := $(LOCAL_PATH)/$(module).so

module_cflags += $(addprefix -I$(srctree)/$(LOCAL_PATH)/,$(module_c_includes))
module_cflags += -fPIC
$(_cobjs): _cflags:=$(module_cflags)
$(_cobjs): $(LOCAL_PATH)/%.o: $(LOCAL_PATH)/%.c FORCE
	$(call if_changed_dep,cobjs)

_targets += $(_cobjs)

module_cxxflags += $(addprefix -I$(srctree)/$(LOCAL_PATH)/,$(module_cxx_includes))
module_cxxflags += -fPIC
$(_cxxobjs): _cxxflags:=$(module_cxxflags)
$(_cxxobjs): $(LOCAL_PATH)/%.o: $(LOCAL_PATH)/%.cpp FORCE
	$(call if_changed_dep,cxxobjs)

_targets += $(_cxxobjs)

module_link_path := $(addprefix -L$(srctree)/$(LOCAL_PATH)/,$(module_link_path))
module_link_path += $(addprefix -l,$(patsubst lib%,%,$(module_link_libs)))
$(_target): _linkflags:=$(module_link_path)
$(_target): $(_cobjs) $(_cxxobjs) $(_subdirs) FORCE
	$(call if_changed,shared)

_targets += $(_target)
TARGETS_ALL += $(_target)

$(LOCAL_PATH)/.stamp_$(module)-installed: _install_path:=$(OUT_LIB)
$(LOCAL_PATH)/.stamp_$(module)-installed: $(_target) FORCE
	$(call if_changed,install)
	$(Q)touch $@

_targets += $(LOCAL_PATH)/.stamp_$(module)-installed

$(_target)-install: $(LOCAL_PATH)/.stamp_$(module)-installed
	@:

PHONY += $(_target)-install

cmd_files := $(wildcard $(foreach f,$(_targets),\
		$(dir $(f)).$(notdir $(f)).cmd))
include $(cmd_files)

_cleanobjs := $(cmd_files) $(_targets)
$(_target)-clean: cleanobjs:=$(_cleanobjs)
$(_target)-clean: FORCE
	-$(Q)$(RM) -rf $(cleanobjs)

endif
