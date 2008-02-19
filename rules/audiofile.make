# -*-makefile-*-
# $Id: audiofile.make,v 1.1 2008-02-19 20:32:44 ericn Exp $
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
ifeq (y, $(CONFIG_AUDIOFILE))
PACKAGES += audiofile
endif

#
# Paths and names 
#
AUDIOFILE		= audiofile-0.2.6
AUDIOFILE_URL 		= http://ftp.acc.umu.se/pub/gnome/sources/audiofile/0.2/$(AUDIOFILE).tar.bz2
AUDIOFILE_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(AUDIOFILE).tar.bz2
AUDIOFILE_DIR		= $(BUILDDIR)/$(AUDIOFILE)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

audiofile_get: $(STATEDIR)/audiofile.get

$(STATEDIR)/audiofile.get: $(AUDIOFILE_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(AUDIOFILE_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(AUDIOFILE_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

audiofile_extract: $(STATEDIR)/audiofile.extract

$(STATEDIR)/audiofile.extract: $(STATEDIR)/audiofile.get
	@$(call targetinfo, $@)
	@$(call clean, $(AUDIOFILE_DIR))
	@cd $(BUILDDIR) && bzcat $(AUDIOFILE_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

audiofile_prepare: $(STATEDIR)/audiofile.prepare

audiofile_prepare_deps = \
	$(STATEDIR)/audiofile.extract

AUDIOFILE_PATH	=  PATH=$(CROSS_PATH)
AUDIOFILE_AUTOCONF 	= --prefix=$(INSTALLPATH) \
                    --host=$(CONFIG_GNU_HOST)

$(STATEDIR)/audiofile.prepare: $(audiofile_prepare_deps)
	@$(call targetinfo, $@)
	cd $(AUDIOFILE_DIR) && \
		$(AUDIOFILE_PATH) \
      $(CROSS_ENV) \
		./configure $(AUDIOFILE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

audiofile_compile: $(STATEDIR)/audiofile.compile

$(STATEDIR)/audiofile.compile: $(STATEDIR)/audiofile.prepare 
	@$(call targetinfo, $@)
	cd $(AUDIOFILE_DIR) && $(AUDIOFILE_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

audiofile_install: $(STATEDIR)/audiofile.install

$(STATEDIR)/audiofile.install: $(STATEDIR)/audiofile.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(AUDIOFILE_DIR) && $(AUDIOFILE_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

audiofile_targetinstall: $(STATEDIR)/audiofile.targetinstall

$(STATEDIR)/audiofile.targetinstall: $(STATEDIR)/audiofile.install
	@$(call targetinfo, $@)
	@mkdir -p $(ROOTDIR)/sbin
	cp -fv $(INSTALLPATH)/sbin/audiofile $(ROOTDIR)/sbin && $(CROSSSTRIP) $(ROOTDIR)/sbin/audiofile
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

audiofile_clean: 
	rm -rf $(STATEDIR)/audiofile.* $(AUDIOFILE_DIR)

# vim: syntax=make
