# -*-makefile-*-
# $Id: mad.make,v 1.16 2009-11-27 17:19:50 ericn Exp $
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

ifdef CONFIG_MADPLAY
PACKAGES += madplay
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

mad_get_deps = $(MAD_SOURCE) $(ID3_SOURCE)

$(STATEDIR)/mad.get: $(mad_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(MAD_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(MAD_URL)

$(ID3_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(ID3_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

mad_extract: $(STATEDIR)/mad.extract

mad_extract_deps = $(STATEDIR)/mad.get

$(STATEDIR)/mad.extract: $(mad_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(MAD_DIR))
	cd $(BUILDDIR) && zcat $(MAD_SOURCE) | tar -xvf -
	cd $(MAD_DIR) && sed -i 's/.*force-mem.*//' configure
	@$(call clean, $(ID3_DIR))
	cd $(BUILDDIR) && zcat $(ID3_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

mad_prepare: $(STATEDIR)/mad.prepare

#
# dependencies
#
mad_prepare_deps = \
   $(STATEDIR)/zlib.install \
	$(STATEDIR)/mad.extract 

MAD_PATH	=  PATH=$(CROSS_PATH)
MAD_ENV 	=  $(CROSS_ENV)

#
# autoconf
#
MAD_AUTOCONF = \
	--host=$(CONFIG_GNU_HOST) \
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


# ----------------------------------------------------------------------------
# madplay stuff (Not yet fully implemented)
# ----------------------------------------------------------------------------

madplay_get_deps: $(MADPLAY_SOURCE)

madplay_get: $(madplay_get_deps)

$(MADPLAY_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(MADPLAY_URL)
	touch $@

madplay_extract: $(STATEDIR)/mad.extract

$(STATEDIR)/madplay.extract: $(MADPLAY_SOURCE)
	@$(call targetinfo, $@)
	@$(call clean, $(MADPLAY_DIR))
	cd $(BUILDDIR) && zcat $(MADPLAY_SOURCE) | tar -xvf -
	touch $@

madplay_prepare: $(STATEDIR)/mad.install $(STATEDIR)/madplay.prepare

$(STATEDIR)/madplay.prepare: $(STATEDIR)/madplay.extract $(STATEDIR)/mad.install
	@$(call targetinfo, $@)
	@$(call clean, $(MADPLAY_DIR)/config.cache)
	cd $(MADPLAY_DIR) && \
		$(MAD_PATH) $(MAD_ENV) \
      CCFLAGS="-I$(INSTALLPATH)/include" \
      CPPFLAGS="-I$(INSTALLPATH)/include" \
      LDFLAGS="-L$(INSTALLPATH)/lib -lid3tag" \
		./configure $(MAD_AUTOCONF)
	touch $@

madplay_compile: $(STATEDIR)/madplay.compile

$(STATEDIR)/madplay.compile: $(STATEDIR)/madplay.prepare
	@$(call targetinfo, $@)
	$(MAD_PATH) && LDFLAGS=-lz make -C $(MADPLAY_DIR)
	touch $@

madplay_install: $(STATEDIR)/madplay.install

$(STATEDIR)/madplay.install: $(STATEDIR)/madplay.compile
	@$(call targetinfo, $@)
	$(MAD_PATH) && LDFLAGS=-lz make -C $(MADPLAY_DIR) install
	touch $@

madplay_targetinstall: $(STATEDIR)/madplay.targetinstall

$(STATEDIR)/madplay.targetinstall: $(STATEDIR)/madplay.install
	@$(call targetinfo, $@)
	cp $(INSTALLPATH)/bin/madplay $(ROOTDIR)/bin
	PATH=$(CROSS_PATH) $(CROSSSTRIP) $(ROOTDIR)/bin/madplay
	touch $@

madplay_clean: $(STATEDIR)/madplay.clean

$(STATEDIR)/madplay.clean:
	@$(call targetinfo, $@)
	rm -rf $(STATEDIR)/madplay.* $(MADPLAY_DIR)

# vim: syntax=make
