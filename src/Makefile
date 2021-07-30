ifneq (firmware,$(notdir $(patsubst %/,%,$(dir $(CURDIR)))))
include $(CURDIR)/../mk/target.mk
else

include $(ROOTDIR)/mk/variables.mk
include $(ROOTDIR)/mk/rules.mk

INCDIR := $(ROOTDIR)/src
LIBDIR := $(CURDIR)

$(warning ROOTDIR=$(ROOTDIR))
$(warning CURDIR=$(CURDIR))
$(warning SRCDIR=$(SRCDIR))
$(warning OBJDIR=$(OBJDIR))
$(warning INCDIR=$(INCDIR))
$(warning LIBDIR=$(LIBDIR))
$(warning MAKECMDGOALS=$(MAKECMDGOALS))

VPATH = $(SRCDIR)

CDEFS = -DDEFAULT_LONGITUDE=$(DEFAULT_LONGITUDE) -DDEFAULT_LATITUDE=$(DEFAULT_LATITUDE) -DVERSION=$(VERSION) -DPKGNAME=$(PKGNAME) -DAVR_TYPE=$(TARGET_AVR) -DF_CPU=$(TARGET_AVR_FREQ)

CFLAGS = $(CDEFS) -Wall -Werror -Os -mmcu=$(TARGET_AVR) -I$(INCDIR) -std=gnu17
CXXFLAGS = $(CDEFS) -D__STDC_LIMIT_MACROS -Wall -Werror -Os -mmcu=$(TARGET_AVR) -I$(INCDIR) -std=gnu++17
LDFLAGS = -mmcu=$(TARGET_AVR) -L$(LIBDIR)
LDLIBS = 

.PHONY: all
all: firmware eeprom test

# Build the main firmware image
.PHONY: firmware
firmware: $(PKGNAME).hex

$(PKGNAME).elf: $(PKGNAME).o lcd2004.o ds3231.o serial.o config.o quadrature.o helper.o

$(PKGNAME).o: $(PKGNAME).c lcd2004.h ds3231.h serial.h quadrature.h pins.h config.h helper.h

# Build the eeprom base image
.PHONY: eeprom
eeprom: $(PKGNAME)_eeprom.hex

# Build the test firmware images
.PHONY: test
test: test-rtc.hex test-lcd.hex test-pins.hex test-basic.hex

test-rtc.elf: test-rtc.o ds3231.o serial.o helper.o

test-rtc.o: test-rtc.c ds3231.h serial.h pins.h helper.h

test-lcd.elf: test-lcd.o lcd2004.o serial.o helper.o

test-lcd.o: test-lcd.c lcd2004.h serial.h pins.h helper.h

test-pins.elf: test-pins.o serial.o quadrature.o helper.o

test-pins.o: test-pins.c serial.h quadrature.h pins.h helper.h

test-basic.elf: test-basic.o serial.o helper.o

test-basic.o: test-basic.c serial.h helper.h pins.h

endif
