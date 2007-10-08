# -*-makefile-*-
# $Id: glib.make,v 1.9 2007-10-08 21:06:10 ericn Exp $
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
ifeq (y, $(CONFIG_GLIB))
PACKAGES += glib
endif

#
# Paths and names 
#
GLIB		= glib-2.8.6
GLIB_URL 	= ftp://ftp.gtk.org/pub/gtk/v2.8/$(GLIB).tar.gz
GLIB_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(GLIB).tar.gz
GLIB_DIR        = $(BUILDDIR)/$(GLIB)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

glib_get: $(STATEDIR)/glib.get

$(STATEDIR)/glib.get: $(GLIB_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(GLIB_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(GLIB_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

glib_extract: $(STATEDIR)/glib.extract

$(STATEDIR)/glib.extract: $(STATEDIR)/glib.get
	@$(call targetinfo, $@)
	@$(call clean, $(GLIB_DIR))
	@cd $(BUILDDIR) && zcat $(GLIB_SOURCE) | tar -xvf -
	sed 's/#include "glib.h"/#include "bits\/posix1_lim.h"\n#include "glib.h"/' \
	< $(GLIB_DIR)/glib/giounix.c \
	> $(GLIB_DIR)/glib/giounix.c.patched
	cp $(GLIB_DIR)/glib/giounix.c $(GLIB_DIR)/glib/giounix.c.orig
	cp $(GLIB_DIR)/glib/giounix.c.patched $(GLIB_DIR)/glib/giounix.c
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

glib_prepare: $(STATEDIR)/glib.prepare

glib_prepare_deps = \
	$(STATEDIR)/glib.extract

GLIB_PATH	  =  PATH=$(CROSS_PATH)
GLIB_AUTOCONF = --host=$(CONFIG_GNU_HOST) \
                --prefix=$(INSTALLPATH) \
                --cache-file=$(GLIB_DIR)/$(CONFIG_GNU_TARGET).cache

ifdef CONFIG_GLIB_SHARED
   GLIB_AUTOCONF 	+=  --shared
else
endif

$(STATEDIR)/glib.prepare: $(glib_prepare_deps)
	@$(call targetinfo, $@)
	cp $(TOPDIR)/rules/$(CONFIG_GNU_TARGET).cache $(GLIB_DIR)/$(CONFIG_GNU_TARGET).cache
	cd $(GLIB_DIR) && \
		$(GLIB_PATH) \
		$(CROSS_ENV) \
		./configure $(GLIB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

glib_compile: $(STATEDIR)/glib.compile

$(STATEDIR)/glib.compile: $(STATEDIR)/glib.prepare 
	@$(call targetinfo, $@)
	cd $(GLIB_DIR) && $(GLIB_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

glib_install: $(STATEDIR)/glib.install

$(STATEDIR)/glib.install: $(STATEDIR)/glib.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(GLIB_DIR) && $(GLIB_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

glib_targetinstall: $(STATEDIR)/glib.targetinstall

$(STATEDIR)/glib.targetinstall: $(STATEDIR)/glib.install
	@$(call targetinfo, $@)
	touch $@


# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

glib_clean: 
	rm -rf $(STATEDIR)/glib.* $(GLIB_DIR)

# vim: syntax=make
