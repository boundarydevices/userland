# -*-makefile-*-
# $Id: mplayer.make,v 1.19 2008-12-21 20:19:26 ericn Exp $
#
# Copyright (C) 2002 by Pengutronix e.K., Hildesheim, Germany
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifeq (y, $(CONFIG_MPLAYER))
PACKAGES += mplayer
endif

include $(TOPDIR)/.kernelconfig

#
# Paths and names 
#
MPLAYER	        = mplayer-export-2008-02-17
MPLAYER_URL 	= http://www3.mplayerhq.hu/MPlayer/releases/$(MPLAYER).tar.bz2
MPLAYER_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(MPLAYER).tar.bz2
MPLAYER_DIR	= $(BUILDDIR)/mplayer-export-2008-02-17
MPLAYER_PATCH_DATE = 20080217
MPLAYER_PATCHES = $(MPLAYER)-patches-$(MPLAYER_PATCH_DATE).tar.bz2
MPLAYER_PATCH_SOURCE = $(CONFIG_ARCHIVEPATH)/$(MPLAYER_PATCHES)
MPLAYER_PATCH_URL = http://boundarydevices.com/$(MPLAYER_PATCHES)

MPLAYER_PATCH_FILES=$(MPLAYER)-oe.patch \
        $(MPLAYER)-boundary-$(MPLAYER_PATCH_DATE).patch

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------
mplayer_get: $(STATEDIR)/mplayer.get

ifneq (y, $(CONFIG_MPLAYER_GIT))
        $(STATEDIR)/mplayer.get: $(MPLAYER_SOURCE) # $(MPLAYER_PATCH_SOURCE)
		@$(call targetinfo, $@)
		touch $@
        
        $(MPLAYER_SOURCE):
		@$(call targetinfo, $@)
		@cd $(CONFIG_ARCHIVEPATH) && wget $(MPLAYER_URL)
        
#        $(MPLAYER_PATCH_SOURCE):
#		@$(call targetinfo, $@)
#		@cd $(CONFIG_ARCHIVEPATH) && wget $(MPLAYER_PATCH_URL)
else
        $(STATEDIR)/mplayer.get:
		@$(call targetinfo, $@)
		touch $@
endif

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mplayer_extract: $(STATEDIR)/mplayer.extract

ifneq (y, $(CONFIG_MPLAYER_GIT))
        $(STATEDIR)/mplayer.extract: $(STATEDIR)/mplayer.get
		@$(call targetinfo, $@)
		@$(call clean, $(MPLAYER_DIR))
		@cd $(BUILDDIR) && bzcat $(MPLAYER_SOURCE) | tar -xvf -
		sed -i 's|/usr/include|$(INSTALLPATH)/include|g' $(MPLAYER_DIR)/configure
		sed -i 's|/usr/lib|$(INSTALLPATH)/lib|g' $(MPLAYER_DIR)/configure
		sed -i 's|/usr/\S*include[\w/]*||g' $(MPLAYER_DIR)/configure
		sed -i 's|/usr/\S*lib[\w/]*||g' $(MPLAYER_DIR)/configure
#		cd $(MPLAYER_DIR) && tar jxvf $(MPLAYER_PATCH_SOURCE)
#		for f in $(MPLAYER_PATCH_FILES); do \
#			echo "patchfile $$f" ; \
#			cd $(MPLAYER_DIR) && patch -p1 < $$f ; \
#		done
else
        $(STATEDIR)/mplayer.extract:
		@$(call targetinfo, $@)
		@$(call clean, $(MPLAYER_DIR))
		rm -rf $(MPLAYER_DIR)
		@cd $(BUILDDIR) && git-clone office:/repository/$(MPLAYER)
endif
		touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mplayer_prepare: $(STATEDIR)/mplayer.prepare

mplayer_prepare_deps = \
	$(STATEDIR)/mplayer.extract \
	$(STATEDIR)/xvid.install \
        $(STATEDIR)/mad.install \
        $(STATEDIR)/alsa.install
        
MPLAYER_LIBS=
ifeq (y, $(CONFIG_AUDIOFILE))
MPLAYER_LIBS += -laudiofile
mplayer_prepare_deps += $(STATEDIR)/audiofile.install
endif

ifeq (y, $(CONFIG_ESOUND))
MPLAYER_LIBS += -lesd
MPLAYER_ESD = --enable-esd
mplayer_prepare_deps += $(STATEDIR)/esound.install
else
MPLAYER_ESD = --disable-esd
endif

