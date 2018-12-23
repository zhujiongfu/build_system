#
# Author: zhujiongfu(zhujiongfu@live.cn)
# Date: Sat Dec 22 09:42:34 CST 2018
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

_cxxobjs := $(addprefix $(LOCAL_PATH)/, $(module_cxxbojs))
_cxxobjs := $(filter-out %/,$(_cxxobjs))

_subdirs := $(addprefix $(LOCAL_PATH)/,$(module_subdirs))
_subdirs := $(addsuffix built-in.o,$(_subdirs))

$(LOCAL_PATH)/built-in.o-var := $(foreach s,$(addsuffix -flag,$(_subdirs)),$(s))
ifeq ($($(LOCAL_PATH)/built-in.o-flag),)
$(LOCAL_PATH)/built-in.o-flag := $(addprefix -l,$(module_link_libs))
else
$(LOCAL_PATH)/built-in.o-flag += $(addprefix -l,$(module_link_libs))
endif

_target := $(LOCAL_PATH)/$(module)-in.o

module_cflags += $(addprefix -I$(srctree)/$(LOCAL_PATH)/,$(module_c_includes))
$(_cobjs): _cflags:=$(module_cflags)
$(_cobjs): $(LOCAL_PATH)/%.o: $(LOCAL_PATH)/%.c FORCE
	$(call if_changed_dep,cobjs)

_targets += $(_cobjs)

module_cxxflags += $(addprefix -I$(srctree)/$(LOCAL_PATH)/,$(module_cxx_includes))
$(_cxxobjs): _cxxflags:=$(module_cxxflags)
$(_cxxobjs): $(LOCAL_PATH)/%.o: $(LOCAL_PATH)/%.cpp FORCE
	$(call if_changed_dep,cxxobjs)

_targets += $(_cxxobjs)

$(_target): $(_cobjs) $(_cxxobjs) $(_subdirs) FORCE
	$(call if_changed,link_o_target)

_targets += $(_target)

$(LOCAL_PATH)/built-in.o: $(_target)

ifeq ($($(LOCAL_PATH)-builin),)

$(LOCAL_PATH)-builin := 1
$(LOCAL_PATH)/built-in.o: test_flag=$(foreach var,$($@-var),$($(var)))
$(LOCAL_PATH)/built-in.o:
	echo test_flag $(test_flag)
	$(call if_changed,link_o_target)

$(LOCAL_PATH)/built-in.o-clean: cleanobjs:=$(LOCAL_PATH)/built-in.o 
$(LOCAL_PATH)/built-in.o-clean: FORCE
	-$(Q)$(RM) -rf $(cleanobjs)

TARGETS_ALL += $(LOCAL_PATH)/built-in.o

endif

cmd_files := $(wildcard $(foreach f,\
	$(_targets) $(LOCAL_PATH)/built-in.o,\
	$(dir $(f)).$(notdir $(f)).cmd))
include $(cmd_files)

_cleanobjs := $(cmd_files) $(_targets)
$(_target)-clean: cleanobjs:=$(_cleanobjs)
$(_target)-clean: FORCE
	-$(Q)$(RM) -rf $(cleanobjs)

$(LOCAL_PATH)/built-in.o-clean: $(_target)-clean

endif
