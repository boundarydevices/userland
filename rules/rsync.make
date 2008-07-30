# -*-makefile-*-
# $Id: rsync.make,v 1.5 2008-07-30 19:34:19 ericn Exp $
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
ifeq (y, $(CONFIG_RSYNC))
PACKAGES += rsync
endif

#
# Paths and names 
#
RSYNC			= rsync-3.0.3
RSYNC_URL 	= http://samba.anu.edu.au/ftp/rsync/$(RSYNC).tar.gz
RSYNC_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(RSYNC).tar.gz
RSYNC_DIR		= $(BUILDDIR)/$(RSYNC)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

rsync_get: $(STATEDIR)/rsync.get

$(STATEDIR)/rsync.get: $(RSYNC_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(RSYNC_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(RSYNC_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

rsync_extract: $(STATEDIR)/rsync.extract

$(STATEDIR)/rsync.extract: $(STATEDIR)/rsync.get
	@$(call targetinfo, $@)
	@$(call clean, $(RSYNC_DIR))
	@cd $(BUILDDIR) && zcat $(RSYNC_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

rsync_prepare: $(STATEDIR)/rsync.prepare

rsync_prepare_deps = \
	$(STATEDIR)/rsync.extract
RSYNC_PATH	= PATH=$(CROSS_PATH)

#
# autoconf
#
RSYNC_AUTOCONF = \
	--host=$(CONFIG_GNU_HOST) \
	--prefix=$(INSTALLPATH) \
	--libexecdir=/usr/sbin \
	--sysconfdir=/etc/ssh \
	--with-privsep-path=/var/run/sshd \
	--without-pam \
	--with-ipv4-default \
	--with-zlib=$(INSTALLPATH) \
	--disable-etc-default-login \
   --includedir=$(INSTALLPATH)/include \
   --datadir=$(INSTALLPATH)/share \
   --mandir=$(INSTALLPATH)/man \
   --infodir=$(INSTALLPATH)/info

$(STATEDIR)/rsync.prepare: $(rsync_prepare_deps)
	@$(call targetinfo, $@)
	cd $(RSYNC_DIR) && \
		$(RSYNC_ENV ) \
		$(CROSS_ENV) \
                $(RSYNC_PATH) ./configure $(RSYNC_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

rsync_compile: $(STATEDIR)/rsync.compile

$(STATEDIR)/rsync.compile: $(STATEDIR)/rsync.prepare 
	@$(call targetinfo, $@)
	cd $(RSYNC_DIR) && $(RSYNC_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

rsync_install: $(STATEDIR)/rsync.install

$(STATEDIR)/rsync.install: $(STATEDIR)/rsync.compile
	@$(call targetinfo, $@)
	cd $(RSYNC_DIR) && $(RSYNC_PATH) make install
	$(RSYNC_PATH) $(CROSSSTRIP) $(INSTALLPATH)/bin/rsync
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

rsync_targetinstall: $(STATEDIR)/rsync.targetinstall

$(STATEDIR)/rsync.targetinstall: $(STATEDIR)/rsync.install
	@$(call targetinfo, $@)
	cp -fv $(INSTALLPATH)/bin/rsync $(ROOTDIR)/bin
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

rsync_clean: 
	rm -rf $(STATEDIR)/rsync.* $(RSYNC_DIR)

# vim: syntax=make
