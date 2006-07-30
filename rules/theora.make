# -*-makefile-*-
# $Id: theora.make,v 1.1 2006-07-30 15:07:31 ericn Exp $
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
ifdef CONFIG_LIBTHEORA
PACKAGES += theora
endif

#
# Paths and names
#
THEORA_VERSION    = 1.0alpha7
THEORA	         = libtheora-$(THEORA_VERSION)
THEORA_SUFFIX	   = tar.gz
THEORA_URLDIR     = http://downloads.xiph.org/releases/theora/
THEORA_URL		   = $(THEORA_URLDIR)/$(THEORA).$(THEORA_SUFFIX)
THEORA_SOURCE	   = $(CONFIG_ARCHIVEPATH)/$(THEORA).$(THEORA_SUFFIX)
THEORA_DIR		   = $(BUILDDIR)/$(THEORA)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

theora_get: $(STATEDIR)/theora.get

theora_get_deps = $(THEORA_SOURCE) 

$(STATEDIR)/theora.get: $(theora_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(THEORA_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(THEORA_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

theora_extract: $(STATEDIR)/theora.extract

theora_extract_deps = $(STATEDIR)/theora.get

$(STATEDIR)/theora.extract: $(theora_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(THEORA_DIR))
	@cd $(BUILDDIR) && zcat $(THEORA_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

theora_prepare: $(STATEDIR)/theora.prepare

#
# dependencies
#
theora_prepare_deps = \
	$(STATEDIR)/theora.extract 

THEORA_PATH	=  PATH=$(CROSS_PATH)
THEORA_ENV 	=  $(CROSS_ENV)
#THEORA_ENV	+=

#
# autoconf
#
THEORA_AUTOCONF = \
	--host=$(CONFIG_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR) \
   --enable-shared=no \
   --enable-static=yes \
   --disable-sdl \
   --exec-prefix=$(INSTALLPATH) \
   --includedir=$(INSTALLPATH)/include \
   --oldincludedir=$(INSTALLPATH)/include \
   --mandir=$(INSTALLPATH)/man \
   --infodir=$(INSTALLPATH)/info \
   --with-ogg-includes=$(INSTALLPATH)/include/ogg \
   --with-ogg-libraries=$(INSTALLPATH)/lib \
   --disable-vorbis-test \
   --disable-float \
   --disable-sdltest \
   --disable-encode

$(STATEDIR)/theora.prepare: $(theora_prepare_deps)
	@$(call targetinfo, $@)
	cd $(THEORA_DIR) && \
		$(THEORA_PATH) $(THEORA_ENV) \
		./configure $(THEORA_AUTOCONF)
	touch $@

#
#	cd $(THEORA_DIR) && ./bootstrap
# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

theora_compile: $(STATEDIR)/theora.compile

theora_compile_deps = $(STATEDIR)/theora.prepare

$(STATEDIR)/theora.compile: $(theora_compile_deps)
	@$(call targetinfo, $@)
	$(THEORA_PATH) \
   make -C $(THEORA_DIR)/lib
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

theora_install: $(STATEDIR)/theora.install

$(STATEDIR)/theora.install: $(STATEDIR)/theora.compile
	@$(call targetinfo, $@)
	$(THEORA_PATH) make -C $(THEORA_DIR)/lib install
	$(THEORA_PATH) make -C $(THEORA_DIR)/include install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

theora_targetinstall: $(STATEDIR)/theora.targetinstall

theora_targetinstall_deps = $(STATEDIR)/theora.compile

$(STATEDIR)/theora.targetinstall: $(theora_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

theora_clean:
	rm -rf $(STATEDIR)/theora.*
	rm -rf $(THEORA_DIR)

# vim: syntax=make
