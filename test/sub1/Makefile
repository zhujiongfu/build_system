LOCAL_PATH := $(call my-dir)

include $(clear-vars)
module := sub1
# module_cflags := -L./
# module_c_includes := ../
# module_link_libs := libffi
module_cobjs := sub1.o
include $(build-execute)

include $(clear-vars)
module := ncurses
module_link_libs := ncurses
module_cobjs := ncurses.o
module_c_includes := ../
module_link_libs := abc
include $(build-in)
