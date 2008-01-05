# -*-makefile-*-
# $Id: mplayer.make,v 1.8 2008-01-05 22:37:21 ericn Exp $
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

#
# Paths and names 
#
MPLAYER	        = MPlayer-1.0rc1
MPLAYER_URL 	= http://www3.mplayerhq.hu/MPlayer/releases/$(MPLAYER).tar.bz2
MPLAYER_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(MPLAYER).tar.bz2
MPLAYER_DIR	= $(BUILDDIR)/$(MPLAYER)
MPLAYER_PATCH_DATE = 20070819
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
        $(STATEDIR)/mplayer.get: $(MPLAYER_SOURCE) $(MPLAYER_PATCH_SOURCE)
		@$(call targetinfo, $@)
		touch $@
        
        $(MPLAYER_SOURCE):
		@$(call targetinfo, $@)
		@cd $(CONFIG_ARCHIVEPATH) && wget $(MPLAYER_URL)
        
        $(MPLAYER_PATCH_SOURCE):
		@$(call targetinfo, $@)
		@cd $(CONFIG_ARCHIVEPATH) && wget $(MPLAYER_PATCH_URL)
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
		cd $(MPLAYER_DIR) && tar jxvf $(MPLAYER_PATCH_SOURCE)
		for f in $(MPLAYER_PATCH_FILES); do \
			echo "patchfile $$f" ; \
			cd $(MPLAYER_DIR) && patch -p1 < $$f ; \
		done
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
        

MPLAYER_PATH            = PATH=$(CROSS_PATH)
MPLAYER_AUTOCONF = \
        --enable-cross-compile \
        --cc=$(CONFIG_CROSSPREFIX)-gcc \
        --with-extraincdir="$(INSTALLPATH)/include -I$(INSTALLPATH)/include/directfb -I$(CONFIG_KERNELPATH)/include" \
        --with-extralibdir=$(INSTALLPATH)/lib \
        --host-cc=gcc \
        --target=arm-linux \
        --as=$(CONFIG_CROSSPREFIX)-as \
        --enable-fbdev \
        --enable-static="-lncurses" \
	--disable-gui \
	--disable-alsa \
	--disable-linux-devfs \
	--disable-lirc \
	--disable-lircc \
        --disable-joystick \
        --disable-vm \
        --disable-xf86keysym \
	--disable-tv \
        --disable-tv-v4l2 \
        --disable-tv-bsdbt848 \
        --disable-winsock2 \
	--disable-smb \
        --disable-live \
        --disable-dvdread \
        --disable-mpdvdkit \
        --disable-cdparanoia \
        --disable-unrarlib \
        --disable-menu \
        --disable-fribidi \
        --disable-enca \
        --disable-macosx \
        --disable-macosx-finder-support \
        --disable-macosx-bundle \
        --disable-ftp \
        --disable-vstream \
        --disable-gif \
        --disable-libcdio \
	--disable-win32 \
        --disable-qtx \
        --disable-xanim \
        --disable-real \
        --disable-libavutil_so \
        --disable-libavcodec_so \
        --disable-libavformat_so \
        --disable-libpostproc_so \
        --disable-libfame \
        --disable-speex \
        --disable-theora \
        --disable-faac \
        --disable-ladspa \
        --disable-libdv \
        --disable-toolame \
        --disable-twolame \
        --disable-xmms \
	--disable-mp3lib \
        --disable-libdts \
        --disable-musepack \
        --disable-amr_nb \
        --disable-amr_nb-fixed \
        --disable-amr_wb \
        --disable-gl \
        --disable-dga \
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
        --disable-esd \
        --disable-polyp \
        --disable-jack \
        --disable-openal \
        --disable-nas \
        --disable-sgiaudio \
        --disable-sunaudio \
        --disable-win32waveout \
        --disable-runtime-cpudetection \
        --disable-tga \
        --disable-x11

ifeq (y,$(KERNEL_FB_SM501))
MPLAYER_AUTOCONF += --enable-sm501_bd
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
	install -d $(INSTALLPATH)/include
	cd $(MPLAYER_DIR) && make DESTDIR=$(INSTALLPATH) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mplayer_targetinstall: $(STATEDIR)/mplayer.targetinstall

$(STATEDIR)/mplayer.targetinstall: $(STATEDIR)/mplayer.install
	@$(call targetinfo, $@)
	@mkdir -p $(ROOTDIR)/bin
	cp -fv $(INSTALLPATH)/usr/local/bin/mplayer $(ROOTDIR)/bin && $(CROSSSTRIP) $(ROOTDIR)/bin/mplayer
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mplayer_clean: 
	rm -rf $(STATEDIR)/mplayer.* $(MPLAYER_DIR)

# vim: syntax=make
