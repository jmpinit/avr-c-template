NAME := firmware
MCU := atmega328p
MCU_AVRDUDE := atmega328p
MCU_FREQ := 8000000UL
PROGRAMMER := usbtiny

SOURCES =	main.c

ifeq ($(OS),Windows_NT)
S := \\
else
S := /
endif

SRCDIR := src
OBJDIR := obj
BINDIR := bin

HEX := $(BINDIR)$(S)$(NAME).hex
OUT := $(OBJDIR)$(S)$(NAME).out
MAP := $(OBJDIR)$(S)$(NAME).map

INCLUDES = -Isrc$(S)inc
OBJECTS = $(patsubst %,$(OBJDIR)$(S)%,$(SOURCES:.c=.o))

CC := avr-gcc
OBJCOPY := avr-objcopy
SIZE := avr-size -C --mcu=$(MCU)

CFLAGS := -Wall -pedantic -mmcu=$(MCU) -std=c99 -g -Os -DF_CPU=$(MCU_FREQ) -gstabs

all: $(OBJDIR) $(BINDIR) $(HEX)

clean:
ifeq ($(OS),Windows_NT)
	del $(HEX) $(OUT) $(MAP) $(OBJECTS)
else
	rm $(HEX) $(OUT) $(MAP) $(OBJECTS)
endif

flash: $(HEX)
	avrdude -c $(PROGRAMMER) -p $(MCU_AVRDUDE) -U flash:w:$(HEX)

$(HEX): $(OUT)
	$(OBJCOPY) -R .eeprom -O ihex $< $@

$(OUT): $(OBJECTS)
	$(CC) $(CFLAGS) -o $@ -Wl,-Map,$(MAP) $^
	@echo = = = = = = = = =
	$(SIZE) $@

$(OBJDIR)$(S)%.o: $(SRCDIR)$(S)%.c
	$(CC) $(CFLAGS) $(INCLUDES) -c -o $@ $<
	
$(OBJDIR):
	mkdir -p $(OBJDIR)

$(BINDIR):
	mkdir -p $(BINDIR)

.PHONY: all clean flash

