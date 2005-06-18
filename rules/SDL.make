# -*-makefile-*-
# $Id: SDL.make,v 1.1 2005-06-18 16:36:28 ericn Exp $
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
ifeq (y, $(CONFIG_SDL))
PACKAGES += zlib
endif

#
# Paths and names 
#
SDL = SDL-1.2.8
SDL_URL = http://www.libsdl.org/release/$(SDL).tar.gz
SDL_SOURCE = $(CONFIG_ARCHIVEPATH)/$(SDL).tar.gz
SDL_DIR = $(BUILDDIR)/$(SDL)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

sdl_get: $(STATEDIR)/sdl.get

$(STATEDIR)/sdl.get: $(SDL_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(SDL_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(SDL_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

sdl_extract: $(STATEDIR)/sdl.extract

$(STATEDIR)/sdl.extract: $(STATEDIR)/sdl.get
	@$(call targetinfo, $@)
	@$(call clean, $(SDL_DIR))
	@cd $(BUILDDIR) && gzcat $(SDL_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

sdl_prepare: $(STATEDIR)/sdl.prepare

sdl_prepare_deps = \
	$(STATEDIR)/sdl.extract

SDL_PATH	=  PATH=$(CROSS_PATH)
SDL_AUTOCONF = --host=$(CONFIG_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR)

ifdef CONFIG_SDL_SHARED
   SDL_AUTOCONF 	+=  --enable-shared=yes
else
   SDL_AUTOCONF 	+=  --enable-shared=no
   SDL_AUTOCONF 	+=  --enable-static=yes
endif

SDL_AUTOCONF += --enable-shared=no 
SDL_AUTOCONF += --enable-static=yes 
SDL_AUTOCONF += --enable-debug=no 
SDL_AUTOCONF += --enable-audio=yes 
SDL_AUTOCONF += --enable-video=yes 
SDL_AUTOCONF += --enable-events=yes 
SDL_AUTOCONF += --enable-joystick=no 
SDL_AUTOCONF += --enable-cdrom=no 
SDL_AUTOCONF += --enable-threads=yes 
SDL_AUTOCONF += --enable-timers=yes 
SDL_AUTOCONF += --enable-endian=yes 
SDL_AUTOCONF += --enable-file=yes 
SDL_AUTOCONF += --enable-cpuinfo=no 
SDL_AUTOCONF += --enable-oss=yes 
SDL_AUTOCONF += --enable-alsa=no 
SDL_AUTOCONF += --enable-alsa-shared=no 
SDL_AUTOCONF += --enable-esd=no 
SDL_AUTOCONF += --enable-esd-shared=no 
SDL_AUTOCONF += --enable-arts=no 
SDL_AUTOCONF += --enable-arts-shared=no 
SDL_AUTOCONF += --enable-nas=no 
SDL_AUTOCONF += --enable-diskaudio=no 
SDL_AUTOCONF += --enable-mintaudio=no 
SDL_AUTOCONF += --enable-nasm=no 
SDL_AUTOCONF += --enable-video-x11=no 
SDL_AUTOCONF += --enable-video-x11-vm=no 
SDL_AUTOCONF += --enable-dga=no 
SDL_AUTOCONF += --enable-video-x11-dgamouse=no 
SDL_AUTOCONF += --enable-video-x11-xv=no 
SDL_AUTOCONF += --enable-video-x11-xinerama=no 
SDL_AUTOCONF += --enable-video-x11-xme=no 
SDL_AUTOCONF += --enable-video-dga=no 
SDL_AUTOCONF += --enable-video-photon=no 
SDL_AUTOCONF += --enable-video-fbcon=yes 
SDL_AUTOCONF += --enable-video-ps2gs=no 
SDL_AUTOCONF += --enable-video-xbios=no 
SDL_AUTOCONF += --enable-video-gem=no 
SDL_AUTOCONF += --enable-video-dummy=no 
SDL_AUTOCONF += --enable-video-opengl=no 
SDL_AUTOCONF += --enable-osmesa-shared=no 
SDL_AUTOCONF += --enable-input-events=yes 
SDL_AUTOCONF += --enable-pth=no 
SDL_AUTOCONF += --enable-pthreads=yes 
SDL_AUTOCONF += --enable-pthread-sem=yes 
SDL_AUTOCONF += --enable-sigaction=yes 
SDL_AUTOCONF += --enable-stdio-redirect=no 
SDL_AUTOCONF += --enable-directx=no 
SDL_AUTOCONF += --enable-sdl-dlopen=yes 
SDL_AUTOCONF += --enable-atari-ldg=no 

$(STATEDIR)/sdl.prepare: $(sdl_prepare_deps)
	@$(call targetinfo, $@)
	cd $(SDL_DIR) && \
		$(SDL_PATH) \
      $(CROSS_ENV) \
      ./configure $(SDL_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

sdl_compile: $(STATEDIR)/sdl.compile

$(STATEDIR)/sdl.compile: $(STATEDIR)/sdl.prepare 
	@$(call targetinfo, $@)
	cd $(SDL_DIR) && $(SDL_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

sdl_install: $(STATEDIR)/sdl.install

$(STATEDIR)/sdl.install: $(STATEDIR)/sdl.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(SDL_DIR) && $(SDL_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

sdl_targetinstall: $(STATEDIR)/sdl.targetinstall

$(STATEDIR)/sdl.targetinstall: $(STATEDIR)/sdl.install
	@$(call targetinfo, $@)
	@mkdir -p $(ROOTDIR)/usr/lib
ifdef CONFIG_SDL_SHARED
	@cp -d $(SDL_DIR)/libz.so* $(ROOTDIR)/usr/lib/
	@$(SDL_PATH) $(CROSSSTRIP) -R .note -R .comment $(ROOTDIR)/usr/lib/libz.so*
endif
	@cp -d $(SDL_DIR)/libz.a $(ROOTDIR)/usr/lib/
	@$(SDL_PATH) $(CROSSSTRIP) -R .note -R .comment $(ROOTDIR)/usr/lib/libz.a
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

sdl_clean: 
	rm -rf $(STATEDIR)/sdl.* $(SDL_DIR)

# vim: syntax=make
