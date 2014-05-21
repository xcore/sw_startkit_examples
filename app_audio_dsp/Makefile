# The TARGET variable determines what target system the application is
# compiled for. It either refers to an XN file in the source directories
# or a valid argument for the --target option when compiling.

TARGET = STARTKIT
APP_NAME = startkit_audio_dsp

# The flags passed to xcc when building the application
BUILD_FLAGS = -Wall -O3 -report -g -DSDA_HIGH=2 -DSCL_HIGH=1

# The USED_MODULES variable lists other module used by the application. These
# modules will extend the SOURCE_DIRS, INCLUDE_DIRS and LIB_DIRS variables.
# Modules are expected to be in the directory above the BASE_DIR directory.
USED_MODULES  = module_capacitive_sensing module_cascading_biquad module_dsp_utils module_i2c_single_port
USED_MODULES += module_i2s_master module_startkit_gpio module_logging

XCC_FLAGS = $(BUILD_FLAGS) -fxscope

#=============================================================================
# The following part of the Makefile includes the common build infrastructure
# for compiling XMOS applications. You should not need to edit below here.

XMOS_MAKE_PATH ?= ../..
include $(XMOS_MAKE_PATH)/xcommon/module_xcommon/build/Makefile.common

VERBOSE = 0
