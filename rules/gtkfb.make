# -*-makefile-*-
# $Id: gtkfb.make,v 1.4 2007-10-08 21:06:10 ericn Exp $
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
ifeq (y, $(CONFIG_GTKFB))
PACKAGES += gtkfb
endif

#
# Paths and names 
#
GTKFB			= gtk+-2.6.8
GTKFB_URL 	= ftp://ftp.gtk.org/pub/gtk/v2.6/$(GTKFB).tar.gz
GTKFB_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(GTKFB).tar.gz
GTKFB_DIR		= $(BUILDDIR)/$(GTKFB)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gtkfb_get: $(STATEDIR)/gtkfb.get

$(STATEDIR)/gtkfb.get: $(GTKFB_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(GTKFB_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(GTKFB_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gtkfb_extract: $(STATEDIR)/gtkfb.extract

$(STATEDIR)/gtkfb.extract: $(STATEDIR)/gtkfb.get
	@$(call targetinfo, $@)
	@$(call clean, $(GTKFB_DIR))
	@cd $(BUILDDIR) && zcat $(GTKFB_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gtkfb_prepare: $(STATEDIR)/gtkfb.prepare $(STATEDIR)/glib.prepare 

gtkfb_prepare_deps = \
	$(STATEDIR)/gtkfb.extract \
	$(STATEDIR)/pango.install \
   $(TOPDIR)/$(CONFIG_GNU_TARGET)-pkg-config

GTKFB_PATH	   =  PATH=$(CROSS_PATH)
GTKFB_AUTOCONF = --host=$(CONFIG_GNU_HOST) \
	--prefix=$(INSTALLPATH) \
   --without-libtiff \
   --with-gdktarget=linux-fb  \
   --disable-shadowfb \
   --disable-modules \
   --with-jpeg=$(INSTALLPATH) \
   --with-included-loaders=xpm,png,jpeg \
   --without-x \
   --without-libjpeg

ifdef CONFIG_GTKFB_SHARED
   GTKFB_AUTOCONF 	+=  --shared
else
endif

$(STATEDIR)/gtkfb.prepare: $(gtkfb_prepare_deps)
	@$(call targetinfo, $@)
	cd $(GTKFB_DIR) && \
		$(GTKFB_PATH) \
      $(CROSS_ENV) \
      PKG_CONFIG_PATH=$(INSTALLPATH)/lib/pkgconfig/ \
      PATH=$(INSTALLPATH)/bin:$(PATH) \
      PKG_CONFIG=$(TOPDIR)/$(CONFIG_GNU_TARGET)-pkg-config \
      PKG_CONFIG_PATH=$(INSTALLPATH)/lib/pkgconfig/ \
		./configure $(GTKFB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gtkfb_compile: $(STATEDIR)/gtkfb.compile 

$(STATEDIR)/gtkfb.compile: $(STATEDIR)/gtkfb.prepare $(STATEDIR)/glib.install 
	@$(call targetinfo, $@)
	cd $(GTKFB_DIR) && $(GTKFB_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gtkfb_install: $(STATEDIR)/gtkfb.install

$(STATEDIR)/gtkfb.install: $(STATEDIR)/gtkfb.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(GTKFB_DIR) && $(GTKFB_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gtkfb_targetinstall: $(STATEDIR)/gtkfb.targetinstall

$(STATEDIR)/gtkfb.targetinstall: $(STATEDIR)/gtkfb.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gtkfb_clean: 
	rm -rf $(STATEDIR)/gtkfb.* $(GTKFB_DIR)

# vim: syntax=make
