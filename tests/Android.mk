#
# Copyright (C) 2012 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

LOCAL_PATH := $(call my-dir)

# -----------------------------------------------------------------------------
# Benchmarks.
# -----------------------------------------------------------------------------

benchmark_c_flags = \
    -O2 \
    -Wall -Wextra \
    -Werror \
    -fno-builtin \

benchmark_src_files = \
    benchmark_main.cpp \
    math_benchmark.cpp \
    string_benchmark.cpp \
    time_benchmark.cpp \

ifeq ($(PROPERTY_SYSTEM_SUPPORT),true)
benchmark_src_files += \
    property_benchmark.cpp \

endif

# Build benchmarks for the device (with bionic's .so). Run with:
#   adb shell bionic-benchmarks
ifneq ($(EXTRA_STLPORT_SUPPORT),)
include $(CLEAR_VARS)
LOCAL_MODULE := bionic-benchmarks
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_CFLAGS += $(benchmark_c_flags)
LOCAL_C_INCLUDES += external/stlport/stlport bionic/ bionic/libstdc++/include
LOCAL_FORCE_STATIC_EXECUTABLE := true
LOCAL_STATIC_LIBRARIES += libstlport_static libstdc++ libm libc
LOCAL_SRC_FILES := $(benchmark_src_files)
include $(BUILD_EXECUTABLE)
endif

# -----------------------------------------------------------------------------
# Unit tests.
# -----------------------------------------------------------------------------

test_c_flags = \
    -fstack-protector-all \
    -g \
    -Wall -Wextra \
    -Werror \
    -fno-builtin \

test_src_files = \
    dirent_test.cpp \
    eventfd_test.cpp \
    fenv_test.cpp \
    getauxval_test.cpp \
    getcwd_test.cpp \
    inttypes_test.cpp \
    libc_logging_test.cpp \
    libgen_test.cpp \
    malloc_test.cpp \
    math_test.cpp \
    netdb_test.cpp \
    pthread_test.cpp \
    regex_test.cpp \
    signal_test.cpp \
    stack_protector_test.cpp \
    stack_unwinding_test.cpp \
    statvfs_test.cpp \
    stdio_test.cpp \
    stdlib_test.cpp \
    string_test.cpp \
    strings_test.cpp \
    stubs_test.cpp \
    sys_select_test.cpp \
    sys_sendfile_test.cpp \
    sys_stat_test.cpp \
    time_test.cpp \
    unistd_test.cpp \

ifeq ($(PROPERTY_SYSTEM_SUPPORT),true)
test_src_files += \
    system_properties_test.cpp \

endif

ifeq ($(STPCPY_IMPL),true)
  test_c_flags += -DSTPCPY_IMPL
endif

ifeq ($(STRCHRNUL_IMPL),true)
  test_c_flags += -DSTRCHRNUL_IMPL
endif

ifeq ($(MEMPCPY_IMPL),true)
  test_c_flags += -DMEMPCPY_IMPL
endif

ifeq ($(SYSVIPC_SUPPORT),true)
  test_src_files += sysvipc_test.cpp
endif

test_dynamic_ldflags = -Wl,--export-dynamic -Wl,-u,DlSymTestFunction
test_dynamic_src_files = \
    dlfcn_test.cpp \

test_fortify_static_libraries = \
    fortify1-tests-gcc fortify2-tests-gcc
# disable this unit test for clang on olibc
#    fortify1-tests-clang fortify2-tests-clang

include $(CLEAR_VARS)
LOCAL_MODULE := bionic-unit-tests-unwind-test-impl
LOCAL_CFLAGS += $(test_c_flags) -fexceptions -fnon-call-exceptions
LOCAL_SRC_FILES := stack_unwinding_test_impl.c
include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_MODULE := bionic-unit-tests-unwind-test-impl-host
LOCAL_CFLAGS += $(test_c_flags) -fexceptions -fnon-call-exceptions
LOCAL_SRC_FILES := stack_unwinding_test_impl.c
include $(BUILD_HOST_STATIC_LIBRARY)

# Build tests for the device (with bionic's .so). Run with:
#   adb shell /data/nativetest/bionic-unit-tests/bionic-unit-tests
ifneq ($(EXTRA_STLPORT_SUPPORT),)
include $(CLEAR_VARS)
LOCAL_MODULE := bionic-unit-tests
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_CFLAGS += $(test_c_flags)
LOCAL_LDFLAGS += $(test_dynamic_ldflags)
LOCAL_SHARED_LIBRARIES += libdl
LOCAL_SRC_FILES := $(test_src_files) $(test_dynamic_src_files)
LOCAL_WHOLE_STATIC_LIBRARIES := $(test_fortify_static_libraries)
LOCAL_STATIC_LIBRARIES += bionic-unit-tests-unwind-test-impl
include $(BUILD_NATIVE_TEST)
endif

# Build tests for the device (with bionic's .a). Run with:
#   adb shell /data/nativetest/bionic-unit-tests-static/bionic-unit-tests-static
ifneq ($(EXTRA_STLPORT_SUPPORT),)
include $(CLEAR_VARS)
LOCAL_MODULE := bionic-unit-tests-static
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_FORCE_STATIC_EXECUTABLE := true
LOCAL_WHOLE_STATIC_LIBRARIES += libBionicTests
LOCAL_STATIC_LIBRARIES += libstlport_static libstdc++ libm libc
include $(BUILD_NATIVE_TEST)
endif

# -----------------------------------------------------------------------------
# We build the static unit tests as a library so they can be used both for
# bionic-unit-tests-static and also as part of CTS.
# -----------------------------------------------------------------------------

