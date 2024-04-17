# The following method is used to generate .tcl files from make
# See https://stackoverflow.com/questions/649246/is-it-possible-to-create-a-multi-line-string-variable-in-a-makefile

include $(FLEXPRET_ROOT_DIR)/hwconfig.mk
TCL_GENERATE_FOLDER := $(FLEXPRET_ROOT_DIR)/fpga/$(BOARD_NAME)/$(PROJECT_NAME)/tcl/generated
CLK_PERIOD_NS := $(shell echo $$((1000 / $(CLK_FREQ_MHZ))))
CLK_HALF_PERIOD_NS := $(shell echo $$(($(CLK_PERIOD_NS) / 2)))

$(TCL_GENERATE_FOLDER)/flash_runnable.tcl: generate
	cat $(TCL_GENERATE_FOLDER)/variables.tcl $(PROJECT_TCL_DIR)/flash.tcl > $@

$(TCL_GENERATE_FOLDER)/bitstream_runnable.tcl: generate
	cat $(TCL_GENERATE_FOLDER)/variables.tcl $(PROJECT_TCL_DIR)/setup.tcl $(PROJECT_TCL_DIR)/bitstream.tcl > $@

$(TCL_GENERATE_FOLDER):
	mkdir -p $@

generate: $(TCL_GENERATE_FOLDER)
	echo "$$VARIABLES_TCL" > $(TCL_GENERATE_FOLDER)/variables.tcl
	echo "$$CLK_WIZ_CONFIG_TCL" > $(TCL_GENERATE_FOLDER)/clk_wiz_config.tcl
	echo "$$SET_PROGRAM_FILE_TCL" > $(TCL_GENERATE_FOLDER)/set_program_file.tcl
	echo "$$CLOCK_XDC" > $(PROJECT_DIR)/xdc/clock.xdc

clean::
	rm -rf $(TCL_GENERATE_FOLDER)
	rm -f $(PROJECT_TCL_DIR)/xdc/clock.xdc

HASHTAG := \#
define COMMON_WARNING
$(HASHTAG) This file is automatically generated and based on configuration
$(HASHTAG) set elsewhere in the project.
$(HASHTAG) 
$(HASHTAG) Should not be edited.
endef

# variables.tcl
define VARIABLES_TCL
$(COMMON_WARNING)

set outputDir ./vivado
set projectName $(PROJECT_NAME)
set boardName $(BOARD_NAME)
set partShort $(PART_SHORT)
set part $(PART)
set nCores $(NCORES)
endef
export VARIABLES_TCL

# clk_wiz_config.tcl
define CLK_WIZ_CONFIG_TCL
$(COMMON_WARNING)

set_property -dict [list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {$(CLK_FREQ_MHZ)} CONFIG.MMCM_CLKOUT0_DIVIDE_F {20.000} CONFIG.CLKOUT1_JITTER {151.636}] [get_ips clk_wiz_0]
endef
export CLK_WIZ_CONFIG_TCL

# set_program_file.tcl
define SET_PROGRAM_FILE_TCL
$(COMMON_WARNING)

set_property PROGRAM.FILE {$(PROJECT_DIR)/bitstream.bit} [get_hw_devices $(PART_SHORT)_1]
endef
export SET_PROGRAM_FILE_TCL

# Clock.xdc
define CLOCK_XDC
$(COMMON_WARNING)

$(HASHTAG)$(HASHTAG) $(CLK_FREQ_MHZ) MHz clock
set_property -dict {PACKAGE_PIN Y9 IOSTANDARD LVCMOS33} [get_ports {CLK_$(CLK_FREQ_MHZ)MHZ_FPGA}];  # "GCLK"
create_clock -period $(CLK_PERIOD_NS).000 -name sys_clk_pin -waveform {0.000 $(CLK_HALF_PERIOD_NS).000} -add [get_ports CLK_$(CLK_FREQ_MHZ)MHZ_FPGA]
endef
export CLOCK_XDC