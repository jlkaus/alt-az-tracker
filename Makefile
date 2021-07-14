ifndef ROOTDIR
ROOTDIR := $(CURDIR)
export ROOTDIR
endif

include $(ROOTDIR)/mk/variables.mk

.PHONY: all
all: firmware test drawings

.PHONY: test
test:
	$(MAKE) -C $(ROOTDIR)/src test

.PHONY: firmware
firmware:
	$(MAKE) -C $(ROOTDIR)/src firmware

.PHONY: drawings
drawings:
	$(MAKE) -C $(ROOTDIR)/draw all

.PHONY: clean
clean:
	$(MAKE) -C $(ROOTDIR)/src clean
	$(MAKE) -C $(ROOTDIR)/draw clean

.PHONY: mostlyclean
mostlyclean:
	$(MAKE) -C $(ROOTDIR)/src mostlyclean
	$(MAKE) -C $(ROOTDIR)/draw mostlyclean

.PHONY: distclean
distclean:
	$(MAKE) -C $(ROOTDIR)/src distclean
	$(MAKE) -C $(ROOTDIR)/draw distclean
	-$(RM) -r $(ROOTDIR)/gen

.DEFAULT:
	$(MAKE) -C $(ROOTDIR)/src $(MAKECMDGOALS)
