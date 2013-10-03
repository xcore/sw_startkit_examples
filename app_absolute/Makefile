TARGET = STARTKIT
APP_NAME =
XCC_FLAGS = -fxscope -lxscope
USED_MODULES = module_capacitive_sensing

XMOS_MAKE_PATH ?= ../..
ifneq ($(wildcard $(XMOS_MAKE_PATH)/xcommon/module_xcommon/build/Makefile.common),)
include $(XMOS_MAKE_PATH)/xcommon/module_xcommon/build/Makefile.common
else
include ../module_xcommon/build/Makefile.common
endif
