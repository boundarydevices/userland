# -*-makefile-*-
# $Id: libflash.make,v 1.2 2004-05-31 21:04:24 ericn Exp $
#
# Copyright (C) 2004 by Boundary Devices
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef CONFIG_LIBFLASH
PACKAGES += libflash
endif

#
# Paths and names
#
LIBFLASH_VERSION	= 0.4.10
LIBFLASH_URL		= http://www.boundarydevices.com/flash-0.4.10.tgz
LIBFLASH_SOURCE		= $(CONFIG_ARCHIVEPATH)/flash-0.4.10.tgz
LIBFLASH_DIR		= $(BUILDDIR)/flash-0.4.10
LIBFLASH_PATCH_SOURCE = $(CONFIG_ARCHIVEPATH)/flash.patch
LIBFLASH_PATCH_URL = http://www.boundarydevices.com/flash.patch

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libflash_get: $(STATEDIR)/libflash.get

libflash_get_deps = $(LIBFLASH_SOURCE) $(LIBFLASH_PATCH_SOURCE)

$(STATEDIR)/libflash.get: $(libflash_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(LIBFLASH_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(LIBFLASH_URL)

$(LIBFLASH_PATCH_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(LIBFLASH_PATCH_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libflash_extract: $(STATEDIR)/libflash.extract

libflash_extract_deps = $(STATEDIR)/libflash.get
libflash_extract_deps = $(STATEDIR)/JPEG.install

INSTALLPATH_ESCAPED = $(subst /,\/, $INSTALLPATH)

$(STATEDIR)/libflash.extract: $(libflash_extract_deps)
	@$(call targetinfo, $@)
	rm -rf $(LIBFLASH_DIR)
	@cd $(BUILDDIR) && gzcat $(LIBFLASH_SOURCE) | tar -xvf -
	@patch -d $(BUILDDIR) -p0 < $(LIBFLASH_PATCH_SOURCE)
	mv $(LIBFLASH_DIR)/Lib/Makefile $(LIBFLASH_DIR)/Lib/Makefile.orig
	sed 's/..\/jpeg-6b/$(INSTALLPATH_ESCAPED)\/include/' \
          < $(LIBFLASH_DIR)/Lib/Makefile.orig \
          > $(LIBFLASH_DIR)/Lib/Makefile
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libflash_prepare: $(STATEDIR)/libflash.prepare

#
# dependencies
#
libflash_prepare_deps = \
	$(STATEDIR)/libflash.extract 

LIBFLASH_PATH	=  PATH=$(CROSS_PATH)
LIBFLASH_ENV 	=  $(CROSS_ENV)

#
# There is currently no configuration for libflash
#
$(STATEDIR)/libflash.prepare: $(libflash_prepare_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libflash_compile: $(STATEDIR)/libflash.compile 

libflash_compile_deps = $(STATEDIR)/libflash.prepare 
libflash_compile_deps += $(STATEDIR)/JPEG.prepare 
libflash_compile_deps += $(STATEDIR)/zlib.prepare

$(STATEDIR)/libflash.compile: $(libflash_compile_deps)
	@$(call targetinfo, $@)
	$(LIBFLASH_PATH) CC=$(CONFIG_GNU_TARGET)-gcc CXX=$(CONFIG_GNU_TARGET)-gcc make -C $(LIBFLASH_DIR)/Lib
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libflash_install: $(STATEDIR)/libflash.install

$(STATEDIR)/libflash.install: $(STATEDIR)/libflash.compile
	@$(call targetinfo, $@)
	@mkdir -p $(INSTALLPATH)/include/flash
	@cp -f -R $(LIBFLASH_DIR)/Lib/*.h $(INSTALLPATH)/include/flash
	@cp -f -R $(LIBFLASH_DIR)/Lib/*.a $(INSTALLPATH)/lib
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libflash_targetinstall: $(STATEDIR)/libflash.targetinstall

libflash_targetinstall_deps = $(STATEDIR)/libflash.compile

$(STATEDIR)/libflash.targetinstall: $(libflash_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libflash_clean:
	rm -rf $(STATEDIR)/libflash.*
	rm -rf $(LIBFLASH_DIR)

# vim: syntax=make
