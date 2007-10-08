# -*-makefile-*-
# $Id: ogg.make,v 1.2 2007-10-08 21:06:10 ericn Exp $
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
ifdef CONFIG_LIBOGG
PACKAGES += ogg
endif

#
# Paths and names
#
OGG_VERSION    = 1.1.2
OGG	         = libogg-$(OGG_VERSION)
OGG_SUFFIX	   = tar.gz
OGG_URLDIR     = http://downloads.xiph.org/releases/ogg/
OGG_URL		   = $(OGG_URLDIR)/$(OGG).$(OGG_SUFFIX)
OGG_SOURCE	   = $(CONFIG_ARCHIVEPATH)/$(OGG).$(OGG_SUFFIX)
OGG_DIR		   = $(BUILDDIR)/$(OGG)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ogg_get: $(STATEDIR)/ogg.get

ogg_get_deps = $(OGG_SOURCE) 

$(STATEDIR)/ogg.get: $(ogg_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(OGG_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(OGG_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ogg_extract: $(STATEDIR)/ogg.extract

ogg_extract_deps = $(STATEDIR)/ogg.get

$(STATEDIR)/ogg.extract: $(ogg_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(OGG_DIR))
	@cd $(BUILDDIR) && zcat $(OGG_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ogg_prepare: $(STATEDIR)/ogg.prepare

#
# dependencies
#
ogg_prepare_deps = \
	$(STATEDIR)/ogg.extract 

OGG_PATH	=  PATH=$(CROSS_PATH)
OGG_ENV 	=  $(CROSS_ENV)
#OGG_ENV	+=

#
# autoconf
#
OGG_AUTOCONF = \
	--host=$(CONFIG_GNU_HOST) \
	--prefix=$(CROSS_LIB_DIR) \
   --enable-shared=no \
   --enable-static=yes \
   --disable-sdl \
   --exec-prefix=$(INSTALLPATH) \
   --includedir=$(INSTALLPATH)/include \
   --mandir=$(INSTALLPATH)/man \
   --infodir=$(INSTALLPATH)/info

$(STATEDIR)/ogg.prepare: $(ogg_prepare_deps)
	@$(call targetinfo, $@)
	cd $(OGG_DIR) && \
		$(OGG_PATH) $(OGG_ENV) \
		./configure $(OGG_AUTOCONF)
	touch $@

#
#	cd $(OGG_DIR) && ./bootstrap
# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ogg_compile: $(STATEDIR)/ogg.compile

ogg_compile_deps = $(STATEDIR)/ogg.prepare

$(STATEDIR)/ogg.compile: $(ogg_compile_deps)
	@$(call targetinfo, $@)
	$(OGG_PATH) make -C $(OGG_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ogg_install: $(STATEDIR)/ogg.install

$(STATEDIR)/ogg.install: $(STATEDIR)/ogg.compile
	@$(call targetinfo, $@)
	$(OGG_PATH) make -C $(OGG_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ogg_targetinstall: $(STATEDIR)/ogg.targetinstall

ogg_targetinstall_deps = $(STATEDIR)/ogg.compile

$(STATEDIR)/ogg.targetinstall: $(ogg_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ogg_clean:
	rm -rf $(STATEDIR)/ogg.*
	rm -rf $(OGG_DIR)

# vim: syntax=make
