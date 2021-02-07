# Build, compile and flash gateware and application

RM?=rm -f

BUILD_DIR=$(CURDIR)/build
BUILD_SOC_DIR=$(BUILD_DIR)/c10lprefkit

# Setup usable rules
all: gateware application
application: gateware
	BUILD_DIR=$(BUILD_DIR) BUILD_SOC_DIR=$(BUILD_SOC_DIR) $(MAKE) -C src
gateware: $(BUILD_SOC_DIR)/gateware/c10lprefkit.sof

# Cleaning rules
clean: clean-application clean-gateware
	$(RM) -r $(BUILD_DIR)
clean-application:
	BUILD_DIR=$(BUILD_DIR) BUILD_SOC_DIR=$(BUILD_SOC_DIR) $(MAKE) -C src clean
clean-gateware:
	$(RM) -r $(BUILD_SOC_DIR)

# Use litex script to build gateware (including bios)
%.sof: soc/c10lp-refkit-soc-demo
	python3 $< --build

.PHONY: all clean application clean_application gateware clean_gateware
