# -*-makefile-*-
# $Id: pango.make,v 1.6 2006-01-10 04:37:22 ericn Exp $
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
ifeq (y, $(CONFIG_PANGO))
PACKAGES += pango
endif

#
# Paths and names 
#
PANGO			= pango-1.8.1
PANGO_URL 	= ftp://ftp.gtk.org/pub/gtk/v2.6/$(PANGO).tar.gz
PANGO_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(PANGO).tar.gz
PANGO_DIR		= $(BUILDDIR)/$(PANGO)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

pango_get: $(STATEDIR)/pango.get

$(STATEDIR)/pango.get: $(PANGO_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(PANGO_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(PANGO_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

pango_extract: $(STATEDIR)/pango.extract

$(STATEDIR)/pango.extract: $(STATEDIR)/pango.get
	@$(call targetinfo, $@)
	@$(call clean, $(PANGO_DIR))
	@cd $(BUILDDIR) && zcat $(PANGO_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

pango_prepare: $(STATEDIR)/pango.prepare $(STATEDIR)/glib.prepare 

pango_prepare_deps = \
	$(STATEDIR)/pango.extract \
   $(TOPDIR)/$(CONFIG_GNU_TARGET)-pkg-config

PANGO_PATH	   =  PATH=$(CROSS_PATH)
PANGO_AUTOCONF = --host=$(CONFIG_GNU_TARGET) \
	--prefix=$(INSTALLPATH) \
   --without-libtiff \
   --with-gdktarget=linux-fb  \
   --disable-shadowfb \
   --disable-modules \
   --with-included-loaders=xpm,png,jpeg \
   --without-x

ifdef CONFIG_PANGO_SHARED
   PANGO_AUTOCONF 	+=  --shared
else
endif

$(STATEDIR)/pango.prepare: $(pango_prepare_deps)
	@$(call targetinfo, $@)
	cd $(PANGO_DIR) && \
		$(PANGO_PATH) \
      $(CROSS_ENV) \
      PKG_CONFIG_PATH=$(INSTALLPATH)/lib/pkgconfig/ \
      PATH=$(INSTALLPATH)/bin:$(PATH) \
      PKG_CONFIG=$(TOPDIR)/$(CONFIG_GNU_TARGET)-pkg-config \
      PKG_CONFIG_PATH=$(INSTALLPATH)/lib/pkgconfig/ \
		./configure $(PANGO_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

pango_compile: $(STATEDIR)/pango.compile $(STATEDIR)/fontconfig.install

$(STATEDIR)/pango.compile: $(STATEDIR)/pango.prepare $(STATEDIR)/glib.install $(INSTALLPATH)/lib/libdl.a
	@$(call targetinfo, $@)
	cd $(PANGO_DIR) && $(PANGO_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

pango_install: $(STATEDIR)/pango.install

$(STATEDIR)/pango.install: $(STATEDIR)/pango.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(PANGO_DIR) && $(PANGO_PATH) make install
	perl -pi -e's/-lpango/-lexpat -lpango/' $(INSTALLPATH)/lib/pkgconfig/pango.pc
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

pango_targetinstall: $(STATEDIR)/pango.targetinstall

$(STATEDIR)/pango.targetinstall: $(STATEDIR)/pango.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

pango_clean: 
	rm -rf $(STATEDIR)/pango.* $(PANGO_DIR)

# vim: syntax=make
