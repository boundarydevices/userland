# -*-makefile-*-
# $Id: vorbis.make,v 1.1 2006-07-30 15:07:19 ericn Exp $
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
ifdef CONFIG_LIBVORBIS
PACKAGES += vorbis
endif

#
# Paths and names
#
VORBIS_VERSION    = 1.1.1
VORBIS	         = libvorbis-$(VORBIS_VERSION)
VORBIS_SUFFIX	   = tar.gz
VORBIS_URLDIR     = http://downloads.xiph.org/releases/vorbis/
VORBIS_URL		   = $(VORBIS_URLDIR)/$(VORBIS).$(VORBIS_SUFFIX)
VORBIS_SOURCE	   = $(CONFIG_ARCHIVEPATH)/$(VORBIS).$(VORBIS_SUFFIX)
VORBIS_DIR		   = $(BUILDDIR)/$(VORBIS)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

vorbis_get: $(STATEDIR)/vorbis.get

vorbis_get_deps = $(VORBIS_SOURCE) 

$(STATEDIR)/vorbis.get: $(vorbis_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(VORBIS_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(VORBIS_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

vorbis_extract: $(STATEDIR)/vorbis.extract

vorbis_extract_deps = $(STATEDIR)/vorbis.get

$(STATEDIR)/vorbis.extract: $(vorbis_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(VORBIS_DIR))
	@cd $(BUILDDIR) && zcat $(VORBIS_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

vorbis_prepare: $(STATEDIR)/vorbis.prepare

#
# dependencies
#
vorbis_prepare_deps = \
	$(STATEDIR)/vorbis.extract 

VORBIS_PATH	=  PATH=$(CROSS_PATH)
VORBIS_ENV 	=  $(CROSS_ENV)
#VORBIS_ENV	+=

#
# autoconf
#
VORBIS_AUTOCONF = \
	--host=$(CONFIG_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR) \
   --enable-shared=no \
   --enable-static=yes \
   --disable-sdl \
   --exec-prefix=$(INSTALLPATH) \
   --includedir=$(INSTALLPATH)/include \
   --mandir=$(INSTALLPATH)/man \
   --infodir=$(INSTALLPATH)/info

$(STATEDIR)/vorbis.prepare: $(vorbis_prepare_deps)
	@$(call targetinfo, $@)
	cd $(VORBIS_DIR) && \
		$(VORBIS_PATH) $(VORBIS_ENV) \
		./configure $(VORBIS_AUTOCONF)
	touch $@

#
#	cd $(VORBIS_DIR) && ./bootstrap
# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

vorbis_compile: $(STATEDIR)/vorbis.compile

vorbis_compile_deps = $(STATEDIR)/vorbis.prepare

$(STATEDIR)/vorbis.compile: $(vorbis_compile_deps)
	@$(call targetinfo, $@)
	$(VORBIS_PATH) make -C $(VORBIS_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

vorbis_install: $(STATEDIR)/vorbis.install

$(STATEDIR)/vorbis.install: $(STATEDIR)/vorbis.compile
	@$(call targetinfo, $@)
	$(VORBIS_PATH) make -C $(VORBIS_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

vorbis_targetinstall: $(STATEDIR)/vorbis.targetinstall

vorbis_targetinstall_deps = $(STATEDIR)/vorbis.compile

$(STATEDIR)/vorbis.targetinstall: $(vorbis_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

vorbis_clean:
	rm -rf $(STATEDIR)/vorbis.*
	rm -rf $(VORBIS_DIR)

# vim: syntax=make
