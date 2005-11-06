# -*-makefile-*-
# $Id: jpeg.make,v 1.6 2005-11-06 17:52:34 ericn Exp $
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
JPEG			= JPEG-1.1.4
JPEG_URL 	= ftp://ftp.uu.net/graphics/jpeg/jpegsrc.v6b.tar.gz
JPEG_SOURCE	= $(CONFIG_ARCHIVEPATH)/jpegsrc.v6b.tar.gz
JPEG_DIR		= $(BUILDDIR)/jpeg-6b
JPEG_PATCH_URL = http://boundarydevices.com/jpeg-6b.patch
JPEG_PATCH_SOURCE	= $(CONFIG_ARCHIVEPATH)/jpeg-6b.patch

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

JPEG_get: $(STATEDIR)/JPEG.get

$(STATEDIR)/JPEG.get: $(JPEG_SOURCE) $(JPEG_PATCH_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(JPEG_SOURCE):
	$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(JPEG_URL)

$(JPEG_PATCH_SOURCE):
	$(call targetinfo, $@)
	$(shell ls -l $(CONFIG_ARCHIVEPATH)/jpeg*)
	cd $(CONFIG_ARCHIVEPATH) && wget $(JPEG_PATCH_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

JPEG_extract: $(STATEDIR)/JPEG.extract

$(STATEDIR)/JPEG.extract: $(STATEDIR)/JPEG.get
	@$(call targetinfo, $@)
	@$(call clean, $(JPEG_DIR))
	cd $(BUILDDIR) && tar -zxvf $(JPEG_SOURCE)
	patch -d $(BUILDDIR) -p0 < $(JPEG_PATCH_SOURCE)
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
JPEG_AUTOCONF	+= --host=$(CONFIG_GNU_TARGET)
JPEG_AUTOCONF	+= --target=$(CONFIG_GNU_TARGET)
JPEG_AUTOCONF	+= --exec-prefix=$(INSTALLPATH) \
                  --includedir=$(INSTALLPATH)/include \
                  --mandir=$(INSTALLPATH)/man \
                  --infodir=$(INSTALLPATH)/info

JPEG_ENV 	=  $(CROSS_ENV)

$(STATEDIR)/JPEG.prepare: $(JPEG_prepare_deps)
	@$(call targetinfo, $@)
	cd $(JPEG_DIR) && \
		$(JPEG_PATH) \
		$(JPEG_ENV) \
		./configure $(JPEG_AUTOCONF)
#	perl -i -p -e 's/=gcc/=$(CONFIG_GNU_TARGET)-gcc/g' $(JPEG_DIR)/Makefile
#  perl -i -p -e 's/=ar/=$(CONFIG_GNU_TARGET)-ar/g' $(JPEG_DIR)/Makefile
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
	cd $(JPEG_DIR) && $(JPEG_PATH) make install-lib
	cd $(JPEG_DIR) && cp -f -v jpeglib.h jerror.h jconfig.h jmorecfg.h $(INSTALLPATH)/include
	mkdir -p $(INSTALLPATH)/lib/pkgconfig/
	$(call makepkgconfig, jpeg, "libJPEG", "6B", \
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
