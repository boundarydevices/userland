# -*-makefile-*-
# $Id: gstreamer.make,v 1.4 2007-10-08 21:06:10 ericn Exp $
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
ifeq (y, $(CONFIG_GSTREAMER))
PACKAGES += gstreamer
endif

#
# Paths and names 
#
GSTREAMER	        = gstreamer-0.10.4
GSTREAMER_URL 	        = http://gstreamer.freedesktop.org/src/gstreamer/$(GSTREAMER).tar.gz
GSTREAMER_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(GSTREAMER).tar.gz
GSTREAMER_DIR		= $(BUILDDIR)/$(GSTREAMER)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gstreamer_get: $(STATEDIR)/gstreamer.get

$(STATEDIR)/gstreamer.get: $(GSTREAMER_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(GSTREAMER_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(GSTREAMER_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gstreamer_extract: $(STATEDIR)/gstreamer.extract

$(STATEDIR)/gstreamer.extract: $(STATEDIR)/gstreamer.get
	@$(call targetinfo, $@)
	@$(call clean, $(GSTREAMER_DIR))
	@cd $(BUILDDIR) && zcat $(GSTREAMER_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gstreamer_prepare: $(STATEDIR)/gstreamer.prepare

gstreamer_prepare_deps = \
	$(STATEDIR)/gstreamer.extract

GSTREAMER_PATH	  =  PATH=$(CROSS_PATH)
GSTREAMER_AUTOCONF = --host=$(CONFIG_GNU_HOST) \
                --prefix=$(INSTALLPATH) \
                --without-libxml2 \
                --cache-file=$(GSTREAMER_DIR)/$(CONFIG_GNU_TARGET).cache

ifdef CONFIG_GSTREAMER_SHARED
   GSTREAMER_AUTOCONF 	+=  --shared
else
endif

$(STATEDIR)/gstreamer.prepare: $(gstreamer_prepare_deps)
	@$(call targetinfo, $@)
	cp $(TOPDIR)/rules/$(CONFIG_GNU_TARGET).cache $(GSTREAMER_DIR)/$(CONFIG_GNU_TARGET).cache
	cd $(GSTREAMER_DIR) && \
		$(GSTREAMER_PATH) \
		$(CROSS_ENV) \
		./configure $(GSTREAMER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gstreamer_compile: $(STATEDIR)/gstreamer.compile

$(STATEDIR)/gstreamer.compile: $(STATEDIR)/gstreamer.prepare 
	@$(call targetinfo, $@)
	cd $(GSTREAMER_DIR) && $(GSTREAMER_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gstreamer_install: $(STATEDIR)/gstreamer.install

$(STATEDIR)/gstreamer.install: $(STATEDIR)/gstreamer.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(GSTREAMER_DIR) && $(GSTREAMER_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gstreamer_targetinstall: $(STATEDIR)/gstreamer.targetinstall

$(STATEDIR)/gstreamer.targetinstall: $(STATEDIR)/gstreamer.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gstreamer_clean: 
	rm -rf $(STATEDIR)/gstreamer.* $(GSTREAMER_DIR)

# vim: syntax=make
