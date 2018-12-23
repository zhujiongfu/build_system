LOCAL_PATH := $(call my-dir)
TEST_PATH := $(LOCAL_PATH)

include $(clear-vars)
module := test
module_cobjs := main.o
module_cflags := -I./
module_cxxflags := -I./
module_link_libs := 
include $(build-in)

include $(clear-vars)
module := helloworld
module_cobjs := helloworld.o
module_subdirs := sub1/ sub/
include $(build-in)

include $(clear-vars)
module := cpp
module_subdirs := sub/
module_cxxobjs := testcpp.o
module_link_libs := pthread
module_link_path := ./
include $(build-execute)

include $(TEST_PATH)/sub/Makefile
include $(TEST_PATH)/sub1/Makefile
