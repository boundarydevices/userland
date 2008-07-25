# -*-makefile-*-
# $Id: module-init-tools.make,v 1.5 2008-07-25 03:32:21 ericn Exp $
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
ifeq (y, $(CONFIG_MODULE_INIT_TOOLS))
PACKAGES += module_init_tools
endif

#
# Paths and names 
#
MODULE_INIT_TOOLS	        = module-init-tools-3.2
MODULE_INIT_TOOLS_URL 	        = http://www.kernel.org/pub/linux/utils/kernel/module-init-tools/$(MODULE_INIT_TOOLS).tar.gz
MODULE_INIT_TOOLS_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(MODULE_INIT_TOOLS).tar.gz
MODULE_INIT_TOOLS_DIR		= $(BUILDDIR)/$(MODULE_INIT_TOOLS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

module_init_tools_get: $(STATEDIR)/module_init_tools.get

$(STATEDIR)/module_init_tools.get: $(MODULE_INIT_TOOLS_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(MODULE_INIT_TOOLS_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(MODULE_INIT_TOOLS_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

module_init_tools_extract: $(STATEDIR)/module_init_tools.extract

$(STATEDIR)/module_init_tools.extract: $(STATEDIR)/module_init_tools.get
	@$(call targetinfo, $@)
	@$(call clean, $(MODULE_INIT_TOOLS_DIR))
	@cd $(BUILDDIR) && zcat $(MODULE_INIT_TOOLS_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

module_init_tools_prepare: $(STATEDIR)/module_init_tools.prepare

module_init_tools_prepare_deps = \
	$(STATEDIR)/module_init_tools.extract

$(STATEDIR)/module_init_tools.prepare: $(module_init_tools_prepare_deps)
	@$(call targetinfo, $@)
	cd $(MODULE_INIT_TOOLS_DIR) && \
		CROSS_COMPILE=$(CONFIG_CROSSPREFIX) ./configure --target=$(CONFIG_GNU_HOST) --host=$(CONFIG_GNU_HOST)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

module_init_tools_compile: $(STATEDIR)/module_init_tools.compile

$(STATEDIR)/module_init_tools.compile: $(STATEDIR)/module_init_tools.prepare 
	@$(call targetinfo, $@)
	cd $(MODULE_INIT_TOOLS_DIR) && PATH=$(CROSS_PATH) make depmod
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

module_init_tools_install: $(STATEDIR)/module_init_tools.install
$(TOPDIR)/tools:
	mkdir -p $@

$(STATEDIR)/module_init_tools.install: $(STATEDIR)/module_init_tools.compile $(TOPDIR)/tools
	@$(call targetinfo, $@)
	cp -fv $(MODULE_INIT_TOOLS_DIR)/depmod $(TOPDIR)/tools
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

module_init_tools_targetinstall: $(STATEDIR)/module_init_tools.targetinstall

$(STATEDIR)/module_init_tools.targetinstall: $(STATEDIR)/module_init_tools.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

module_init_tools_clean: 
	rm -rf $(STATEDIR)/module_init_tools.* $(MODULE_INIT_TOOLS_DIR)

# vim: syntax=make