include $(CLEAR_VARS)
LOCAL_MODULE := libBionicTests
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_CFLAGS += $(test_c_flags)
LOCAL_SRC_FILES := $(test_src_files)
LOCAL_CFLAGS += \
    -DGTEST_OS_LINUX_ANDROID \
    -DGTEST_HAS_STD_STRING \

LOCAL_C_INCLUDES += \
    bionic bionic/libstdc++/include \
    external/gtest/include \
    external/stlport/stlport \

LOCAL_WHOLE_STATIC_LIBRARIES := \
    $(test_fortify_static_libraries) \
    bionic-unit-tests-unwind-test-impl \

include $(BUILD_STATIC_LIBRARY)

# -----------------------------------------------------------------------------
# Test library for the unit tests.
# -----------------------------------------------------------------------------

# Build no-elf-hash-table-library.so to test dlopen(3) on a library that
# only has a GNU-style hash table. MIPS doesn't support GNU hash style.
ifneq ($(TARGET_ARCH),mips)
include $(CLEAR_VARS)
LOCAL_MODULE := no-elf-hash-table-library
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_SRC_FILES := empty.cpp
LOCAL_LDFLAGS := -Wl,--hash-style=gnu
include $(BUILD_SHARED_LIBRARY)
endif

# -----------------------------------------------------------------------------
# Unit tests built against glibc.
# -----------------------------------------------------------------------------

# Build tests for the host (with glibc).
# Note that this will build against glibc, so it's not useful for testing
# bionic's implementation, but it does let you use glibc as a reference
# implementation for testing the tests themselves.
ifeq ($(HOST_OS)-$(HOST_ARCH),linux-x86)
include $(CLEAR_VARS)
LOCAL_MODULE := bionic-unit-tests-glibc
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_CFLAGS += $(test_c_flags)
LOCAL_LDFLAGS += -lpthread -ldl -lrt
LOCAL_LDFLAGS += $(test_dynamic_ldflags)
LOCAL_SRC_FILES := $(test_src_files) $(test_dynamic_src_files)
LOCAL_STATIC_LIBRARIES += bionic-unit-tests-unwind-test-impl-host
include $(BUILD_HOST_NATIVE_TEST)
endif

# -----------------------------------------------------------------------------
# Run the unit tests built against x86 bionic on an x86 host.
# -----------------------------------------------------------------------------

ifeq ($(HOST_OS)-$(HOST_ARCH),linux-x86)
ifeq ($(TARGET_ARCH),x86)
# gtest needs EXTERNAL_STORAGE for death test output.
# bionic itself should always work relative to ANDROID_DATA or ANDROID_ROOT.
# We create /data/local/tmp to be as much like the regular target environment
# as possible.
bionic-unit-tests-run-on-host: bionic-unit-tests $(TARGET_OUT_EXECUTABLES)/linker
	mkdir -p $(TARGET_OUT_DATA)/local/tmp
	cp $(TARGET_OUT_EXECUTABLES)/linker /system/bin
	cp $(TARGET_OUT_EXECUTABLES)/sh /system/bin
	ANDROID_DATA=$(TARGET_OUT_DATA) \
	ANDROID_ROOT=$(TARGET_OUT) \
	EXTERNAL_STORAGE=$(TARGET_OUT_DATA)/local/tmp \
	LD_LIBRARY_PATH=$(TARGET_OUT_SHARED_LIBRARIES) \
		$(TARGET_OUT_DATA_NATIVE_TESTS)/bionic-unit-tests/bionic-unit-tests
endif
endif

# -----------------------------------------------------------------------------
# FORTIFY_SOURCE tests
# -----------------------------------------------------------------------------

fortify_c_includes = \
    bionic \
    bionic/libstdc++/include \
    external/stlport/stlport \
    external/gtest/include
fortify_test_files = fortify_test.cpp

# -Wno-error=unused-parameter needed as
# external/stlport/stlport/stl/_threads.c (included from
# external/gtest/include/gtest/gtest.h) does not compile cleanly under
# clang. TODO: fix this.
fortify_c_flags = $(test_c_flags) -Wno-error=unused-parameter

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(fortify_test_files)
LOCAL_MODULE := fortify1-tests-gcc
LOCAL_CFLAGS += $(fortify_c_flags) -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=1 -DTEST_NAME=Fortify1_Gcc
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_C_INCLUDES += $(fortify_c_includes)
include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(fortify_test_files)
LOCAL_MODULE := fortify2-tests-gcc
LOCAL_CFLAGS += $(fortify_c_flags) -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2 -DTEST_NAME=Fortify2_Gcc
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_C_INCLUDES += $(fortify_c_includes)
include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(fortify_test_files)
LOCAL_MODULE := fortify1-tests-clang
LOCAL_CLANG := true
LOCAL_CFLAGS += $(fortify_c_flags) -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=1 -DTEST_NAME=Fortify1_Clang
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_C_INCLUDES += $(fortify_c_includes)
include $(BUILD_STATIC_LIBRARY)

include $(CLEAR_VARS)
LOCAL_SRC_FILES := $(fortify_test_files)
LOCAL_MODULE := fortify2-tests-clang
LOCAL_CLANG := true
LOCAL_CFLAGS += $(fortify_c_flags) -U_FORTIFY_SOURCE -D_FORTIFY_SOURCE=2 -DTEST_NAME=Fortify2_Clang
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
LOCAL_C_INCLUDES += $(fortify_c_includes)
include $(BUILD_STATIC_LIBRARY)
