# Build, compile and flash gateware and application

RM?=rm -f
LN?=ln
CP?=cp

BUILD_DIR=$(CURDIR)/build
BUILD_SOC_DIR=$(BUILD_DIR)/c10lprefkit
BUILD_APP_DIR=$(BUILD_DIR)/application

# Setup usable rules
all: gateware application

application: $(BUILD_DIR)/application.bin                  # Build application

gateware: $(BUILD_DIR)/gateware.sof                        # Build gateware

load: soc/c10lp-refkit-soc-demo $(BUILD_DIR)/gateware.sof  # Load gateware to FPGA
	python3 $< --load

load-flash: $(BUILD_DIR)/indirect_flash.jic                 # Load gateware to FPGA flash
	quartus_pgm -m JTAG -c Arrow-USB-Blaster -i -o "ipv;$<"

run: $(BUILD_DIR)/application.bin                           # Flash gateware and application
	flterm --port $(PORT) --kernel $<


# Cleaning rules
clean: clean-application clean-gateware
	$(RM) -r $(BUILD_DIR)

clean-application:
	BUILD_DIR=$(BUILD_DIR) BUILD_SOC_DIR=$(BUILD_SOC_DIR) $(MAKE) -C src clean
	$(RM) $(BUILD_DIR)/application.bin

clean-gateware:
	$(RM) -r $(BUILD_SOC_DIR)
	$(RM) $(BUILD_DIR)/gateware.sof

# Link generated headers, linker scripts and makefile segments for use in application
$(BUILD_APP_DIR)/generated: $(BUILD_SOC_DIR)/software/include/generated
	if [ ! -e $< ]; then  $(LN) -s $< $@; fi;

# Use litex script to build gateware (including bios)
$(BUILD_DIR)/gateware.sof: $(BUILD_SOC_DIR)/gateware/c10lprefkit.sof
	$(CP) -f $< $@

$(BUILD_SOC_DIR)/%.sof: soc/c10lp-refkit-soc-demo
	python3 $< --build

# Build application with recursive make
$(BUILD_DIR)/%.bin: $(BUILD_APP_DIR)/%.bin
	$(CP) -f $< $@

$(BUILD_APP_DIR)/application.bin: $(BUILD_APP_DIR)/generated
	BUILD_DIR=$(BUILD_DIR) BUILD_SOC_DIR=$(BUILD_SOC_DIR) $(MAKE) -C src application

# Use quartus_pgm to build flashing configuration files
$(BUILD_DIR)/indirect_flash.jic: $(BUILD_DIR)/gateware.sof
	quartus_cpf -c -d EPCQ16A -s 10CL055Y $< $@

.PHONY: all clean application clean_application gateware load clean_gateware $(BUILD_APP_DIR)/application.bin
.SECONDARY: $(BUILD_SOC_DIR)/gateware/%.sof
