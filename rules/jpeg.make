# -*-makefile-*-
# $Id: jpeg.make,v 1.8 2009-11-29 18:30:58 ericn Exp $
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
ifeq (y, $(CONFIG_JPEG))
PACKAGES += JPEG
endif

#
# Paths and names 
#
JPEG			= JPEG-V7
JPEG_URL 	= http://www.ijg.org/files/jpegsrc.v7.tar.gz
JPEG_SOURCE	= $(CONFIG_ARCHIVEPATH)/jpegsrc.v7.tar.gz
JPEG_DIR		= $(BUILDDIR)/jpeg-7

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

JPEG_get: $(STATEDIR)/JPEG.get

$(STATEDIR)/JPEG.get: $(JPEG_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(JPEG_SOURCE):
	$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(JPEG_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

JPEG_extract: $(STATEDIR)/JPEG.extract

$(STATEDIR)/JPEG.extract: $(STATEDIR)/JPEG.get
	@$(call targetinfo, $@)
	@$(call clean, $(JPEG_DIR))
	cd $(BUILDDIR) && tar -zxvf $(JPEG_SOURCE)
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

JPEG_prepare: $(STATEDIR)/JPEG.prepare

JPEG_prepare_deps = \
	$(STATEDIR)/JPEG.extract

JPEG_PATH	=  PATH=$(CROSS_PATH)
JPEG_AUTOCONF 	=  --enable-shared
JPEG_AUTOCONF 	+= --prefix=$(INSTALLPATH)
JPEG_AUTOCONF	+= --host=$(CONFIG_GNU_HOST)

JPEG_ENV 	=  $(CROSS_ENV)

$(STATEDIR)/JPEG.prepare: $(JPEG_prepare_deps)
	@$(call targetinfo, $@)
	cd $(JPEG_DIR) && \
		$(JPEG_PATH) \
		$(JPEG_ENV) \
		./configure $(JPEG_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

JPEG_compile: $(STATEDIR)/JPEG.compile

$(STATEDIR)/JPEG.compile: $(STATEDIR)/JPEG.prepare 
	@$(call targetinfo, $@)
	cd $(JPEG_DIR) && $(JPEG_PATH) make all
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

JPEG_install: $(STATEDIR)/JPEG.install

$(STATEDIR)/JPEG.install: $(STATEDIR)/JPEG.compile
	@$(call targetinfo, $@)
	cd $(JPEG_DIR) && $(JPEG_PATH) make install
	cd $(JPEG_DIR) && cp -f -v jpeglib.h jerror.h jconfig.h jmorecfg.h $(INSTALLPATH)/include
	mkdir -p $(INSTALLPATH)/lib/pkgconfig/
	$(call makepkgconfig, jpeg, "libJPEG", "7", \
      "-L$(INSTALLPATH)/lib -ljpeg", "-I$(INSTALLPATH)/include", \
      $(INSTALLPATH)/lib/pkgconfig/jpeg.pc )
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

JPEG_targetinstall: $(STATEDIR)/JPEG.targetinstall

$(STATEDIR)/JPEG.targetinstall: $(STATEDIR)/JPEG.install
	@$(call targetinfo, $@)
	mkdir -p $(ROOTDIR)/usr/lib
	cp -d $(JPEG_DIR)/.libs/libjpeg* $(ROOTDIR)/usr/lib/
	$(JPEG_PATH) $(CROSSSTRIP) -R .note -R .comment $(ROOTDIR)/usr/lib/libjpeg.so*
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

JPEG_clean: 
	rm -rf $(STATEDIR)/JPEG.* $(JPEG_DIR)

# vim: syntax=make
