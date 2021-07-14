.SUFFIXES:

include $(CURDIR)/../mk/variables.mk

OBJDIR := $(CURDIR)/../gen/$(CLASS)
SRCDIR := $(CURDIR)

$(warning ROOTDIR=$(ROOTDIR))
$(warning CURDIR=$(CURDIR))
$(warning SRCDIR=$(SRCDIR))
$(warning OBJDIR=$(OBJDIR))
$(warning MAKECMDGOALS=$(MAKECMDGOALS))

MAKETARGET = $(MAKE) --no-print-directory -C $@ -f $(CURDIR)/Makefile \
			SRCDIR=$(SRCDIR) $(MAKECMDGOALS)

.PHONY: $(OBJDIR)
$(OBJDIR):
	+[ -d $@ ] || $(MKDIR) -p $@
	+@$(MAKETARGET)

Makefile : ;
%.mk :: ;

% :: $(OBJDIR) ; :

.PHONY: mostlyclean
mostlyclean: clean-gen

.PHONY: clean
clean: clean-gen

.PHONY: distclean
distclean: clean-distgen clean-source

.PHONY: clean-gen
clean-gen:
	-$(RM) -r $(OBJDIR)/

.PHONY: clean-distgen
clean-distgen:
	-$(RM) -r $(CURDIR)/../gen/$(CLASS)/

.PHONY: clean-source
clean-source: ;
