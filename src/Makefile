ifneq (firmware,$(notdir $(patsubst %/,%,$(dir $(CURDIR)))))
include $(CURDIR)/../mk/target.mk
else

include $(ROOTDIR)/mk/variables.mk
include $(ROOTDIR)/mk/rules.mk

INCDIR := $(ROOTDIR)/include
LIBDIR := .

$(warning ROOTDIR=$(ROOTDIR))
$(warning CURDIR=$(CURDIR))
$(warning SRCDIR=$(SRCDIR))
$(warning OBJDIR=$(OBJDIR))
$(warning INCDIR=$(INCDIR))
$(warning LIBDIR=$(LIBDIR))
$(warning MAKECMDGOALS=$(MAKECMDGOALS))

VPATH = $(SRCDIR)

CDEFS = -DDEFAULT_LONGITUDE=$(DEFAULT_LONGITUDE) -DDEFAULT_LATITUDE=$(DEFAULT_LATITUDE) -DVERSION=$(VERSION) -DPKGNAME=$(PKGNAME) -DAVR_TYPE=$(TARGET_AVR) -DAVR_FREQ=$(TARGET_AVR_FREQ)

AVRFLAGS = -mmcu=$(TARGET_AVR) -DF_CPU=$(TARGET_AVR_FREQ)
CFLAGS = $(CDEFS) -Wall -Werror -Os $(AVRFLAGS) -I$(INCDIR) -std=gnu17
CXXFLAGS = $(CDEFS) -D__STDC_LIMIT_MACROS -Wall -Werror -Os $(AVRFLAGS) -I$(INCDIR) -std=gnu++17
LDFLAGS = $(AVRFLAGS) -L$(LIBDIR)
LDLIBS = 

.PHONY: all
all: firmware eeprom test

# Build the main firmware image
.PHONY: firmware
firmware: $(PKGNAME).hex

$(PKGNAME).elf: $(PKGNAME).o

$(PKGNAME).o: $(PKGNAME).C

# Build the eeprom base image
.PHONY: eeprom
eeprom: $(PKGNAME)_eeprom.hex

# Build the test firmware images
.PHONY: test
test: test-rtc.hex test-lcd.hex test-pins.hex

test-rtc.elf: test-rtc.o

test-rtc.o: test-rtc.C

test-lcd.elf: test-lcd.o

test-lcd.o: test-lcd.C

test-pins.elf: test-pins.o

test-pins.o: test-pins.C

endif 
