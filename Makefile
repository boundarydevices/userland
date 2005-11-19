#
# Makefile
#
# This directory and makefile will produce a root filesystem for
# input to the creation of a flash image.
# 
# History:
# $Log: Makefile,v $
# Revision 1.17  2005-11-19 13:17:12  ericn
# -keep flat, unzipped initrd
#
# Revision 1.16  2005/11/07 13:08:43  ericn
# -fix dependency order for .bbconfig
#
# Revision 1.15  2005/08/24 03:29:01  ericn
# -parse Busybox config file
#
# Revision 1.14  2005/07/23 17:09:06  ericn
# -add u-boot initrd
#
# Revision 1.13  2005/06/27 03:56:55  ericn
# -added mmcinitrd target
#
# Revision 1.12  2005/06/19 00:32:21  ericn
# -create ./arm-linux-pkg-config
#
# Revision 1.11  2004/06/26 14:21:19  ericn
# -removed unused symbols
#
# Revision 1.10  2004/06/20 19:29:14  ericn
# -fixed directory dependencies
#
# Revision 1.9  2004/06/19 23:31:44  ericn
# -can't strip all libs (ld-linux.so chokes)
#
# Revision 1.8  2004/06/18 14:44:24  ericn
# -strip before mkfs
#
# Revision 1.7  2004/06/18 04:16:51  ericn
# -add cramfs, jffs2 targets
#
# Revision 1.6  2004/06/06 17:56:27  ericn
# -added cramfs, jffs2 targets
#
# Revision 1.5  2004/06/06 14:57:40  ericn
# -added targetinstall, 1st pass
#
#
#
.PHONY: clean dist-clean config menuconfig userlandconfig userland rootfs

TOPDIR			   := $(shell pwd)
BASENAME		      := $(shell basename $(TOPDIR))
BUILDDIR		      := $(TOPDIR)/build
STATEDIR		      := $(TOPDIR)/state
CONFIG_GNU_TARGET ?= arm-linux
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
CROSSSTRIP        := $(CONFIG_GNU_TARGET)-strip
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

export TAR TOPDIR BUILDDIR SRCDIR STATEDIR PACKAGES CONFIG_GNU_TARGET 

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

$(TOPDIR)/$(CONFIG_GNU_TARGET)-pkg-config:
	mkdir -p $(INSTALLPATH)/lib/pkgconfig
	echo -e "#!/bin/sh\nPKG_CONFIG_PATH=$(INSTALLPATH)/lib/pkgconfig pkg-config \044@\n" >$@
	chmod 755 $@

export ROOTDIR INSTALLPATH CONFIG_ARCH CONFIG_KERNELPATH CONFIG_TOOLCHAINPATH CROSS_LIB_DIR

PACKAGES_CLEAN			   := $(addsuffix _clean,$(PACKAGES))
PACKAGES_GET			   := $(addsuffix _get,$(PACKAGES))
PACKAGES_EXTRACT		   := $(addsuffix _extract,$(PACKAGES))
PACKAGES_PREPARE		   := $(addsuffix _prepare,$(PACKAGES))
PACKAGES_COMPILE		   := $(addsuffix _compile,$(PACKAGES))
PACKAGES_INSTALL		   := $(addsuffix _install,$(PACKAGES))
PACKAGES_TARGETINSTALL  := $(addsuffix _targetinstall,$(PACKAGES))
CROSS_PATH              := $(CONFIG_TOOLCHAINPATH)/bin:$$PATH

INSTALL_DIRS := $(INSTALLPATH) $(INSTALLPATH)/bin $(INSTALLPATH)/lib $(INSTALLPATH)/sbin $(INSTALLPATH)/include

DIRS := $(BUILDDIR) $(STATEDIR) $(ROOTDIR) $(INSTALL_DIRS)

$(DIRS):
	mkdir -p $@

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

ifdef CONFIG_KERNELPATH
.kernelconfig: $(CONFIG_KERNELPATH)/.config
	cat $(CONFIG_KERNELPATH)/.config | sed 's/^CONFIG_/KERNEL_/' > $@
else
.kernelconfig: 
	touch -t 197001010000 $@
endif

ifdef CONFIG_BUSYBOX
.bbconfig: $(STATEDIR)/busybox.extract
	cat $(BUSYBOX_DIR)/.config | sed 's/^CONFIG_/BUSYBOX_/' > $@
else
.bbconfig: 
	touch -t 197001010000 $@
endif

menuconfig config .config: userland.in .kernelconfig kconf/kconfig/mconf 
	./kconf/kconfig/mconf userland.in

userland: .config
	make -f userland.mak all

devices.txt: .config .kernelconfig
	make -f devices.mak all

devices:
	make -f devices.mak all

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
	@echo "  make install                 Install to temporary installation directory"
	@echo "  make targetinstall           Install packages to target root directory"
	@echo "  make rootfs                  Build complete root filesystem"
	@echo "  make cramfs                  Make cramfs image from target root"
	@echo "  make jffs2                   Make JFFS2 image from target root"
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
get: $(DIRS) $(PACKAGES_GET)
extract: get     $(DIRS) $(PACKAGES_EXTRACT)
prepare: extract $(DIRS) $(PACKAGES_PREPARE)
compile: prepare $(DIRS) $(PACKAGES_COMPILE)
install: compile $(DIRS)  $(PACKAGES_INSTALL)
targetinstall: install $(DIRS) $(PACKAGES_TARGETINSTALL)


$(ROOTDIR)/etc/init.d/rcS: targetinstall
	mkdir -p $(ROOTDIR)/etc/init.d/
	make -f rootfs.mak all

rootfs: $(ROOTDIR) .bbconfig targetinstall devices.txt $(ROOTDIR)/etc/init.d/rcS 

cramfs.img: targetinstall $(BUILDDIR)/cramfs-1.1/mkcramfs rootfs devices
#	-$(CROSSSTRIP) $(ROOTDIR)/lib/*
#	-$(CROSSSTRIP) $(ROOTDIR)/bin/*
	cd $(ROOTDIR)/etc && /sbin/ldconfig -r ../ -v
	$(BUILDDIR)/cramfs-1.1/mkcramfs -q -D devices.txt $(ROOTDIR) $@
cramfs: cramfs.img
	echo "cramfs image built"


jffs2.img: rootfs devices
#	-$(CROSSSTRIP) $(ROOTDIR)/lib/*
	-$(CROSSSTRIP) $(ROOTDIR)/bin/*
	mkfs.jffs2 -l -q -v --devtable=devices.txt --root=$(ROOTDIR) -o $@

jffs2: jffs2.img
	echo "JFFS2 image built"

-include mmcinitrd.mak

mmcinitrd.gz: $(STATEDIR)/mmcinitrd.built
	genext2fs mmcinitrd.img -d mmc.initrd -U -D devices.txt -b 8192
	gzip -f -v9 mmcinitrd.img -c >$@

mmcinitrd.u-boot: mmcinitrd.gz
	mkimage -A arm -O linux -T ramdisk -n "Initial Ram Disk" -d mmcinitrd.gz mmcinitrd.u-boot


