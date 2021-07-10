PKGNAME = alt-az-tracker

ifndef ROOTDIR
ROOTDIR := $(CURDIR)
export ROOTDIR
endif

ifndef TARGET_ARCH_TYPE
TARGET_ARCH_TYPE := xyz
export TARGET_ARCH_TYPE
endif
ifndef VERSION
VERSION := $(shell cat $(ROOTDIR)/VERSION)
export VERSION
endif

TAR = tar
MKDIR = mkdir
INSTALL = install
WGET=wget
WGET_OPT= --quiet --compression=auto
CONVERT=convert
FIND=find
CP=cp
CHMOD=chmod

DESTDIR =
prefix = /usr/local
exec_prefix = $(prefix)
bindir = $(exec_prefix)/bin
sbindir = $(exec_prefix)/sbin
libexecdir = $(exec_prefix)/libexec
datarootdir = $(prefix)/share
datadir = $(datarootdir)
sysconfdir = $(prefix)/etc
sharedstatedir = $(prefix)/com
localstatedir = $(prefix)/var
runstatedir = $(localstatedir)/run
includedir = $(prefix)/include
docdir = $(datarootdir)/doc/$(PKGNAME)
infodir = $(datarootdir)/info
libdir = $(exec_prefix)/lib
mandir = $(datarootdir)/man


DEFAULT_LATITUDE ?= "43.761463"
DEFAULT_LONGITUDE ?= "-90.490470"
# 43.761463,-90.490470 - The South Ridge cemetary
# 45.000000,-90.000000 - Near Wausau
# 45.035423,-87.885620 - Mom & Dad's in Grover
# 44.074288,-92.557447 - My house in Rochester
# 43.764016,-90.478865 - Pasch Farm
# 43.750741,-90.449193 - Kaus Farm





$(warning PKGNAME=$(PKGNAME))
$(warning VERSION=$(VERSION))
$(warning TARGET_ARCH_TYPE=$(TARGET_ARCH_TYPE))

$(warning DESTDIR=$(DESTDIR))
$(warning prefix=$(prefix))
