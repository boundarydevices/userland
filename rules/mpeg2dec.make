# -*-makefile-*-
# $Id: mpeg2dec.make,v 1.5 2005-11-23 14:49:43 ericn Exp $
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
ifdef CONFIG_LIBMPEG2
PACKAGES += mpeg2dec
endif

#
# Paths and names
#
ifdef CONFIG_LIBMPEG2_OLD
MPEG2DEC_VERSION	= 0.3.1
else
MPEG2DEC_VERSION	= 0.4.0
endif

MPEG2DEC		         = mpeg2dec-$(MPEG2DEC_VERSION)
MPEG2DEC_SUFFIX	   = tar.gz
MPEG2DEC_URLDIR      = http://libmpeg2.sourceforge.net/files
MPEG2DEC_URL		   = $(MPEG2DEC_URLDIR)/$(MPEG2DEC).$(MPEG2DEC_SUFFIX)
MPEG2DEC_SOURCE	   = $(CONFIG_ARCHIVEPATH)/$(MPEG2DEC).$(MPEG2DEC_SUFFIX)
MPEG2DEC_DIR		   = $(BUILDDIR)/$(MPEG2DEC)
ifdef CONFIG_LIBMPEG2_OLD
   MPEG2DEC_PATCH       = mpeg2dec-$(MPEG2DEC_VERSION)-2005-11-18.patch
   MPEG2DEC_PATCH_SRC   = $(CONFIG_ARCHIVEPATH)/$(MPEG2DEC_PATCH)
   MPEG2DEC_PATCH_URL   = http://boundarydevices.com/$(MPEG2DEC_PATCH)
endif

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mpeg2dec_get: $(STATEDIR)/mpeg2dec.get

mpeg2dec_get_deps = $(MPEG2DEC_SOURCE) 

ifdef CONFIG_LIBMPEG2_OLD
   mpeg2dec_get_deps += $(MPEG2DEC_PATCH_SRC)
endif

$(STATEDIR)/mpeg2dec.get: $(mpeg2dec_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(MPEG2DEC_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(MPEG2DEC_URL)

$(MPEG2DEC_PATCH_SRC):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(MPEG2DEC_PATCH_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mpeg2dec_extract: $(STATEDIR)/mpeg2dec.extract

mpeg2dec_extract_deps = $(STATEDIR)/mpeg2dec.get

$(STATEDIR)/mpeg2dec.extract: $(mpeg2dec_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MPEG2DEC_DIR))
	@cd $(BUILDDIR) && zcat $(MPEG2DEC_SOURCE) | tar -xvf -
ifdef CONFIG_LIBMPEG2_OLD
	cd $(BUILDDIR) && patch -p0 <$(MPEG2DEC_PATCH_SRC)
endif
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mpeg2dec_prepare: $(STATEDIR)/mpeg2dec.prepare

#
# dependencies
#
mpeg2dec_prepare_deps = \
	$(STATEDIR)/mpeg2dec.extract 

MPEG2DEC_PATH	=  PATH=$(CROSS_PATH)
MPEG2DEC_ENV 	=  $(CROSS_ENV)
#MPEG2DEC_ENV	+=

#
# autoconf
#
MPEG2DEC_AUTOCONF = \
	--host=$(CONFIG_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR) \
   --enable-shared=no \
   --enable-static=yes \
   --disable-sdl \
   --exec-prefix=$(INSTALLPATH) \
   --includedir=$(INSTALLPATH)/include \
   --mandir=$(INSTALLPATH)/man \
   --infodir=$(INSTALLPATH)/info

$(STATEDIR)/mpeg2dec.prepare: $(mpeg2dec_prepare_deps)
	@$(call targetinfo, $@)
	cd $(MPEG2DEC_DIR) && ./bootstrap
	@$(call clean, $(MPEG2DEC_DIR)/config.cache)
	cd $(MPEG2DEC_DIR) && \
		$(MPEG2DEC_PATH) $(MPEG2DEC_ENV) \
		./configure $(MPEG2DEC_AUTOCONF)
	touch $@

#
#	cd $(MPEG2DEC_DIR) && ./bootstrap
# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mpeg2dec_compile: $(STATEDIR)/mpeg2dec.compile

mpeg2dec_compile_deps = $(STATEDIR)/mpeg2dec.prepare

$(STATEDIR)/mpeg2dec.compile: $(mpeg2dec_compile_deps)
	@$(call targetinfo, $@)
	$(MPEG2DEC_PATH) make -C $(MPEG2DEC_DIR)/libmpeg2
	$(MPEG2DEC_PATH) make -C $(MPEG2DEC_DIR)/libvo
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mpeg2dec_install: $(STATEDIR)/mpeg2dec.install

$(STATEDIR)/mpeg2dec.install: $(STATEDIR)/mpeg2dec.compile
	@$(call targetinfo, $@)
	$(MPEG2DEC_PATH) make -C $(MPEG2DEC_DIR)/libmpeg2 install
	$(MPEG2DEC_PATH) make -C $(MPEG2DEC_DIR)/libvo install
	@mkdir -p $(INSTALLPATH)/include/mpeg2dec
	@cp -f -R $(MPEG2DEC_DIR)/include/*.h $(INSTALLPATH)/include/mpeg2dec
	@cp -f -R $(MPEG2DEC_DIR)/libvo/*.a $(INSTALLPATH)/lib
	@cp -f -R $(MPEG2DEC_DIR)/libmpeg2/.libs/*.a $(INSTALLPATH)/lib
ifndef CONFIG_LIBMPEG2_OLD
	@cp -f -R $(MPEG2DEC_DIR)/libmpeg2/convert/.libs/*.a $(INSTALLPATH)/lib
endif
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mpeg2dec_targetinstall: $(STATEDIR)/mpeg2dec.targetinstall

mpeg2dec_targetinstall_deps = $(STATEDIR)/mpeg2dec.compile

$(STATEDIR)/mpeg2dec.targetinstall: $(mpeg2dec_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mpeg2dec_clean:
	rm -rf $(STATEDIR)/mpeg2dec.*
	rm -rf $(MPEG2DEC_DIR)

# vim: syntax=make
