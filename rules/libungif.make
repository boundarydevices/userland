# -*-makefile-*-
# $Id: libungif.make,v 1.2 2005-11-23 14:49:43 ericn Exp $
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
ifdef CONFIG_LIBUNGIF
PACKAGES += libungif
endif

#
# Paths and names
#
LIBUNGIF_VERSION	= 4.1.0
LIBUNGIF          = libungif-$(LIBUNGIF_VERSION)
LIBUNGIF_SUFFIX	= tar.gz
LIBUNGIF_URL		= http://www.ibiblio.org/pub/Linux/libs/graphics/$(LIBUNGIF).$(LIBUNGIF_SUFFIX)
LIBUNGIF_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(LIBUNGIF).$(LIBUNGIF_SUFFIX)
LIBUNGIF_DIR		= $(BUILDDIR)/$(LIBUNGIF)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libungif_get: $(STATEDIR)/libungif.get

libungif_get_deps = $(LIBUNGIF_SOURCE)

$(STATEDIR)/libungif.get: $(libungif_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(LIBUNGIF_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(LIBUNGIF_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libungif_extract: $(STATEDIR)/libungif.extract

libungif_extract_deps = $(STATEDIR)/libungif.get

$(STATEDIR)/libungif.extract: $(libungif_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBUNGIF_DIR))
	@cd $(BUILDDIR) && zcat $(LIBUNGIF_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libungif_prepare: $(STATEDIR)/libungif.prepare

#
# dependencies
#
libungif_prepare_deps = \
	$(STATEDIR)/libungif.extract 

LIBUNGIF_PATH	=  PATH=$(CROSS_PATH)
LIBUNGIF_ENV 	=  $(CROSS_ENV)
#LIBUNGIF_ENV	+=

#
# autoconf
#
LIBUNGIF_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(CONFIG_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR) \
   --exec-prefix=$(INSTALLPATH) \
   --includedir=$(INSTALLPATH)/include \
   --mandir=$(INSTALLPATH)/man \
   --infodir=$(INSTALLPATH)/info

$(STATEDIR)/libungif.prepare: $(libungif_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBUNGIF_DIR)/config.cache)
	cd $(LIBUNGIF_DIR) && \
		$(LIBUNGIF_PATH) $(LIBUNGIF_ENV) \
		./configure $(LIBUNGIF_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libungif_compile: $(STATEDIR)/libungif.compile

libungif_compile_deps = $(STATEDIR)/libungif.prepare

$(STATEDIR)/libungif.compile: $(libungif_compile_deps)
	@$(call targetinfo, $@)
	$(LIBUNGIF_PATH) make -C $(LIBUNGIF_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libungif_install: $(STATEDIR)/libungif.install

ifdef LIBUNGIF_SHARED
   INSTPOST = echo "Installing shared library"
else
   INSTPOST = echo "NOT Installing shared library" \
      && rm -f $(INSTALLPATH)/lib/libungif.so* \
      && rm -f $(INSTALLPATH)/lib/libungif.la 
endif

$(STATEDIR)/libungif.install: $(STATEDIR)/libungif.compile
	@$(call targetinfo, $@)
	$(LIBUNGIF_PATH) make -C $(LIBUNGIF_DIR) install
	$(INSTPOST)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libungif_targetinstall: $(STATEDIR)/libungif.targetinstall

libungif_targetinstall_deps = $(STATEDIR)/libungif.compile

$(STATEDIR)/libungif.targetinstall: $(libungif_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libungif_clean:
	rm -rf $(STATEDIR)/libungif.*
	rm -rf $(LIBUNGIF_DIR)

# vim: syntax=make
