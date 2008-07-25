# -*-makefile-*-
# $Id: busybox.make,v 1.10 2008-07-25 04:50:16 ericn Exp $
#
# Copyright (C) 2003 by Robert Schwebel <r.schwebel@pengutronix.de>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef CONFIG_BUSYBOX
PACKAGES += busybox
endif

#
# Paths and names
#
BUSYBOX_VERSION		= 1.10.0
BUSYBOX			= busybox-$(BUSYBOX_VERSION)
BUSYBOX_SUFFIX		= tar.bz2
BUSYBOX_URL		= http://www.busybox.net/downloads/$(BUSYBOX).$(BUSYBOX_SUFFIX)
BUSYBOX_SOURCE		= $(CONFIG_ARCHIVEPATH)/$(BUSYBOX).$(BUSYBOX_SUFFIX)
BUSYBOX_DIR		= $(BUILDDIR)/$(BUSYBOX)
BUSYBOX_CONFIG_URL = http://boundarydevices.com/$(BUSYBOX).config.20080401
BUSYBOX_CONFIG = $(CONFIG_ARCHIVEPATH)/$(BUSYBOX).config.20080401

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

busybox_get: $(STATEDIR)/busybox.get

busybox_get_deps	 =  $(BUSYBOX_SOURCE)
busybox_get_deps  +=  $(BUSYBOX_CONFIG)

$(STATEDIR)/busybox.get: $(busybox_get_deps)
	touch $@

$(BUSYBOX_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(BUSYBOX_URL)

$(BUSYBOX_CONFIG):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(BUSYBOX_CONFIG_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------
busybox_extract: $(STATEDIR)/busybox.extract
busybox_extract_deps	=  $(STATEDIR)/busybox.get

$(STATEDIR)/busybox.extract: $(busybox_extract_deps)
	@$(call targetinfo, $@)
	rm -rf $(BUSYBOX_DIR)
	cd $(BUILDDIR) && bzcat $(BUSYBOX_SOURCE) | tar -xvf -
	cp -vf $(BUSYBOX_CONFIG) $(BUSYBOX_DIR)/.config
	cd $(BUSYBOX_DIR) && yes "" | make oldconfig
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

busybox_prepare: $(STATEDIR)/busybox.prepare

BUSYBOX_PATH		=  PATH=$(CROSS_PATH)
BUSYBOX_ENV 		=  $(CROSS_ENV)
BUSYBOX_MAKEVARS	=  CROSS=$(CONFIG_GNU_TARGET)- HOSTCC=$(HOSTCC) EXTRA_CFLAGS='$(strip $(subst ",,$(TARGET_CFLAGS)))'

#
# dependencies
#
busybox_prepare_deps	= $(STATEDIR)/busybox.extract

$(STATEDIR)/busybox.prepare: $(busybox_prepare_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

busybox_compile: $(STATEDIR)/busybox.compile

busybox_compile_deps =  $(STATEDIR)/busybox.prepare

$(STATEDIR)/busybox.compile: $(busybox_compile_deps)
	@$(call targetinfo, $@)
	$(BUSYBOX_PATH) && $(BUSYBOX_ENV) \
   && make CROSS_COMPILE=$(CONFIG_GNU_TARGET)- -C $(BUSYBOX_DIR) all $(BUSYBOX_MAKEVARS)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

busybox_install: $(STATEDIR)/busybox.install

$(STATEDIR)/busybox.install: $(STATEDIR)/busybox.compile
	@$(call targetinfo, $@)
	cd $(BUSYBOX_DIR) &&					\
		$(BUSYBOX_PATH)  \
                CROSS_COMPILE=$(CONFIG_GNU_TARGET)- \
                $(MAKE) install 		\
		$(BUSYBOX_MAKEVARS)
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

busybox_targetinstall: $(STATEDIR)/busybox.targetinstall

busybox_targetinstall_deps	=  $(STATEDIR)/busybox.install

$(STATEDIR)/busybox.targetinstall: $(busybox_targetinstall_deps)
	@$(call targetinfo, $@)
	mkdir -p $(ROOTDIR) $(ROOTDIR)/bin
	cp -rvd $(BUSYBOX_DIR)/_install/* $(ROOTDIR)
	$(BUSYBOX_PATH) $(CROSSSTRIP) -R .note -R .comment $(ROOTDIR)/bin/busybox
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

busybox_clean:
	rm -rf $(STATEDIR)/busybox.*
	rm -rf $(BUSYBOX_DIR)

# vim: syntax=make
