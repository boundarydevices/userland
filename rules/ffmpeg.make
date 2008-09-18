# -*-makefile-*-
# $Id: ffmpeg.make,v 1.5 2008-09-18 00:54:36 ericn Exp $
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
ifdef CONFIG_FFMPEG
PACKAGES += ffmpeg
endif

#
# Paths and names
#
FFMPEG_VERSION	= 20080917-r15352
FFMPEG		= ffmpeg-svn-$(FFMPEG_VERSION)
FFMPEG_SUFFIX		= tar.gz
FFMPEG_URL		= http://boundarydevices.com/archives/$(FFMPEG).$(FFMPEG_SUFFIX)
FFMPEG_SOURCE		= $(CONFIG_ARCHIVEPATH)/$(FFMPEG).$(FFMPEG_SUFFIX)
FFMPEG_DIR		= $(BUILDDIR)/ffmpeg

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ffmpeg_get: $(STATEDIR)/ffmpeg.get

ffmpeg_get_deps = $(FFMPEG_SOURCE)

$(STATEDIR)/ffmpeg.get: $(ffmpeg_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(FFMPEG_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(FFMPEG_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ffmpeg_extract: $(STATEDIR)/ffmpeg.extract

ffmpeg_extract_deps = $(STATEDIR)/ffmpeg.get

$(STATEDIR)/ffmpeg.extract: $(ffmpeg_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FFMPEG_DIR))
	@cd $(BUILDDIR) && zcat $(FFMPEG_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ffmpeg_prepare: $(STATEDIR)/ffmpeg.prepare

#
# dependencies
#
ffmpeg_prepare_deps = \
	$(STATEDIR)/ffmpeg.extract 

FFMPEG_PATH	=  PATH=$(CROSS_PATH)
FFMPEG_ENV 	=  $(CROSS_ENV)
#FFMPEG_ENV	+=

#
# autoconf
#
FFMPEG_AUTOCONF = \
   --arch=armv4l \
   --enable-static \
   --prefix=/usr \
   --disable-decoder=snow \
   --disable-encoder=snow \
   --enable-swscale \
   --enable-gpl \
   --cross-prefix=$(CONFIG_GNU_TARGET)-

$(STATEDIR)/ffmpeg.prepare: $(ffmpeg_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FFMPEG_DIR)/config.cache)
	cd $(FFMPEG_DIR) && \
		$(FFMPEG_PATH) $(FFMPEG_ENV) \
      $(CROSS_ENV_STRIP) \
      CFLAGS="-I$(INSTALLPATH)/include " \
		LDFLAGS="-L$(INSTALLPATH)/lib" \
      ./configure $(FFMPEG_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ffmpeg_compile: $(STATEDIR)/ffmpeg.compile

ffmpeg_compile_deps = $(STATEDIR)/ffmpeg.prepare

$(STATEDIR)/ffmpeg.compile: $(ffmpeg_compile_deps)
	@$(call targetinfo, $@)
	$(FFMPEG_PATH) make -C $(FFMPEG_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ffmpeg_install: $(STATEDIR)/ffmpeg.install

$(STATEDIR)/ffmpeg.install: $(STATEDIR)/ffmpeg.compile
	@$(call targetinfo, $@)
	cd $(FFMPEG_DIR) && make DESTDIR=$(INSTALLPATH) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ffmpeg_targetinstall: $(STATEDIR)/ffmpeg.targetinstall

ffmpeg_targetinstall_deps = $(STATEDIR)/ffmpeg.compile

$(STATEDIR)/ffmpeg.targetinstall: $(ffmpeg_targetinstall_deps)
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ffmpeg_clean:
	rm -rf $(STATEDIR)/ffmpeg.*
	rm -rf $(FFMPEG_DIR)

# vim: syntax=make
