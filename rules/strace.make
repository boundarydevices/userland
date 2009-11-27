# -*-makefile-*-
# $Id: strace.make,v 1.6 2009-11-27 19:58:00 ericn Exp $
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
ifeq (y, $(CONFIG_STRACE))
PACKAGES += strace
endif

#
# Paths and names 
#
STRACE			= strace-4.5.19
STRACE_URL 	= http://easynews.dl.sourceforge.net/sourceforge/strace/$(STRACE).tar.bz2
STRACE_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(STRACE).tar.bz2
STRACE_DIR		= $(BUILDDIR)/$(STRACE)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

strace_get: $(STATEDIR)/strace.get

$(STATEDIR)/strace.get: $(STRACE_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(STRACE_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(STRACE_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

strace_extract: $(STATEDIR)/strace.extract

$(STATEDIR)/strace.extract: $(STATEDIR)/strace.get
	@$(call targetinfo, $@)
	@$(call clean, $(STRACE_DIR))
	@cd $(BUILDDIR) && bzcat $(STRACE_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

strace_prepare: $(STATEDIR)/strace.prepare

strace_prepare_deps = \
	$(STATEDIR)/strace.extract

STRACE_PATH = PATH=$(CROSS_PATH)

STRACE_AUTOCONF = \
	--host=$(CONFIG_GNU_HOST) \
	--prefix=$(INSTALLPATH) \
   --exec-prefix=$(INSTALLPATH) \
   --includedir=$(INSTALLPATH)/include \
   --mandir=$(INSTALLPATH)/man \
   --exec-prefix=/usr \
   --bindir=/usr/bin \
   --sbindir=/usr/sbin \
   --libexecdir=/usr/lib \
   --sysconfdir=/etc \
   --datadir=/usr/share \
   --localstatedir=/var \
   --mandir=/usr/man \
   --infodir=/usr/info

$(STATEDIR)/strace.prepare: $(strace_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(STRACE_DIR)/config.cache)
	cd $(STRACE_DIR) && \
		$(STRACE_PATH) \
      $(CROSS_ENV) \
		./configure $(STRACE_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

strace_compile: $(STATEDIR)/strace.compile

$(STATEDIR)/strace.compile: $(STATEDIR)/strace.prepare 
	@$(call targetinfo, $@)
	cd $(STRACE_DIR) && $(STRACE_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

strace_install: $(STATEDIR)/strace.install

$(STATEDIR)/strace.install: $(STATEDIR)/strace.compile
	@$(call targetinfo, $@)
	mkdir -p $(INSTALLPATH)/usr/bin/
	install -c $(STRACE_DIR)/strace $(INSTALLPATH)/usr/bin/strace
	PATH=$(CROSS_PATH) $(CROSSSTRIP) $(INSTALLPATH)/usr/bin/strace > /dev/null 2>&1   
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

strace_targetinstall: $(STATEDIR)/strace.targetinstall

$(STATEDIR)/strace.targetinstall: $(STATEDIR)/strace.install
	@$(call targetinfo, $@)
	cp -fv $(INSTALLPATH)/usr/bin/strace $(ROOTDIR)/bin
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

strace_clean: 
	rm -rf $(STATEDIR)/strace.* $(STRACE_DIR)

# vim: syntax=make
