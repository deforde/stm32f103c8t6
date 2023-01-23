TARGET_NAME := stm32f103c8t6_blink

CC := arm-none-eabi-gcc
AR := arm-none-eabi-ar
LD := arm-none-eabi-ld
OBJCP := arm-none-eabi-objcopy

BUILD_DIR := build
SRC_DIRS := src

SRCS := $(shell find $(SRC_DIRS) -name '*.c')
OBJS := $(SRCS:%=$(BUILD_DIR)/%.o)
DEPS := $(OBJS:.o=.d)

INC_DIRS := $(shell find $(SRC_DIRS) -type d)
INC_DIRS += libopencm3/include
INC_FLAGS := $(addprefix -I,$(INC_DIRS))

CFLAGS := -mcpu=cortex-m3 -mthumb -DSTM32F1 -Wall -Wextra -Wpedantic -Werror $(INC_FLAGS) -MMD -MP
LDFLAGS := -nostartfiles -nostdlib -Llibopencm3/lib -Tstm32f103c8t6.ld -lopencm3_stm32f1

BIN_FILE := $(BUILD_DIR)/$(TARGET_NAME).bin
OUT_FILE := $(BUILD_DIR)/$(TARGET_NAME)

LIBOPENCM3 := libopencm3/lib/libopencm3_stm32f1.a

all: $(OUT_FILE)

$(OUT_FILE): $(BIN_FILE)
	$(OBJCP) -O binary $< $@

$(BIN_FILE): $(LIBOPENCM3) $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS)

$(BUILD_DIR)/%.c.o: %.c
	mkdir -p $(dir $@)
	$(CC) $(CFLAGS) -c $< -o $@

$(LIBOPENCM3):
	git clone https://github.com/libopencm3/libopencm3
	cd libopencm3 && \
	make

.PHONY: clean compdb valgrind flash

flash: all
	openocd -f interface/stlink.cfg -f board/stm32f103c8_blue_pill.cfg -c "program $(OUT_FILE) 0x08000000 verify reset exit"

clean:
	@rm -rf $(addprefix $(BUILD_DIR)/,$(filter-out compile_commands.json,$(shell ls $(BUILD_DIR))))

compdb: clean
	@bear -- $(MAKE) san
	@mv compile_commands.json build

valgrind: debug
	@valgrind ./$(TARGET)

-include $(DEPS)
