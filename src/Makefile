ifneq (exec,$(notdir $(patsubst %/,%,$(dir $(CURDIR)))))
include $(CURDIR)/../mk/target.mk
else
.PHONY: exec test 

include $(ROOTDIR)/mk/variables.mk

INCDIR := $(ROOTDIR)/include

$(warning ROOTDIR=$(ROOTDIR))
$(warning CURDIR=$(CURDIR))
$(warning SRCDIR=$(SRCDIR))
$(warning OBJDIR=$(OBJDIR))
$(warning INCDIR=$(INCDIR))
$(warning MAKECMDGOALS=$(MAKECMDGOALS))

VPATH = $(SRCDIR)

CXXDEFS = -DDEFAULT_LONGITUDE=$(DEFAULT_LONGITUDE) -DDEFAULT_LATITUDE=$(DEFAULT_LATITUDE) -DVERSION=$(VERSION) -DPKGNAME=$(PKGNAME) -DARCH=$(TARGET_ARCH_TYPE)
CXXFLAGS = -std=gnu++11 -I$(INCDIR) -Wall -Werror $(CXXDEFS) -g -rdynamic
LDLIBS = -lm

exec: $(PKGNAME)

test: test-rtc test-lcd test-pins

test-rtc: test-rtc.o
	$(LINK.cc) $^ $(LOADLIBES) $(LDLIBS) -o $@

test-rtc.o:

test-lcd: test-lcd.o

test-lcd.o:

test-pins: test-pins.o

test-pins.o:

$(PKGNAME): $(PKGNAME).o
	$(LINK.cc) $^ $(LOADLIBES) $(LDLIBS) -o $@

$(PKGNAME).o: $(PKGNAME).C




endif 
