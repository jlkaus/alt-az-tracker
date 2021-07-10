ifndef ROOTDIR
ROOTDIR := $(CURDIR)
export ROOTDIR
endif

include $(ROOTDIR)/mk/variables.mk

.PHONY: all
all: firmware test

.PHONY: test
test:
	$(MAKE) -C $(ROOTDIR)/src test

.PHONY: firmware
firmware:
	$(MAKE) -C $(ROOTDIR)/src firmware

.PHONY: clean
clean:
	$(MAKE) -C $(ROOTDIR)/src clean

.PHONY: mostlyclean
mostlyclean:
	$(MAKE) -C $(ROOTDIR)/src mostlyclean

.PHONY: distclean
distclean:
	$(MAKE) -C $(ROOTDIR)/src distclean
	$(RM) -r $(ROOTDIR)/gen

.DEFAULT:
	$(MAKE) -C $(ROOTDIR)/src $(MAKECMDGOALS)
