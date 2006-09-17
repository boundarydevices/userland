# -*-makefile-*-
# $Id: ethtool.make,v 1.1 2006-09-17 02:32:19 ericn Exp $
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
ifeq (y, $(CONFIG_ETHTOOL))
PACKAGES += ethtool
endif

#
# Paths and names 
#
ETHTOOL			= ethtool-5
ETHTOOL_URL 	= http://easynews.dl.sourceforge.net/sourceforge/gkernel/$(ETHTOOL).tar.gz
ETHTOOL_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(ETHTOOL).tar.gz
ETHTOOL_DIR		= $(BUILDDIR)/$(ETHTOOL)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ethtool_get: $(STATEDIR)/ethtool.get

$(STATEDIR)/ethtool.get: $(ETHTOOL_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(ETHTOOL_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(ETHTOOL_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ethtool_extract: $(STATEDIR)/ethtool.extract

$(STATEDIR)/ethtool.extract: $(STATEDIR)/ethtool.get
	@$(call targetinfo, $@)
	@$(call clean, $(ETHTOOL_DIR))
	@cd $(BUILDDIR) && zcat $(ETHTOOL_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ethtool_prepare: $(STATEDIR)/ethtool.prepare

ethtool_prepare_deps = \
	$(STATEDIR)/ethtool.extract

ETHTOOL_PATH	=  PATH=$(CROSS_PATH)
ETHTOOL_AUTOCONF 	= --prefix=$(INSTALLPATH) \
                    --host=$(CONFIG_GNU_TARGET)

$(STATEDIR)/ethtool.prepare: $(ethtool_prepare_deps)
	@$(call targetinfo, $@)
	cd $(ETHTOOL_DIR) && \
		$(ETHTOOL_PATH) \
      $(CROSS_ENV) \
		./configure $(ETHTOOL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ethtool_compile: $(STATEDIR)/ethtool.compile

$(STATEDIR)/ethtool.compile: $(STATEDIR)/ethtool.prepare 
	@$(call targetinfo, $@)
	cd $(ETHTOOL_DIR) && $(ETHTOOL_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ethtool_install: $(STATEDIR)/ethtool.install

$(STATEDIR)/ethtool.install: $(STATEDIR)/ethtool.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(ETHTOOL_DIR) && $(ETHTOOL_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ethtool_targetinstall: $(STATEDIR)/ethtool.targetinstall

$(STATEDIR)/ethtool.targetinstall: $(STATEDIR)/ethtool.install
	@$(call targetinfo, $@)
	@mkdir -p $(ROOTDIR)/sbin
	cp -fv $(INSTALLPATH)/sbin/ethtool $(ROOTDIR)/sbin && $(CROSSSTRIP) $(ROOTDIR)/sbin/ethtool
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ethtool_clean: 
	rm -rf $(STATEDIR)/ethtool.* $(ETHTOOL_DIR)

# vim: syntax=make
