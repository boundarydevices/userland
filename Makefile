.PHONY: clean dist-clean config menuconfig userlandconfig userland

TOPDIR			   := $(shell pwd)
BASENAME		      := $(shell basename $(TOPDIR))
BUILDDIR		      := $(TOPDIR)/build
XCHAIN_BUILDDIR	:= $(BUILDDIR)/xchain
NATIVE_BUILDDIR	:= $(BUILDDIR)/native
PATCHES_BUILDDIR	:= $(BUILDDIR)/patches
PATCHDIR		      := $(TOPDIR)/patches
STATEDIR		      := $(TOPDIR)/state
BOOTDISKDIR		   := $(TOPDIR)/bootdisk
MISCDIR			   := $(TOPDIR)/misc
CONFIG_GNU_TARGET := arm-linux
GNU_HOST          := $(CONFIG_GNU_TARGET)
DEP_OUTPUT = depend.out
WGET := wget
HOSTCC := gcc

#
# crossenvironment
#
CROSS_ENV_AR		= AR=$(CONFIG_GNU_TARGET)-ar
CROSS_ENV_AS		= AS=$(CONFIG_GNU_TARGET)-as
CROSS_ENV_LD		= LD=$(CONFIG_GNU_TARGET)-ld
CROSS_ENV_NM		= NM=$(CONFIG_GNU_TARGET)-nm
CROSS_ENV_CC		= CC=$(CONFIG_GNU_TARGET)-gcc
CROSS_ENV_CXX		= CXX=$(CONFIG_GNU_TARGET)-g++
CROSS_ENV_OBJCOPY	= OBJCOPY=$(CONFIG_GNU_TARGET)-objcopy
CROSS_ENV_OBJDUMP	= OBJDUMP=$(CONFIG_GNU_TARGET)-objdump
CROSS_ENV_RANLIB	= RANLIB=$(CONFIG_GNU_TARGET)-ranlib
CROSS_ENV_STRIP		= STRIP=$(CONFIG_GNU_TARGET)-strip
ifneq ('','$(strip $(subst ",,$(TARGET_CFLAGS)))')
CROSS_ENV_CFLAGS	= CFLAGS='$(strip $(subst ",,$(TARGET_CFLAGS)))'
endif
ifneq ('','$(strip $(subst ",,$(TARGET_CXXFLAGS)))')
CROSS_ENV_CXXFLAGS	= CXXFLAGS='$(strip $(subst ",,$(TARGET_CXXFLAGS)))'
endif
ifneq ('','$(strip $(subst ",,$(TARGET_CPPFLAGS)))')
CROSS_ENV_CPPFLAGS	= CPPFLAGS='$(strip $(subst ",,$(TARGET_CPPFLAGS)))'
endif
ifneq ('','$(strip $(subst ",,$(TARGET_LDFLAGS)))')
CROSS_ENV_LDFLAGS	= LDFLAGS='$(strip $(subst ",,$(TARGET_LDFLAGS)))'
endif

CROSS_ENV := \
	$(CROSS_ENV_AR) \
	$(CROSS_ENV_AS) \
	$(CROSS_ENV_CXX) \
	$(CROSS_ENV_CC) \
	$(CROSS_ENV_LD) \
	$(CROSS_ENV_NM) \
	$(CROSS_ENV_OBJCOPY) \
	$(CROSS_ENV_OBJDUMP) \
	$(CROSS_ENV_RANLIB) \
	$(CROSS_ENV_STRIP) \
	$(CROSS_ENV_CFLAGS) \
	$(CROSS_ENV_CPPFLAGS) \
	$(CROSS_ENV_LDFLAGS) \
	$(CROSS_ENV_CXXFLAGS) \
	ac_cv_func_getpgrp_void=yes \
	ac_cv_func_setpgrp_void=yes \
	ac_cv_sizeof_long_long=8 \
	ac_cv_func_memcmp_clean=yes \
	ac_cv_func_setvbuf_reversed=no \
	ac_cv_func_getrlimit=yes

export TAR TOPDIR BUILDDIR ROOTDIR SRCDIR STATEDIR PACKAGES CONFIG_GNU_TARGET 

-include .config 

include rules.mak

