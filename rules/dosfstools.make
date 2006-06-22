# -*-makefile-*-
# $Id: dosfstools.make,v 1.1 2006-06-22 13:46:09 ericn Exp $
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
ifeq (y, $(CONFIG_DOSFSTOOLS))
PACKAGES += dosfstools
endif

#
# Paths and names 
#
DOSFSTOOLS_VER    = 2.11
DOSFSTOOLS        = dosfstools_$(DOSFSTOOLS_VER)
DOSFSTOOLS_TARBALL= $(DOSFSTOOLS).orig.tar.gz
DOSFSTOOLS_URL 	= http://ftp.debian.org/debian/pool/main/d/dosfstools/$(DOSFSTOOLS_TARBALL)
DOSFSTOOLS_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(DOSFSTOOLS_TARBALL)
DOSFSTOOLS_DIR		= $(BUILDDIR)/dosfstools-$(DOSFSTOOLS_VER)

DOSFSTOOLS_PATCH_URL		= http://ftp.debian.org/debian/pool/main/d/dosfstools/dosfstools_2.11-2.1.diff.gz
DOSFSTOOLS_PATCH_SOURCE	= $(CONFIG_ARCHIVEPATH)/dosfstools_2.11-2.1.diff.gz

DOSFSTOOLS_PATCH2_URL		= http://boundarydevices.com/dosfstools_2.11_cross_compile.diff.gz
DOSFSTOOLS_PATCH2_SOURCE	= $(CONFIG_ARCHIVEPATH)/dosfstools_2.11_cross_compile.diff.gz

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

dosfstools_get: $(STATEDIR)/dosfstools.get

$(STATEDIR)/dosfstools.get: $(DOSFSTOOLS_SOURCE) $(DOSFSTOOLS_PATCH_SOURCE) $(DOSFSTOOLS_PATCH2_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(DOSFSTOOLS_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(DOSFSTOOLS_URL)

$(DOSFSTOOLS_PATCH_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(DOSFSTOOLS_PATCH_URL)

$(DOSFSTOOLS_PATCH2_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(DOSFSTOOLS_PATCH2_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

dosfstools_extract: $(STATEDIR)/dosfstools.extract

$(STATEDIR)/dosfstools.extract: $(STATEDIR)/dosfstools.get
	@$(call targetinfo, $@)
	@$(call clean, $(DOSFSTOOLS_DIR))
	@cd $(BUILDDIR) && zcat $(DOSFSTOOLS_SOURCE) | tar -xvf -
	@cd $(BUILDDIR) && zcat $(DOSFSTOOLS_PATCH_SOURCE) | patch -p0
	@cd $(BUILDDIR) && zcat $(DOSFSTOOLS_PATCH2_SOURCE) | patch -p0
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

dosfstools_prepare: $(STATEDIR)/dosfstools.prepare

$(STATEDIR)/dosfstools.prepare: $(STATEDIR)/dosfstools.extract
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

dosfstools_compile: $(STATEDIR)/dosfstools.compile

$(STATEDIR)/dosfstools.compile: $(STATEDIR)/dosfstools.prepare 
	@$(call targetinfo, $@)
	cd $(DOSFSTOOLS_DIR) && CC=$(CONFIG_GNU_TARGET)-gcc make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

dosfstools_install: $(STATEDIR)/dosfstools.install

$(STATEDIR)/dosfstools.install: $(STATEDIR)/dosfstools.compile
	@$(call targetinfo, $@)
	cp -fv $(DOSFSTOOLS_DIR)/dosfsck/dosfsck $(INSTALLPATH)/bin
	cp -fv $(DOSFSTOOLS_DIR)/mkdosfs/mkdosfs $(INSTALLPATH)/bin
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

dosfstools_targetinstall: $(STATEDIR)/dosfstools.targetinstall

$(STATEDIR)/dosfstools.targetinstall: $(STATEDIR)/dosfstools.install
	@$(call targetinfo, $@)
	@mkdir -p $(ROOTDIR)/bin
	cp -fv $(INSTALLPATH)/bin/dosfsck $(ROOTDIR)/bin && $(CROSSSTRIP) $(ROOTDIR)/bin/dosfsck
	cp -fv $(INSTALLPATH)/bin/mkdosfs $(ROOTDIR)/bin && $(CROSSSTRIP) $(ROOTDIR)/bin/mkdosfs
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

dosfstools_clean: 
	rm -rf $(STATEDIR)/dosfstools.* $(DOSFSTOOLS_DIR)

# vim: syntax=make
