# Include litex makefiles
include build/c10lprefkit/software/include/generated/variables.mak
include $(SOC_DIRECTORY)/software/common.mak

OBJECTS=build/application/main.o
BUILD_DIR=build
BUILD_SOC_DIR=$(BUILD_DIR)/c10lprefkit
BUILD_APP_DIR=$(BUILD_DIR)/application

# Setup usable rules
all: gateware application
application: $(BUILD_APP_DIR)/application.bin
gateware: $(BUILD_SOC_DIR)/gateware/c10lprefkit.sof

# Use litex script to build gateware (including bios)
*.sof: soc/c10lp-refkit-soc-demo
	python3 $< --build

# Build application binary
%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

build/application/application.elf: $(OBJECTS)
	$(LD) $(LDFLAGS) \
	  	-T src/linker.ld \
		-N -o $@ \
		$(BUILD_SOC_DIR)/software/libbase/crt0.o \
		$(OBJECTS) \
		-L$(BUILD_SOC_DIR)/software/libbase \
		-L$(BUILD_SOC_DIR)/software/libcompiler_rt \
		-lbase-nofloat -lcompiler_rt

build/application/%.o: src/%.c $(BUILD_APP_DIR)
	$(compile)

# Create needed directories
$(BUILD_APP_DIR):
	mkdir -p $@

.PHONY: all application gateware $(BUILD_APP_DIR)
