# -*-makefile-*-
# $Id: ffmpeg.make,v 1.1 2004-05-31 19:45:32 ericn Exp $
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
FFMPEG_VERSION	= 0.4.8
FFMPEG		= ffmpeg-$(FFMPEG_VERSION)
FFMPEG_SUFFIX		= tar.gz
FFMPEG_URL		= http://easynews.dl.sourceforge.net/sourceforge/ffmpeg/$(FFMPEG).$(FFMPEG_SUFFIX)
FFMPEG_SOURCE		= $(CONFIG_ARCHIVEPATH)/$(FFMPEG).$(FFMPEG_SUFFIX)
FFMPEG_DIR		= $(BUILDDIR)/$(FFMPEG)

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
	@cd $(BUILDDIR) && gzcat $(FFMPEG_SOURCE) | tar -xvf -
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
	--build=$(GNU_HOST) \
	--host=$(CONFIG_GNU_TARGET) \
	--prefix=$(CROSS_LIB_DIR) \
   --cpu=$(CONFIG_FFMPEG_CPU) \
   --strip=$(CROSS_STRIP) \
   --cross-prefix=$(CONFIG_GNU_TARGET)- \
   --enable-shared=no \
   --enable-static=yes \
   --exec-prefix=$(INSTALLPATH) \
   --includedir=$(INSTALLPATH)/include \
   --mandir=$(INSTALLPATH)/man \
   --infodir=$(INSTALLPATH)/info


$(STATEDIR)/ffmpeg.prepare: $(ffmpeg_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(FFMPEG_DIR)/config.cache)
	cd $(FFMPEG_DIR) && \
		$(FFMPEG_PATH) $(FFMPEG_ENV) \
      $(CROSS_ENV_STRIP) \
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
	mkdir -p $(INSTALLPATH)/include/libavformat
	mkdir -p $(INSTALLPATH)/lib
	cp -f $(FFMPEG_DIR)/libavformat/*.h $(INSTALLPATH)/include/libavformat
	cp -f $(FFMPEG_DIR)/libavformat/libavformat.a $(INSTALLPATH)/lib/libavformat.a
	mkdir -p $(INSTALLPATH)/include/libavcodec
	cp -f $(FFMPEG_DIR)/libavcodec/*.h $(INSTALLPATH)/include/libavcodec
	cp -f $(FFMPEG_DIR)/libavcodec/libavcodec.a $(INSTALLPATH)/lib/libavcodec.a
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
