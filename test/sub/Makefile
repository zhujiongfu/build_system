LOCAL_PATH := $(call my-dir)

include $(clear-vars)
module := sub
module_cflags := -L./
module_c_includes := ../
# module_link_libs := libffi
module_cobjs := sub.o
include $(build-execute)

include $(clear-vars)
module := thread
module_c_includes := ../
module_link_libs := pthread
module_cobjs := thread.o
include $(build-in)

include $(clear-vars)
module := shared
module_cobjs := shared.o
include $(build-shared)
