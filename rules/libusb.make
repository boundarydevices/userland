
# -*-makefile-*-
# $Id: libusb.make,v 1.3 2005-11-23 14:49:43 ericn Exp $
#
# Copyright (C) 2003 by Boundary Devices
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef CONFIG_LIBUSB
PACKAGES += libusb
endif

#
# Paths and names
#
LIBUSB_VERSION	= 0.1.8
LIBUSB		= libusb-$(LIBUSB_VERSION)
LIBUSB_SUFFIX		= tar.gz
LIBUSB_URL		= http://easynews.dl.sourceforge.net/sourceforge/libusb/$(LIBUSB).$(LIBUSB_SUFFIX)
LIBUSB_SOURCE		= $(CONFIG_ARCHIVEPATH)/$(LIBUSB).$(LIBUSB_SUFFIX)
LIBUSB_DIR		= $(BUILDDIR)/$(LIBUSB)
LIBUSB_PATCH_URL		= http://boundarydevices.com/libusb-$(LIBUSB_VERSION).patch
LIBUSB_PATCH_SOURCE	= $(CONFIG_ARCHIVEPATH)/libusb-$(LIBUSB_VERSION).patch

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libusb_get: $(STATEDIR)/libusb.get

libusb_get_deps = $(LIBUSB_SOURCE) $(LIBUSB_PATCH_SOURCE)

$(STATEDIR)/libusb.get: $(libusb_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(LIBUSB_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(LIBUSB_URL)

$(LIBUSB_PATCH_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(LIBUSB_PATCH_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libusb_extract: $(STATEDIR)/libusb.extract

libusb_extract_deps = $(STATEDIR)/libusb.get

$(STATEDIR)/libusb.extract: $(libusb_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBUSB_DIR))
	@cd $(BUILDDIR) && zcat $(LIBUSB_SOURCE) | tar -xvf -
	@cd $(BUILDDIR) && patch -p0 < $(LIBUSB_PATCH_SOURCE)
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libusb_prepare: $(STATEDIR)/libusb.prepare

#
# dependencies
#
libusb_prepare_deps = \
	$(STATEDIR)/libusb.extract 

LIBUSB_PATH	=  PATH=$(CROSS_PATH)
LIBUSB_ENV 	=  $(CROSS_ENV)

#
# autoconf
#
LIBUSB_AUTOCONF = \
	--host=$(CONFIG_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR) \
   --enable-shared=no \
   --enable-static=yes \
   --exec-prefix=$(INSTALLPATH) \
   --includedir=$(INSTALLPATH)/include \
   --mandir=$(INSTALLPATH)/man \
   --infodir=$(INSTALLPATH)/info

$(STATEDIR)/libusb.prepare: $(libusb_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBUSB_DIR)/config.cache)
	cd $(LIBUSB_DIR) && \
		$(LIBUSB_PATH) $(LIBUSB_ENV) \
		./configure $(LIBUSB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libusb_compile: $(STATEDIR)/libusb.compile

libusb_compile_deps = $(STATEDIR)/libusb.prepare

$(STATEDIR)/libusb.compile: $(libusb_compile_deps)
	@$(call targetinfo, $@)
	$(LIBUSB_PATH) make -C $(LIBUSB_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libusb_install: $(STATEDIR)/libusb.install

$(STATEDIR)/libusb.install: $(STATEDIR)/libusb.compile
	@$(call targetinfo, $@)
	$(LIBUSB_PATH) make -C $(LIBUSB_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libusb_targetinstall: $(STATEDIR)/libusb.targetinstall

libusb_targetinstall_deps = $(STATEDIR)/libusb.compile

$(STATEDIR)/libusb.targetinstall: $(libusb_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libusb_clean:
	rm -rf $(STATEDIR)/libusb.*
	rm -rf $(LIBUSB_DIR)

# vim: syntax=make
