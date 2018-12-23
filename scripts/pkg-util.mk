#
# Author: zhujiongfu(zhujiongfu@live.cn)
# Date: Sat Dec 22 09:43:10 CST 2018
#

_arg-check = $(strip $(filter-out $(cmd_$(1)), $(cmd_$@)) \
                    $(filter-out $(cmd_$@),   $(cmd_$(1))) )

_any-prereq = $(filter-out $(PHONY),$?) $(filter-out $(PHONY) $(wildcard $^),$^)

_make-cmd = $(call escsq,$(subst \#,\\\#,$(subst $$,$$$$,$(cmd_$(1)))))

# Execute command if command has changed or prerequisite(s) are updated.
#
_if_changed = $(if $(strip $(any-prereq) $(arg-check)),                       \
	@set -e;                                                             \
	$(echo-cmd) $(cmd_$(1));                                             \
	printf '%s\n' 'cmd_$@ := $(make-cmd)' > $(dot-target).cmd)

# Execute the command and also postprocess generated .d dependencies file.
_if_changed_dep = $(if $(strip $(any-prereq) $(_arg-check)),                    \
	@set -e;                                                                \
	$(echo-cmd) $(cmd_$(1));                                                \
	scripts/basic/fixdep $(depfile) $@ '$(make-cmd)' > $(dot-target).tmp;\
	rm -f $(depfile);                                                      \
	mv -f $(dot-target).tmp $(dot-target).cmd)

test_dep = $(if $(strip $(any-prereq) $(arg-check)),echo "$@ oo $(arg-check) $(cmd_$(1)) s $(cmd_$@) oo $(any-prereq)";)

quiet_cmd_cobjs 	= CC  $@
      cmd_cobjs		= $(CC) -Wp,-MD,$(depfile) $(_cflags) $(c_flags) -c -o $@ $<

quiet_cmd_cxxobjs	= CXX  $@
      cmd_cxxobjs	= $(CXX) -Wp,-MD,$(depfile) $(_cxxflags) $(cxx_flags) -c -o $@ $<

quiet_cmd_execute 	= LINK $@
      cmd_execute 	= $(CXX) $(_builinflags) $(_linkflags) -o $@ $(filter-out FORCE,$^) 

quiet_cmd_shared 	= LINK $@
      cmd_shared 	= $(CXX) $(_linkflags) -shared -o $@ $(filter-out FORCE,$^)

quiet_cmd_install 	= INSTALL $<
      cmd_install       = $(INSTALL) -D -m 0755 $< $(_install_path)/$(notdir $<)

quiet_cmd_link_o_target = LD $@
      cmd_link_o_target = $(LD) -r -o $@ $(filter-out FORCE,$^)

quiet_cmd_strip         = STRIP $@
      cmd_strip         = $(STRIP) -s --remove-section=.note --remove-section=.comment \
			    $@-unstripped -o $@

curdir = $(patsubst %/, %,$(dir $(lastword $(MAKEFILE_LIST))))

clear-vars := $(srctree)/scripts/clear-vars.mk
build-execute := $(srctree)/scripts/build-execute.mk
build-shared := $(srctree)/scripts/build-shared.mk
build-in := $(srctree)/scripts/build-in.mk

ifeq ($(KBUILD_SRC),)
define my-dir
$(patsubst %/, %, $(dir $(lastword $(MAKEFILE_LIST))))
endef
else
define my-dir
$(patsubst $(KBUILD_SRC)/%,%,$(shell realpath $(patsubst %/, %, $(dir $(lastword $(MAKEFILE_LIST))))))
endef
endif


[FROM] := a b c d e f g h i j k l m n o p q r s t u v w x y z - .
[TO]   := A B C D E F G H I J K L M N O P Q R S T U V W X Y Z _ _

define caseconvert-helper
$(1) = $$(strip \
	$$(eval __tmp := $$(1))\
	        $(foreach c, $(2),\
		$$(eval __tmp := $$(subst $(word 1,$(subst :, ,$c)),$(word 2,$(subst :, ,$c)),$$(__tmp))))\
		        $$(__tmp))
endef

$(eval $(call caseconvert-helper,UPPERCASE,$(join $(addsuffix :,$([FROM])),$([TO]))))
$(eval $(call caseconvert-helper,LOWERCASE,$(join $(addsuffix :,$([TO])),$([FROM]))))
