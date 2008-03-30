# -*-makefile-*-
# $Id: ddcontrol.make,v 1.1 2008-03-30 18:42:19 ericn Exp $
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
ifeq (y, $(CONFIG_DDCONTROL))
PACKAGES += ddcontrol
endif

#
# Paths and names 
#
DDCONTROL		= ddccontrol-0.4.2
DDCONTROL_URL		= http://superb-west.dl.sourceforge.net/sourceforge/ddccontrol/$(DDCONTROL).tar.bz2
DDCONTROL_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(DDCONTROL).tar.bz2
DDCONTROL_DIR		= $(BUILDDIR)/$(DDCONTROL)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ddcontrol_get: $(STATEDIR)/ddcontrol.get

$(STATEDIR)/ddcontrol.get: $(DDCONTROL_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(DDCONTROL_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(DDCONTROL_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ddcontrol_extract: $(STATEDIR)/ddcontrol.extract

$(STATEDIR)/ddcontrol.extract: $(STATEDIR)/ddcontrol.get
	@$(call targetinfo, $@)
	@$(call clean, $(DDCONTROL_DIR))
	@cd $(BUILDDIR) && bzcat $(DDCONTROL_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ddcontrol_prepare: $(STATEDIR)/ddcontrol.prepare

ddcontrol_prepare_deps = \
	$(STATEDIR)/ddcontrol.extract

DDCONTROL_PATH = PATH=$(CROSS_PATH)

DDCONTROL_AUTOCONF = \
	--host=$(CONFIG_GNU_HOST) \
   --enable-shared=yes \
   --enable-static=yes \
   --disable-ddcpci \
   --disable-gnome \
   --disable-gnome-applet \
   --disable-xsltproc-check \
   --disable-nls \
   --includedir=$(INSTALLPATH)/include

$(STATEDIR)/ddcontrol.prepare: $(ddcontrol_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DDCONTROL_DIR)/config.cache)
	cd $(DDCONTROL_DIR) && \
		$(DDCONTROL_PATH) \
      $(CROSS_ENV) \
      PATH=$(PATH):$(INSTALLPATH)/usr/local/bin \
		./configure $(DDCONTROL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ddcontrol_compile: $(STATEDIR)/ddcontrol.compile

$(STATEDIR)/ddcontrol.compile: $(STATEDIR)/ddcontrol.prepare 
	@$(call targetinfo, $@)
	cd $(DDCONTROL_DIR) && $(DDCONTROL_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ddcontrol_install: $(STATEDIR)/ddcontrol.install

$(STATEDIR)/ddcontrol.install: $(STATEDIR)/ddcontrol.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(DDCONTROL_DIR) && $(DDCONTROL_PATH) && DESTDIR=$(INSTALLPATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ddcontrol_targetinstall: $(STATEDIR)/ddcontrol.targetinstall

$(STATEDIR)/ddcontrol.targetinstall: $(STATEDIR)/ddcontrol.install
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(DDCONTROL_DIR) && $(DDCONTROL_PATH) && DESTDIR=$(ROOTDIR) make install-strip
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ddcontrol_clean: 
	rm -rf $(STATEDIR)/ddcontrol.* $(DDCONTROL_DIR)

# vim: syntax=make
