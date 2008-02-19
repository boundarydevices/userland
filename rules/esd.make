# -*-makefile-*-
# $Id: esd.make,v 1.1 2008-02-19 20:32:44 ericn Exp $
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
ifeq (y, $(CONFIG_ESOUND))
PACKAGES += esound
endif

#
# Paths and names 
#
ESOUND		= esound-0.2.38
ESOUND_URL 	= http://ftp.gnome.org/pub/gnome/sources/esound/0.2/$(ESOUND).tar.bz2
ESOUND_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(ESOUND).tar.bz2
ESOUND_DIR	= $(BUILDDIR)/$(ESOUND)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

esound_get: $(STATEDIR)/esound.get

$(STATEDIR)/esound.get: $(ESOUND_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(ESOUND_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(ESOUND_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

esound_extract: $(STATEDIR)/esound.extract

$(STATEDIR)/esound.extract: $(STATEDIR)/esound.get
	@$(call targetinfo, $@)
	@$(call clean, $(ESOUND_DIR))
	@cd $(BUILDDIR) && bzcat $(ESOUND_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

esound_prepare: $(STATEDIR)/esound.prepare

esound_prepare_deps = \
	$(STATEDIR)/esound.extract

ESOUND_PATH	=  PATH=$(CROSS_PATH)
ESOUND_AUTOCONF 	= --host=$(CONFIG_GNU_HOST)
                    

$(STATEDIR)/esound.prepare: $(esound_prepare_deps)
	@$(call targetinfo, $@)
	cd $(ESOUND_DIR) && \
		$(ESOUND_PATH) \
      $(CROSS_ENV) \
      AUDIOFILE_CFLAGS="-I$(INSTALLPATH)/include -L$(INSTALLPATH)/lib" \
      AUDIOFILE_LIBS="-laudiofile" \
      ESD_DIR=/bin \
		./configure $(ESOUND_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

esound_compile: $(STATEDIR)/esound.compile

$(STATEDIR)/esound.compile: $(STATEDIR)/esound.prepare 
	@$(call targetinfo, $@)
	cd $(ESOUND_DIR) && \
	ESD_DIR=/bin \
        $(ESOUND_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

esound_install: $(STATEDIR)/esound.install

$(STATEDIR)/esound.install: $(STATEDIR)/esound.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)
	cd $(ESOUND_DIR) && $(ESOUND_PATH) DESTDIR=$(INSTALLPATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

esound_targetinstall: $(STATEDIR)/esound.targetinstall

$(STATEDIR)/esound.targetinstall: $(STATEDIR)/esound.install
	@$(call targetinfo, $@)
	@mkdir -p $(ROOTDIR)/sbin
	cp -fv $(INSTALLPATH)/sbin/esound $(ROOTDIR)/sbin && $(CROSSSTRIP) $(ROOTDIR)/sbin/esound
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

esound_clean: 
	rm -rf $(STATEDIR)/esound.* $(ESOUND_DIR)

# vim: syntax=make
