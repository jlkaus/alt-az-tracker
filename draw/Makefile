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

GENFLAGS = #-m 6.25 #-p -d -t
PDFFLAGS = -f pdf -d 72 -p 72 -b white

.PHONY: all
all: test linear circular

.PHONY: test
test: test_01.pdf

test_%.svg: test_%.cfg
	PERL5LIB=$(SRCDIR) $(SRCDIR)/gen-test-pattern.pl $(GENFLAGS) -g 203.2x266.7+0+0 $< -o $@

%.pdf: %.svg
	$(RSVGCONVERT) $(PDFFLAGS) $< -o $@

.PHONY: linear
linear: linear_0_01.pdf linear_1_01.pdf

linear_0_%.svg: linear_%.cfg
	PERL5LIB=$(SRCDIR) $(SRCDIR)/gen-linear-quad-pattern.pl $(GENFLAGS) -g 203.2x266.7+0+0 $< -o $@

linear_1_%.svg: linear_%.cfg
	PERL5LIB=$(SRCDIR) $(SRCDIR)/gen-linear-quad-pattern.pl $(GENFLAGS) -g 203.2x266.7+0+223.9 $< -o $@

.PHONY: circular
circular: circular_I_01.pdf circular_II_01.pdf circular_III_01.pdf circular_IV_01.pdf circular_small.pdf

circular_I_%.svg: circular_%.cfg
	PERL5LIB=$(SRCDIR) $(SRCDIR)/gen-circular-quad-pattern.pl $(GENFLAGS) -g 203.2x266.7+-5+-200 $< -o $@
circular_II_%.svg: circular_%.cfg
	PERL5LIB=$(SRCDIR) $(SRCDIR)/gen-circular-quad-pattern.pl $(GENFLAGS) -g 203.2x266.7+-200+-200 $< -o $@
circular_III_%.svg: circular_%.cfg
	PERL5LIB=$(SRCDIR) $(SRCDIR)/gen-circular-quad-pattern.pl $(GENFLAGS) -g 203.2x266.7+-200+-5 $< -o $@
circular_IV_%.svg: circular_%.cfg
	PERL5LIB=$(SRCDIR) $(SRCDIR)/gen-circular-quad-pattern.pl $(GENFLAGS) -g 203.2x266.7+-5+-5 $< -o $@

circular_small.svg: circular_small.cfg
	PERL5LIB=$(SRCDIR) $(SRCDIR)/gen-circular-quad-pattern.pl $(GENFLAGS) -g 203.2x266.7+-101.6+-133.35 $< -o $@


endif
