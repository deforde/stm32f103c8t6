TARGET_NAME := stm32f103c8t6_blink

CC := arm-none-eabi-gcc
AR := arm-none-eabi-ar
LD := arm-none-eabi-ld
OBJCP := arm-none-eabi-objcopy

BUILD_DIR := build
SRC_DIRS := src stm32f1xx_hal_driver/Src

SRCS := $(shell find $(SRC_DIRS) -name '*.c')
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_DIRS += stm32f1xx_hal_driver/Inc
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

CFLAGS := -mcpu=cortex-m3 -Wall -Wextra -Wpedantic -Werror -g3 -D_FORTIFY_SOURCE=2 $(INC_FLAGS) -MMD -MP
LDFLAGS := -T stm32.ld

BIN_FILE := $(BUILD_DIR)/$(TARGET_NAME).bin
OUT_FILE := $(BUILD_DIR)/$(TARGET_NAME)

all: $(OUT_FILE)

$(OUT_FILE): $(BIN_FILE)
	$(OBJCP) -O binary $< $@

$(BIN_FILE): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

$(BUILD_DIR)/%.c.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

libopencm3:
	git clone https://github.com/libopencm3/libopencm3
	cd libopencm3 && \
	make

.PHONY: clean compdb valgrind flash

flash: all
	openocd -f jtag/openocd.cfg -c "program $(OUT_FILE) 0x08000000 verify reset exit"

clean:
	@rm -rf $(addprefix $(BUILD_DIR)/,$(filter-out compile_commands.json,$(shell ls $(BUILD_DIR))))

compdb: clean
	@bear -- $(MAKE) san
	@mv compile_commands.json build

valgrind: debug
	@valgrind ./$(TARGET)

-include $(DEPS)
