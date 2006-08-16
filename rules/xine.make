# -*-makefile-*-
# $Id: xine.make,v 1.1 2006-08-16 18:41:28 ericn Exp $
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
ifdef CONFIG_LIBXINE
PACKAGES += xine
endif

#
# Paths and names
#
XINE_VERSION   = 1.1.1
XINE	         = xine-lib-$(XINE_VERSION)
XINE_SUFFIX	   = tar.gz
XINE_URLDIR    = http://easynews.dl.sourceforge.net/sourceforge/xine/
XINE_URL		   = $(XINE_URLDIR)/$(XINE).$(XINE_SUFFIX)
XINE_SOURCE	   = $(CONFIG_ARCHIVEPATH)/$(XINE).$(XINE_SUFFIX)
XINE_DIR		   = $(BUILDDIR)/$(XINE)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xine_get: $(STATEDIR)/xine.get

xine_get_deps = $(XINE_SOURCE) 

$(STATEDIR)/xine.get: $(xine_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(XINE_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(XINE_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xine_extract: $(STATEDIR)/xine.extract

xine_extract_deps = $(STATEDIR)/xine.get

$(STATEDIR)/xine.extract: $(xine_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XINE_DIR))
	@cd $(BUILDDIR) && zcat $(XINE_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xine_prepare: $(STATEDIR)/xine.prepare

#
# dependencies
#
xine_prepare_deps = \
	$(STATEDIR)/xine.extract 

XINE_PATH	=  PATH=$(CROSS_PATH):$(XINE_DIR)/misc/xine-config
XINE_ENV 	=  $(CROSS_ENV)
#XINE_ENV	+=

#
# autoconf
#
XINE_AUTOCONF = \
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
   --disable-nls           \
   --disable-altivec       \
   --disable-vis           \
   --disable-mlib          \
   --disable-opengl        \
   --disable-glu           \
   --disable-fb            \
   --disable-v4l           \
   --enable-static-xv      \
   --disable-xinerama      \
   --disable-aalib         \
   --disable-aalibtest     \
   --disable-caca          \
   --disable-cacatest      \
   --disable-fb            \
   --disable-sdl           \
   --disable-sdltest       \
   --disable-polypaudio    \
   --disable-dxr3          \
   --disable-libfametest   \
   --disable-vidix         \
   --disable-ogg       \
   --disable-vorbis    \
   --disable-theora    \
   --disable-speex         \
   --disable-flac          \
   --disable-libFLACtest   \
   --disable-a52dec        \
   --disable-mad           \
   --disable-mng           \
   --disable-imagemagick   \
   --disable-freetype      \
   --disable-oss           \
   --disable-alsa          \
   --disable-alsatest      \
   --disable-esd           \
   --disable-esdtest       \
   --disable-arts          \
   --disable-artstest      \
   --disable-gnome         \
   --disable-samba         \
   --disable-dvdnavtest    \
   --disable-vcd           \
   --disable-asf           \
   --disable-faad          \
   --disable-dts           \
   --disable-fpic          \
   --disable-largefile     \
   --disable-optimizations \
   --disable-min-symtab    \
   --disable-ffmpeg \
   --without-ffmpeg \
   --without-x \
   --with-zlib-prefix=$(INSTALLPATH)

$(STATEDIR)/xine.prepare: $(xine_prepare_deps)
	@$(call targetinfo, $@)
	cd $(XINE_DIR) && \
		$(XINE_PATH) $(XINE_ENV) \
		./configure $(XINE_AUTOCONF)
	touch $@

#
#	cd $(XINE_DIR) && ./bootstrap
# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xine_compile: $(STATEDIR)/xine.compile

xine_compile_deps = $(STATEDIR)/xine.prepare

$(STATEDIR)/xine.compile: $(xine_compile_deps)
	@$(call targetinfo, $@)
	$(XINE_PATH) \
   make -C $(XINE_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xine_install: $(STATEDIR)/xine.install

$(STATEDIR)/xine.install: $(STATEDIR)/xine.compile
	@$(call targetinfo, $@)
	$(XINE_PATH) make -C $(XINE_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xine_targetinstall: $(STATEDIR)/xine.targetinstall

xine_targetinstall_deps = $(STATEDIR)/xine.compile

$(STATEDIR)/xine.targetinstall: $(xine_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xine_clean:
	rm -rf $(STATEDIR)/xine.*
	rm -rf $(XINE_DIR)

# vim: syntax=make
