# -*-makefile-*-
# $Id: dropbear.make,v 1.1 2008-03-30 19:22:45 ericn Exp $
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
ifeq (y, $(CONFIG_DROPBEAR))
PACKAGES += dropbear
endif

#
# Paths and names 
#
DROPBEAR		= dropbear-0.51
DROPBEAR_URL		= http://matt.ucc.asn.au/dropbear/$(DROPBEAR).tar.bz2
DROPBEAR_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(DROPBEAR).tar.bz2
DROPBEAR_DIR		= $(BUILDDIR)/$(DROPBEAR)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dropbear_get: $(STATEDIR)/dropbear.get

$(STATEDIR)/dropbear.get: $(DROPBEAR_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(DROPBEAR_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(DROPBEAR_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dropbear_extract: $(STATEDIR)/dropbear.extract

$(STATEDIR)/dropbear.extract: $(STATEDIR)/dropbear.get
	@$(call targetinfo, $@)
	@$(call clean, $(DROPBEAR_DIR))
	@cd $(BUILDDIR) && bzcat $(DROPBEAR_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dropbear_prepare: $(STATEDIR)/dropbear.prepare

dropbear_prepare_deps = \
	$(STATEDIR)/dropbear.extract

DROPBEAR_PATH = PATH=$(CROSS_PATH)

DROPBEAR_AUTOCONF = \
	--host=$(CONFIG_GNU_HOST) \
   --enable-shared=yes \
   --enable-static=yes \
   --disable-ddcpci \
   --disable-gnome \
   --disable-gnome-applet \
   --disable-xsltproc-check \
   --disable-nls \
   --includedir=$(INSTALLPATH)/include

$(STATEDIR)/dropbear.prepare: $(dropbear_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(DROPBEAR_DIR)/config.cache)
	cd $(DROPBEAR_DIR) && \
		$(DROPBEAR_PATH) \
      $(CROSS_ENV) \
      PATH=$(PATH):$(INSTALLPATH)/usr/local/bin \
		./configure $(DROPBEAR_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dropbear_compile: $(STATEDIR)/dropbear.compile

$(STATEDIR)/dropbear.compile: $(STATEDIR)/dropbear.prepare 
	@$(call targetinfo, $@)
	cd $(DROPBEAR_DIR) && $(DROPBEAR_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dropbear_install: $(STATEDIR)/dropbear.install

$(STATEDIR)/dropbear.install: $(STATEDIR)/dropbear.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(DROPBEAR_DIR) && $(DROPBEAR_PATH) && DESTDIR=$(INSTALLPATH) sudo make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dropbear_targetinstall: $(STATEDIR)/dropbear.targetinstall
dropbear_binaries=$(ROOTDIR)/usr/local/sbin/dropbear $(ROOTDIR)/usr/local/bin/drop* $(ROOTDIR)/usr/local/bin/dbclient
$(STATEDIR)/dropbear.targetinstall: $(STATEDIR)/dropbear.install
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(DROPBEAR_DIR) && $(DROPBEAR_PATH) && DESTDIR=$(ROOTDIR) sudo make install
	sudo chown `whoami` $(ROOTDIR)/usr/local/sbin $(ROOTDIR)/usr/local/bin $(dropbear_binaries)
	$(DROPBEAR_PATH) $(CROSSSTRIP) $(dropbear_binaries)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dropbear_clean: 
	rm -rf $(STATEDIR)/dropbear.* $(DROPBEAR_DIR)

# vim: syntax=make
