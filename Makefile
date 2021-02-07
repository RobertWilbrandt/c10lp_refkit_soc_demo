# Build, compile and flash gateware and application

RM?=rm -f

BUILD_DIR=$(CURDIR)/build
BUILD_SOC_DIR=$(BUILD_DIR)/c10lprefkit
BUILD_APP_DIR=$(BUILD_DIR)/application

# Setup usable rules
all: gateware application
application: gateware $(BUILD_DIR)/application.bin
gateware: $(BUILD_DIR)/c10lprefkit.sof

# Cleaning rules
clean: clean-application clean-gateware
	$(RM) -r $(BUILD_DIR)
clean-application:
	BUILD_DIR=$(BUILD_DIR) BUILD_SOC_DIR=$(BUILD_SOC_DIR) $(MAKE) -C src clean
clean-gateware:
	$(RM) -r $(BUILD_SOC_DIR)

# Use litex script to build gateware (including bios)
$(BUILD_DIR)/%.sof: $(BUILD_SOC_DIR)/gateware/%.sof
	ln -s $< $@

$(BUILD_SOC_DIR)/gateware/%.sof: soc/c10lp-refkit-soc-demo
	python3 $< --build

# Build application with recursive make
$(BUILD_DIR)/%.bin: $(BUILD_APP_DIR)/%.bin
	ln -s $< $@

$(BUILD_APP_DIR)/application.bin:
	BUILD_DIR=$(BUILD_DIR) BUILD_SOC_DIR=$(BUILD_SOC_DIR) $(MAKE) -C src

.PHONY: all clean application clean_application gateware clean_gateware