include $(wildcard rules/*.make)

export PACKAGES

INSTALLPATH=$(subst ",,$(CONFIG_INSTALLPATH))
ifeq ("", $(CONFIG_INSTALLPATH))
   INSTALLPATH=$(TOPDIR)/install
else   
ifndef CONFIG_INSTALLPATH
   INSTALLPATH=$(TOPDIR)/install
endif
endif

ROOTDIR=$(subst ",,$(CONFIG_ROOT))
ifeq ("", $(CONFIG_ROOT))
   ROOTDIR=$(TOPDIR)/root
else
ifndef CONFIG_ROOT
   ROOTDIR=$(TOPDIR)/root
endif
endif

CONFIG_KERNELPATH := $(subst ",,$(CONFIG_KERNELPATH))
CONFIG_ARCH :=$(subst ",,$(CONFIG_ARCH))
CONFIG_TOOLCHAINPATH := $(subst ",,$(CONFIG_TOOLCHAINPATH))
CROSS_LIB_DIR := $(subst ",,$(CONFIG_TOOLCHAINPATH)/$(CONFIG_GNU_TARGET))


export ROOTDIR INSTALLPATH CONFIG_ARCH CONFIG_KERNELPATH CONFIG_TOOLCHAINPATH CROSS_LIB_DIR

PACKAGES_CLEAN			:= $(addsuffix _clean,$(PACKAGES))
PACKAGES_GET			:= $(addsuffix _get,$(PACKAGES))
PACKAGES_EXTRACT		:= $(addsuffix _extract,$(PACKAGES))
PACKAGES_PREPARE		:= $(addsuffix _prepare,$(PACKAGES))
PACKAGES_COMPILE		:= $(addsuffix _compile,$(PACKAGES))
CROSS_PATH           := $(CONFIG_TOOLCHAINPATH)/bin:$$PATH

$(BUILDDIR):
	mkdir -p $(BUILDDIR)
$(STATEDIR):
	mkdir -p $(STATEDIR)


kconf.mak:
	@echo -------------- How did you get this directory? We\'re missing $@
	exit 1
rules.mak:
	@echo -------------- How did you get this directory? We\'re missing $@
	exit 1
userland.in:
	@echo -------------- How did you get this directory? We\'re missing $@
	exit 1

kconf/kconfig/mconf: kconf.mak
	make -f $< all

menuconfig config .config: userland.in kconf/kconfig/mconf
	./kconf/kconfig/mconf userland.in

userland: .config
	make -f userland.mak all

all: help

clean:
	@echo "Cleaning up..."
	@rm -f .config

distclean:
	@echo "Cleaning up everything..."
	@rm -f .config

help:
# help message {{{
	@echo
	@echo "PTXdist - Pengutronix Distribution Build System"
	@echo
	@echo "Syntax:"
	@echo
	@echo "  make menuconfig              Configure the whole system"
	@echo
	@echo "  make get                     Download (most) of the needed packets"
	@echo "  make extract                 Extract all needed archives"
	@echo "  make prepare                 Prepare the configured system for compilation"
	@echo "  make compile                 Compile the packages"
	@echo "  make install                 Install to rootdirectory"
	@echo "  make clean                   Remove everything but local/"
	@echo "  make rootclean               Remove root directory contents"
	@echo "  make distclean               Clean everything"
	@echo "  make world                   Make-everything-and-be-happy"
	@echo
	@echo "Some 'helpful' targets:"
	@echo "  make configs                 show predefined configs"
	@echo
	@echo "Calling these targets affects the whole system. If you want to"
	@echo "do something for a packet do 'make packet_<action>'."
	@echo
	@echo "Available packages and versions:"
	@echo " $(PACKAGES)"
	@echo
	@echo
# }}}

clean: $(BUILDDIR) $(STATEDIR) $(PACKAGES_CLEAN)
get: $(BUILDDIR) $(STATEDIR) $(PACKAGES_GET)
extract: get $(BUILDDIR) $(STATEDIR) $(PACKAGES_EXTRACT)
prepare: extract $(BUILDDIR) $(STATEDIR) $(PACKAGES_PREPARE)
compile: extract $(BUILDDIR) $(STATEDIR) $(PACKAGES_COMPILE)

