# -*-makefile-*-
# $Id: tinylogin.make,v 1.1 2004-06-09 13:07:46 ericn Exp $
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
ifdef PTXCONF_TINYLOGIN
PACKAGES += tinylogin
endif

#
# Paths and names
#
TINYLOGIN_VERSION	= 1.4
TINYLOGIN		= tinylogin-$(TINYLOGIN_VERSION)
TINYLOGIN_SUFFIX		= tar.gz
TINYLOGIN_URL		= http://tinylogin.busybox.net/downloads//$(TINYLOGIN).$(TINYLOGIN_SUFFIX)
TINYLOGIN_SOURCE		= $(CONFIG_ARCHIVEPATH)/$(TINYLOGIN).$(TINYLOGIN_SUFFIX)
TINYLOGIN_DIR		= $(BUILDDIR)/$(TINYLOGIN)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

tinylogin_get: $(STATEDIR)/tinylogin.get

tinylogin_get_deps = $(TINYLOGIN_SOURCE)

$(STATEDIR)/tinylogin.get: $(tinylogin_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(TINYLOGIN_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(TINYLOGIN_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

tinylogin_extract: $(STATEDIR)/tinylogin.extract

tinylogin_extract_deps = $(STATEDIR)/tinylogin.get

$(STATEDIR)/tinylogin.extract: $(tinylogin_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TINYLOGIN_DIR))
	@cd $(BUILDDIR) && gzcat $(TINYLOGIN_SOURCE) | tar -xvf -
	sed 's/USE_SYSTEM_PWD_GRP = true/USE_SYSTEM_PWD_GRP = false/' <$(TINYLOGIN_DIR)/Makefile >$(TINYLOGIN_DIR)/Makefile.patched
	mv $(TINYLOGIN_DIR)/Makefile $(TINYLOGIN_DIR)/Makefile.orig
	mv $(TINYLOGIN_DIR)/Makefile.patched $(TINYLOGIN_DIR)/Makefile
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

tinylogin_prepare: $(STATEDIR)/tinylogin.prepare

#
# dependencies
#
tinylogin_prepare_deps = \
	$(STATEDIR)/tinylogin.extract 

TINYLOGIN_PATH	=  PATH=$(CROSS_PATH)
TINYLOGIN_ENV 	=  $(CROSS_ENV)
#TINYLOGIN_ENV	+=

#
# autoconf
#
TINYLOGIN_AUTOCONF = \
	--build=$(GNU_HOST) \
	--host=$(PTXCONF_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

$(STATEDIR)/tinylogin.prepare: $(tinylogin_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(TINYLOGIN_DIR)/config.cache)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

tinylogin_compile: $(STATEDIR)/tinylogin.compile

tinylogin_compile_deps = $(STATEDIR)/tinylogin.prepare

$(STATEDIR)/tinylogin.compile: $(tinylogin_compile_deps)
	@$(call targetinfo, $@)
	$(TINYLOGIN_PATH) \
   $(TINYLOGIN_ENV) make -C $(TINYLOGIN_DIR) CROSS=arm-linux- 
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

tinylogin_install: $(STATEDIR)/tinylogin.install

$(STATEDIR)/tinylogin.install: $(STATEDIR)/tinylogin.compile
	@$(call targetinfo, $@)
	$(TINYLOGIN_PATH) sudo make -C $(TINYLOGIN_DIR) CROSS=arm-linux- PREFIX=$(INSTALLPATH) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

tinylogin_targetinstall: $(STATEDIR)/tinylogin.targetinstall

tinylogin_targetinstall_deps = $(STATEDIR)/tinylogin.compile

$(STATEDIR)/tinylogin.targetinstall: $(tinylogin_targetinstall_deps)
	@$(call targetinfo, $@)
	$(TINYLOGIN_PATH) sudo make -C $(TINYLOGIN_DIR) CROSS=arm-linux- PREFIX=$(ROOTDIR) install
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

tinylogin_clean:
	rm -rf $(STATEDIR)/tinylogin.*
	rm -rf $(TINYLOGIN_DIR)

# vim: syntax=make
