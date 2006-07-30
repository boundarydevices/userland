# -*-makefile-*-
# $Id: gtk.make,v 1.1 2006-07-30 15:07:58 ericn Exp $
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
ifeq (y, $(CONFIG_GTK))
PACKAGES += gtk
endif

#
# Paths and names 
#
GTK		= gtk+-2.6.10
GTK_URL 	= ftp://ftp.gtk.org/pub/gtk/v2.6/$(GTK).tar.gz
GTK_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(GTK).tar.gz
GTK_DIR		= $(BUILDDIR)/$(GTK)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gtk_get: $(STATEDIR)/gtk.get

$(STATEDIR)/gtk.get: $(GTK_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(GTK_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(GTK_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gtk_extract: $(STATEDIR)/gtk.extract

$(STATEDIR)/gtk.extract: $(STATEDIR)/gtk.get
	@$(call targetinfo, $@)
	@$(call clean, $(GTK_DIR))
	@cd $(BUILDDIR) && zcat $(GTK_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gtk_prepare: $(STATEDIR)/gtk.prepare $(STATEDIR)/glib.prepare 

gtk_prepare_deps = \
	$(STATEDIR)/gtk.extract \
	$(STATEDIR)/pango.install \
   $(TOPDIR)/$(CONFIG_GNU_TARGET)-pkg-config

GTK_PATH	   =  PATH=$(CROSS_PATH)
GTK_AUTOCONF = --host=$(CONFIG_GNU_TARGET) \
	--prefix=$(INSTALLPATH) \
   --without-libtiff \
   --with-jpeg=$(INSTALLPATH) \
   --with-included-loaders=xpm,png,jpeg \
   --without-libjpeg \
   --without-cairo \
   --x-includes=$(INSTALLPATH)/include \
   --x-libraries=$(INSTALLPATH)/lib 

CONFIG_GTK_SHARED = 1
ifdef CONFIG_GTK_SHARED
   GTK_AUTOCONF 	+=  --enable-shared
else
endif

$(STATEDIR)/gtk.prepare: $(gtk_prepare_deps)
	@$(call targetinfo, $@)
	cd $(GTK_DIR) && \
		$(GTK_PATH) \
      $(CROSS_ENV) \
      ac_cv_func_XOpenDisplay=yes \
      ac_cv_func_XextFindDisplay=yes \
      GDK_PIXBUF_CSOURCE=$(INSTALLPATH)/bin/gdk-pixbuf-csource \
      LD_LIBRARY_PATH=$(INSTALLPATH)/lib:$(LD_LIBRARY_PATH) \
      PKG_CONFIG_PATH=$(INSTALLPATH)/lib/pkgconfig/ \
      PATH=$(INSTALLPATH)/bin:$(PATH) \
      PKG_CONFIG=$(TOPDIR)/$(CONFIG_GNU_TARGET)-pkg-config \
      PKG_CONFIG_PATH=$(INSTALLPATH)/lib/pkgconfig/ \
      CFLAGS=-I$(INSTALLPATH)/include \
      CPPFLAGS=-I$(INSTALLPATH)/include \
      LDFLAGS=-L$(INSTALLPATH)/lib \
		./configure $(GTK_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gtk_compile: $(STATEDIR)/gtk.compile 

$(STATEDIR)/gtk.compile: $(STATEDIR)/gtk.prepare $(STATEDIR)/glib.install 
	@$(call targetinfo, $@)
	cd $(GTK_DIR) && $(GTK_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gtk_install: $(STATEDIR)/gtk.install

$(STATEDIR)/gtk.install: $(STATEDIR)/gtk.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(GTK_DIR) && $(GTK_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gtk_targetinstall: $(STATEDIR)/gtk.targetinstall

$(STATEDIR)/gtk.targetinstall: $(STATEDIR)/gtk.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gtk_clean: 
	rm -rf $(STATEDIR)/gtk.* $(GTK_DIR)

# vim: syntax=make
