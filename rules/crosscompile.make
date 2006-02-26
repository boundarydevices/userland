# -*-makefile-*-
# $Id: crosscompile.make,v 1.1 2006-02-26 16:29:58 ericn Exp $
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
ifeq (y, $(CONFIG_CROSSCOMPILE))
PACKAGES += crosscompile
endif

#
# Paths and names 
#

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

crosscompile_get: $(STATEDIR)/crosscompile.get

$(STATEDIR)/crosscompile.get:
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

crosscompile_extract: $(STATEDIR)/crosscompile.extract

$(STATEDIR)/crosscompile.extract: $(STATEDIR)/crosscompile.get
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

crosscompile_prepare: $(STATEDIR)/crosscompile.prepare

$(STATEDIR)/crosscompile.prepare:
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

crosscompile_compile: $(STATEDIR)/crosscompile.compile

$(STATEDIR)/crosscompile.compile: $(STATEDIR)/crosscompile.prepare 
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

crosscompile_install: $(STATEDIR)/crosscompile.install

CCPATH = $(TOPDIR)/crosscompile

$(STATEDIR)/crosscompile.install: $(STATEDIR)/crosscompile.compile
	@$(call targetinfo, $@)
	mkdir -p $(CCPATH)
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-gcc gcc 
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-gcc cc 
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-ld ld 
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-ar ar 
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-cpp cpp
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-gcov gcov
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-ranlib ranlib 
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-nm nm 
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-objdump objdump 
	cd $(CCPATH) && ln -sf $(CONFIG_TOOLCHAINPATH)bin/$(CONFIG_CROSSPREFIX)-g++ g++
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

crosscompile_targetinstall: $(STATEDIR)/crosscompile.targetinstall

$(STATEDIR)/crosscompile.targetinstall: $(STATEDIR)/crosscompile.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

crosscompile_clean: 
	rm -rf $(STATEDIR)/crosscompile.*
	rm -rf $(TOPDIR)/crosscompile

# vim: syntax=make
