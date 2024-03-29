# -*-makefile-*-
# $Id: freetype.make,v 1.6 2009-06-16 00:32:04 ericn Exp $
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
ifdef CONFIG_FREETYPE
PACKAGES += freetype
endif

#
# Paths and names
#
FREETYPE_VERSION	= 2.3.7
FREETYPE		= freetype-$(FREETYPE_VERSION)
FREETYPE_SUFFIX		= tar.gz
FREETYPE_URL		= http://umn.dl.sourceforge.net/sourceforge/freetype/$(FREETYPE).$(FREETYPE_SUFFIX)
FREETYPE_SOURCE		= $(CONFIG_ARCHIVEPATH)/$(FREETYPE).$(FREETYPE_SUFFIX)
FREETYPE_DIR		= $(BUILDDIR)/$(FREETYPE)
FREETYPE_SHARED=yes

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

freetype_get: $(STATEDIR)/freetype.get

freetype_get_deps = $(FREETYPE_SOURCE)

$(STATEDIR)/freetype.get: $(freetype_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(FREETYPE_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(FREETYPE_URL)	

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

freetype_extract: $(STATEDIR)/freetype.extract

freetype_extract_deps = $(STATEDIR)/freetype.get

$(STATEDIR)/freetype.extract: $(freetype_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FREETYPE_DIR))
	@cd $(BUILDDIR) && zcat $(FREETYPE_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

freetype_prepare: $(STATEDIR)/freetype.prepare

#
# dependencies
#
freetype_prepare_deps = \
	$(STATEDIR)/freetype.extract

FREETYPE_PATH	=  PATH=$(CROSS_PATH)
FREETYPE_ENV 	=  $(CROSS_ENV)
#FREETYPE_ENV	+=

#
# autoconf
#
FREETYPE_AUTOCONF = \
	--host=$(CONFIG_GNU_HOST) --prefix=/

ifdef FREETYPE_SHARED
   FREETYPE_AUTOCONF += --enable-shared=yes --enable-static=no
else
   FREETYPE_AUTOCONF += --enable-shared=no --enable-static=yes
endif

$(STATEDIR)/freetype.prepare: $(freetype_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FREETYPE_DIR)/config.cache)
	echo CROSS_PATH=$(CROSS_PATH)
	echo PATH=$(PATH)
	cd $(FREETYPE_DIR) && \
		$(FREETYPE_PATH) $(FREETYPE_ENV) \
		./configure $(FREETYPE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

freetype_compile: $(STATEDIR)/freetype.compile

freetype_compile_deps = $(STATEDIR)/freetype.prepare

$(STATEDIR)/freetype.compile: $(freetype_compile_deps)
	@$(call targetinfo, $@)
	$(FREETYPE_PATH) make -C $(FREETYPE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

freetype_install: $(STATEDIR)/freetype.install

$(STATEDIR)/freetype.install: $(STATEDIR)/freetype.compile
	@$(call targetinfo, $@)
	$(FREETYPE_PATH) make -C $(FREETYPE_DIR) DESTDIR=$(INSTALLPATH) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

freetype_targetinstall: $(STATEDIR)/freetype.targetinstall

freetype_targetinstall_deps = $(STATEDIR)/freetype.compile

$(STATEDIR)/freetype.targetinstall: $(freetype_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

freetype_clean:
	rm -rf $(STATEDIR)/freetype.*
	rm -rf $(FREETYPE_DIR)

# vim: syntax=make
