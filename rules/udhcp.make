# -*-makefile-*-
# $Id: udhcp.make,v 1.8 2007-10-08 21:06:10 ericn Exp $
#
# Copyright (C) 2003 by Boundary Devices
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef CONFIG_UDHCP
PACKAGES += udhcp
endif

#
# Paths and names
#
UDHCP_VERSION	= 0.9.7
UDHCP		= udhcp-$(UDHCP_VERSION)
UDHCP_SUFFIX		= tar.gz
UDHCP_URL		= http://udhcp.busybox.net/source/$(UDHCP).$(UDHCP_SUFFIX)
UDHCP_SOURCE		= $(CONFIG_ARCHIVEPATH)/$(UDHCP).$(UDHCP_SUFFIX)
UDHCP_DIR		= $(BUILDDIR)/$(UDHCP)

UDHCP_PATCH_URL		= http://boundarydevices.com/$(UDHCP).patch
UDHCP_PATCH_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(UDHCP).patch

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

udhcp_get: $(STATEDIR)/udhcp.get

udhcp_get_deps = $(UDHCP_SOURCE) $(UDHCP_PATCH_SOURCE)

$(STATEDIR)/udhcp.get: $(udhcp_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(UDHCP_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(UDHCP_URL)

$(UDHCP_PATCH_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(UDHCP_PATCH_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

udhcp_extract: $(STATEDIR)/udhcp.extract

udhcp_extract_deps = $(STATEDIR)/udhcp.get

$(STATEDIR)/udhcp.extract: $(udhcp_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UDHCP_DIR))
	@cd $(BUILDDIR) && zcat $(UDHCP_SOURCE) | tar -xvf -
	cd $(BUILDDIR) && patch -p0 < $(UDHCP_PATCH_SOURCE)
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

udhcp_prepare: $(STATEDIR)/udhcp.prepare

#
# dependencies
#
udhcp_prepare_deps = \
	$(STATEDIR)/udhcp.extract 

UDHCP_PATH	=  PATH=$(CROSS_PATH)
UDHCP_ENV 	=  $(CROSS_ENV)
UDHCP_ENV	+= CROSS_COMPILE=$(CONFIG_CROSSPREFIX)- 

#
# autoconf
#
UDHCP_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(CONFIG_GNU_HOST) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/udhcp.prepare: $(udhcp_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(UDHCP_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

udhcp_compile: $(STATEDIR)/udhcp.compile

udhcp_compile_deps = $(STATEDIR)/udhcp.prepare

$(STATEDIR)/udhcp.compile: $(udhcp_compile_deps)
	@$(call targetinfo, $@)
	$(UDHCP_PATH) \
   $(UDHCP_ENV) make -C $(UDHCP_DIR) all
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

udhcp_install: $(STATEDIR)/udhcp.install

$(STATEDIR)/udhcp.install: $(STATEDIR)/udhcp.compile
	@$(call targetinfo, $@)
	$(UDHCP_PATH) \
   $(UDHCP_ENV) make -C $(UDHCP_DIR) install prefix=$(INSTALLPATH) SBINDIR=$(INSTALLPATH)/sbin
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

udhcp_targetinstall: $(STATEDIR)/udhcp.targetinstall

udhcp_targetinstall_deps = $(STATEDIR)/udhcp.compile

$(STATEDIR)/udhcp.targetinstall: $(udhcp_targetinstall_deps)
	@$(call targetinfo, $@)
ifeq (y, $(CONFIG_UDHCP_SERVER))
	mkdir -p $(ROOTDIR)/sbin
	cp $(UDHCP_DIR)/udhcpd $(ROOTDIR)/sbin
	$(UDHCP_PATH) \
   $(UDHCP_ENV) $(CROSSSTRIP) $(ROOTDIR)/sbin/udhcpd
endif
ifeq (y, $(CONFIG_UDHCP_CLIENT))
	mkdir -p $(ROOTDIR)/sbin
	cp $(UDHCP_DIR)/udhcpc $(ROOTDIR)/sbin
	$(UDHCP_PATH) \
   $(UDHCP_ENV) $(CROSSSTRIP) $(ROOTDIR)/sbin/udhcpc
	-mkdir -p $(ROOTDIR)/etc/pcmcia/
	-rm -f $(ROOTDIR)/etc/pcmcia/dhcp
	cd $(ROOTDIR)/etc/pcmcia && ln -sf ../../js/dhcp
endif
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

udhcp_clean:
	rm -rf $(STATEDIR)/udhcp.*
	rm -rf $(UDHCP_DIR)

# vim: syntax=make
