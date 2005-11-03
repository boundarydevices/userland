# -*-makefile-*-
# $Id: mad.make,v 1.3 2005-11-03 02:29:35 ericn Exp $
#
# Copyright (C) 2003 by Sascha Hauer <sascha.hauer@gyro-net.de>
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef CONFIG_MAD
PACKAGES += mad
endif

#
# Paths and names
#
MAD_VERSION	= 0.15.1b
MAD		= libmad-$(MAD_VERSION)
MAD_SUFFIX	= tar.gz
MAD_URL		= http://easynews.dl.sourceforge.net/sourceforge/mad/$(MAD).$(MAD_SUFFIX)
MAD_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(MAD).$(MAD_SUFFIX)
MAD_DIR		= $(BUILDDIR)/$(MAD)

ID3_VERSION     = 0.15.1b
ID3             = libid3tag-$(ID3_VERSION)
ID3_SUFFIX	= tar.gz
ID3_URL		= http://easynews.dl.sourceforge.net/sourceforge/mad/$(ID3).$(ID3_SUFFIX)
ID3_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(ID3).$(ID3_SUFFIX)
ID3_DIR		= $(BUILDDIR)/$(ID3)

MADPLAY_VERSION	= 0.15.2b
MADPLAY		= madplay-$(MADPLAY_VERSION)
MADPLAY_SUFFIX	= tar.gz
MADPLAY_URL	= http://easynews.dl.sourceforge.net/sourceforge/mad/$(MADPLAY).$(MADPLAY_SUFFIX)
MADPLAY_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(MADPLAY).$(MADPLAY_SUFFIX)
MADPLAY_DIR	= $(BUILDDIR)/$(MADPLAY)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

mad_get: $(STATEDIR)/mad.get

mad_get_deps = $(MAD_SOURCE) $(ID3_SOURCE) $(MADPLAY_SOURCE)

$(STATEDIR)/mad.get: $(mad_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(MAD_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(MAD_URL)

$(ID3_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(ID3_URL)

$(MADPLAY_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(MADPLAY_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mad_extract: $(STATEDIR)/mad.extract

mad_extract_deps = $(STATEDIR)/mad.get

$(STATEDIR)/mad.extract: $(mad_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MAD_DIR))
	cd $(BUILDDIR) && gzcat $(MAD_SOURCE) | tar -xvf -
	@$(call clean, $(ID3_DIR))
	cd $(BUILDDIR) && gzcat $(ID3_SOURCE) | tar -xvf -
	@$(call clean, $(MADPLAY_DIR))
	cd $(BUILDDIR) && gzcat $(MADPLAY_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mad_prepare: $(STATEDIR)/mad.prepare

#
# dependencies
#
mad_prepare_deps = \
	$(STATEDIR)/mad.extract 

MAD_PATH	=  PATH=$(CROSS_PATH)
MAD_ENV 	=  $(CROSS_ENV)

#
# autoconf
#
MAD_AUTOCONF = \
	--host=$(CONFIG_GNU_TARGET) \
	--prefix=$(INSTALLPATH) \
	--enable-shared=no \
   --exec-prefix=$(INSTALLPATH) \
   --includedir=$(INSTALLPATH)/include \
   --libdir=$(INSTALLPATH)/lib \
   --libexecdir=$(INSTALLPATH)/lib \
   --mandir=$(INSTALLPATH)/man \
   --infodir=$(INSTALLPATH)/info \
   CPPFLAGS="-I$(INSTALLPATH)/include -I$(INSTALLPATH)/include/mad" \
   LDFLAGS="-L$(INSTALLPATH)/lib -lz "   

$(STATEDIR)/mad.prepare: $(mad_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MAD_DIR)/config.cache)
	cd $(MAD_DIR) && \
		$(MAD_PATH) $(MAD_ENV) \
		./configure $(MAD_AUTOCONF)
	@$(call clean, $(ID3_DIR)/config.cache)
	cd $(ID3_DIR) && \
		$(MAD_PATH) $(MAD_ENV) \
		./configure $(MAD_AUTOCONF)
	@$(call clean, $(MADPLAY_DIR)/config.cache)
	cd $(MADPLAY_DIR) && \
		$(MAD_PATH) $(MAD_ENV) \
		./configure $(MAD_AUTOCONF) \
                CPPFLAGS="-I$(INSTALLPATH)/include/mad"
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

mad_compile: $(STATEDIR)/mad.compile

mad_compile_deps = $(STATEDIR)/mad.prepare

$(STATEDIR)/mad.compile: $(mad_compile_deps)
	@$(call targetinfo, $@)
	$(MAD_PATH) make -C $(MAD_DIR) install
	$(MAD_PATH) make -C $(ID3_DIR) install
	$(MAD_PATH) && LDFLAGS=-lz make -C $(MADPLAY_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

mad_install: $(STATEDIR)/mad.install

$(STATEDIR)/mad.install: $(STATEDIR)/mad.compile
	@$(call targetinfo, $@)
	@mkdir -p $(INSTALLPATH)/include/mad
	$(MAD_PATH) make -C $(MAD_DIR) install
	$(MAD_PATH) make -C $(ID3_DIR) install
	$(MAD_PATH) && LDFLAGS=-lz make -C $(MADPLAY_DIR) install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

mad_targetinstall: $(STATEDIR)/mad.targetinstall

mad_targetinstall_deps = $(STATEDIR)/mad.compile

$(STATEDIR)/mad.targetinstall: $(mad_targetinstall_deps)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

mad_clean:
	rm -rf $(STATEDIR)/mad.*
	rm -rf $(MAD_DIR)

# vim: syntax=make
