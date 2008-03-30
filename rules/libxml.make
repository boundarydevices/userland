# -*-makefile-*-
# $Id: libxml.make,v 1.1 2008-03-30 18:42:19 ericn Exp $
#
# Copyright (C) 2002 by Pengutronix e.K., Hildesheim, Germany
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifeq (y, $(CONFIG_LIBXML))
PACKAGES += libxml
endif

#
# Paths and names 
#
LIBXML			= libxml2-2.6.31
LIBXML_URL 	= ftp://xmlsoft.org/libxml2/$(LIBXML).tar.gz
LIBXML_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(LIBXML).tar.gz
LIBXML_DIR		= $(BUILDDIR)/$(LIBXML)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libxml_get: $(STATEDIR)/libxml.get

$(STATEDIR)/libxml.get: $(LIBXML_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(LIBXML_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget --no-passive-ftp $(LIBXML_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libxml_extract: $(STATEDIR)/libxml.extract

$(STATEDIR)/libxml.extract: $(STATEDIR)/libxml.get
	@$(call targetinfo, $@)
	@$(call clean, $(LIBXML_DIR))
	@cd $(BUILDDIR) && zcat $(LIBXML_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libxml_prepare: $(STATEDIR)/libxml.prepare

libxml_prepare_deps = \
	$(STATEDIR)/libxml.extract

LIBXML_PATH = PATH=$(CROSS_PATH)

LIBXML_AUTOCONF = \
	--host=$(CONFIG_GNU_HOST) \
   --enable-shared=yes \
   --enable-static=yes \
   --disable-sdl \
   --includedir=$(INSTALLPATH)/include

$(STATEDIR)/libxml.prepare: $(libxml_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBXML_DIR)/config.cache)
	cd $(LIBXML_DIR) && \
		$(LIBXML_PATH) \
      $(CROSS_ENV) \
		./configure $(LIBXML_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libxml_compile: $(STATEDIR)/libxml.compile

$(STATEDIR)/libxml.compile: $(STATEDIR)/libxml.prepare 
	@$(call targetinfo, $@)
	cd $(LIBXML_DIR) && $(LIBXML_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libxml_install: $(STATEDIR)/libxml.install

$(STATEDIR)/libxml.install: $(STATEDIR)/libxml.compile
	@$(call targetinfo, $@)
	# install -d $(INSTALLPATH)/include
	cd $(LIBXML_DIR) && $(LIBXML_PATH) && make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libxml_targetinstall: $(STATEDIR)/libxml.targetinstall

$(STATEDIR)/libxml.targetinstall: $(STATEDIR)/libxml.install
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(LIBXML_DIR) && $(LIBXML_PATH) && DESTDIR=$(ROOTDIR) make install-strip
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libxml_clean: 
	rm -rf $(STATEDIR)/libxml.* $(LIBXML_DIR)

# vim: syntax=make