MPLAYER_PATH            = PATH=$(CROSS_PATH)
MPLAYER_AUTOCONF = \
        --enable-cross-compile \
        --cc=$(CONFIG_CROSSPREFIX)-gcc \
        --with-extraincdir="$(INSTALLPATH)/include -I$(INSTALLPATH)/include/directfb -I$(CONFIG_KERNELPATH)/include" \
        --with-extralibdir=$(INSTALLPATH)/lib:$(INSTALLPATH)/usr/local/lib \
        --host-cc=gcc \
        --target=arm-linux \
        --as=$(CONFIG_CROSSPREFIX)-as \
        --enable-fbdev \
	--disable-gui \
	--enable-alsa \
	--disable-linux-devfs \
	--disable-lirc \
	--disable-lircc \
        --disable-joystick \
        --disable-vm \
        --disable-xf86keysym \
	--enable-tv \
        --enable-tv-v4l2 \
        --enable-v4l2 \
        --disable-tv-bsdbt848 \
        --disable-winsock2 \
	--disable-smb \
        --disable-live \
        --disable-dvdread \
        --disable-cdparanoia \
        --disable-menu \
        --disable-fribidi \
        --disable-enca \
        --disable-macosx \
        --disable-macosx-finder-support \
        --disable-macosx-bundle \
        --disable-ftp \
        --disable-vstream \
        --disable-gif \
        --disable-ivtv \
        --disable-libcdio \
        --disable-qtx \
        --disable-xanim \
        --disable-real \
        --disable-libavutil_so \
        --disable-libavcodec_so \
        --disable-libavformat_so \
        --disable-libpostproc_so \
        --disable-speex \
        --disable-theora \
        --disable-faac \
        --disable-ladspa \
        --disable-libdv \
        --disable-toolame \
        --disable-twolame \
        --disable-xmms \
	--disable-mp3lib \
        --disable-musepack \
        --disable-gl \
        --disable-vesa \
        --disable-svga \
        --disable-aa \
        --disable-caca \
        --disable-ggi \
        --disable-ggiwmh \
        --disable-directx \
        --disable-dxr2 \
        --disable-dxr3 \
        --disable-dvb \
        --disable-dvbhead \
        --disable-mga \
        --disable-xmga \
        --disable-xvmc \
        --disable-vm \
        --disable-xinerama \
        --disable-mlib \
        --disable-3dfx \
        --disable-tdfxfb \
        --disable-s3fb \
        --disable-directfb \
        --disable-zr \
        --disable-bl \
        --disable-tdfxvid \
        --disable-tga \
        --disable-pnm \
        --disable-md5sum \
        --disable-arts \
        $(MPLAYER_ESD) \
        --disable-jack \
        --disable-openal \
        --disable-nas \
        --disable-sgiaudio \
        --disable-sunaudio \
        --disable-win32waveout \
        --disable-runtime-cpudetection \
        --disable-tga \
        --disable-x11 \
        --disable-sdl \
        --disable-mencoder \
        --extra-libs="$(MPLAYER_LIBS)"

ifeq (y,$(KERNEL_FB_SM501))
MPLAYER_AUTOCONF += --enable-sm501_bd \
                    --enable-pxa27x
endif

ifeq (y,$(KERNEL_PXA27x))
MPLAYER_AUTOCONF += --enable-iwmmxt \
                    --enable-armpld                    
endif

ifeq (y,$(KERNEL_FB_PXA_YUV))
MPLAYER_AUTOCONF += --enable-pxa27x                    
endif

ifeq (y,$(KERNEL_FB_DAVINCI))
MPLAYER_AUTOCONF += --enable-davinci \
                    --enable-armv5te \
                    --enable-armpld                    
endif

$(STATEDIR)/mplayer.prepare: $(mplayer_prepare_deps)
	@$(call targetinfo, $@)
	cd $(MPLAYER_DIR) && \
		$(MPLAYER_PATH) \
		$(CROSS_ENV) \
		./configure $(MPLAYER_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mplayer_compile: $(STATEDIR)/mplayer.compile

$(STATEDIR)/mplayer.compile: $(STATEDIR)/mplayer.prepare 
	@$(call targetinfo, $@)
	cd $(MPLAYER_DIR) && $(MPLAYER_PATH) BUILD_CC=gcc make all
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mplayer_install: $(STATEDIR)/mplayer.install

$(STATEDIR)/mplayer.install: $(STATEDIR)/mplayer.compile
	@$(call targetinfo, $@)
	echo "--------------------------------------- installing mplayer from $(MPLAYER_DIR)"
	cp -fv $(MPLAYER_DIR)/mplayer $(INSTALLPATH)/bin
	$(CROSSSTRIP) $(INSTALLPATH)/bin/mplayer
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mplayer_targetinstall: $(STATEDIR)/mplayer.targetinstall

$(STATEDIR)/mplayer.targetinstall: $(STATEDIR)/mplayer.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mplayer_clean: 
	rm -rf $(STATEDIR)/mplayer.* $(MPLAYER_DIR)

# vim: syntax=make
