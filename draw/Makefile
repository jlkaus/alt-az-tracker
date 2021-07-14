CLASS = drawings
ifneq ($(CLASS),$(notdir $(patsubst %/,%,$(CURDIR))))
include $(CURDIR)/../mk/notarget.mk
else

include $(ROOTDIR)/mk/variables.mk

$(warning ROOTDIR=$(ROOTDIR))
$(warning CURDIR=$(CURDIR))
$(warning SRCDIR=$(SRCDIR))
$(warning OBJDIR=$(OBJDIR))
$(warning MAKECMDGOALS=$(MAKECMDGOALS))

VPATH = $(SRCDIR)

GENFLAGS = -m 6.25 #-p
PDFFLAGS = -f pdf -d 72 -p 72 -b white

.PHONY: all
all: test #linear circular

.PHONY: test
test: test_01.pdf

test_%.svg: test_%.cfg
	$(SRCDIR)/gen-test-pattern.pl $(GENFLAGS) $< -o $@

%.pdf: %.svg
	$(RSVGCONVERT) $(PDFFLAGS) $< -o $@

.PHONY: linear
linear: linear_01.pdf

linear_%.svg: linear_%.cfg
	$(SRCDIR)/gen-linear-quad-pattern.pl $(GENFLAGS) $< -o $@

.PHONY: circular
circular: circular_01.pdf

circular_%.svg: circular_%.cfg
	$(SRCDIR)/gen-circular-quad-pattern.pl $(GENFLAGS) $< -o $@

endif
