# -*-makefile-*-
# $Id: cairo.make,v 1.2 2005-06-18 17:03:09 ericn Exp $
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
ifeq (y, $(CONFIG_CAIRO))
PACKAGES += zlib
endif

#
# Paths and names 
#
CAIRO = cairo-0.5.0
CAIRO_URL = http://cairographics.org/snapshots/$(CAIRO).tar.gz
CAIRO_SOURCE = $(CONFIG_ARCHIVEPATH)/$(CAIRO).tar.gz
CAIRO_DIR = $(BUILDDIR)/$(CAIRO)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

cairo_get: $(STATEDIR)/cairo.get

$(STATEDIR)/cairo.get: $(CAIRO_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(CAIRO_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(CAIRO_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

cairo_extract: $(STATEDIR)/cairo.extract

$(STATEDIR)/cairo.extract: $(STATEDIR)/cairo.get
	@$(call targetinfo, $@)
	@$(call clean, $(CAIRO_DIR))
	@cd $(BUILDDIR) && gzcat $(CAIRO_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

cairo_prepare: $(STATEDIR)/cairo.prepare

cairo_prepare_deps = \
	$(STATEDIR)/cairo.extract

CAIRO_PATH	=  PATH=$(CROSS_PATH)
CAIRO_AUTOCONF = --host=$(CONFIG_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

ifdef CONFIG_CAIRO_SHARED
   CAIRO_AUTOCONF 	+=  --enable-shared=yes
else
   CAIRO_AUTOCONF 	+=  --enable-shared=no
   CAIRO_AUTOCONF 	+=  --enable-static=yes
endif

CAIRO_AUTOCONF += --without-x

$(STATEDIR)/cairo.prepare: $(cairo_prepare_deps)
	@$(call targetinfo, $@)
	cd $(CAIRO_DIR) && \
		$(CAIRO_PATH) \
      $(CROSS_ENV) \
      ./configure $(CAIRO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

cairo_compile: $(STATEDIR)/cairo.compile

$(STATEDIR)/cairo.compile: $(STATEDIR)/cairo.prepare 
	@$(call targetinfo, $@)
	cd $(CAIRO_DIR) && $(CAIRO_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

cairo_install: $(STATEDIR)/cairo.install

$(STATEDIR)/cairo.install: $(STATEDIR)/cairo.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(CAIRO_DIR) && $(CAIRO_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

cairo_targetinstall: $(STATEDIR)/cairo.targetinstall

$(STATEDIR)/cairo.targetinstall: $(STATEDIR)/cairo.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

cairo_clean: 
	rm -rf $(STATEDIR)/cairo.* $(CAIRO_DIR)

# vim: syntax=make
