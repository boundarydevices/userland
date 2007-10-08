# -*-makefile-*-
# $Id: libevent.make,v 1.3 2007-10-08 21:06:10 ericn Exp $
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
ifeq (y, $(CONFIG_ALSA_UTILS))
PACKAGES += libevent
endif

#
# Paths and names 
#
LIBEVENT		= libevent-1.1a
LIBEVENT_URL 	        = http://www.monkey.org/~provos/$(LIBEVENT).tar.gz
LIBEVENT_SOURCE	        = $(CONFIG_ARCHIVEPATH)/$(LIBEVENT).tar.gz
LIBEVENT_DIR		= $(BUILDDIR)/$(LIBEVENT)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libevent_get: $(STATEDIR)/libevent.get

$(STATEDIR)/libevent.get: $(LIBEVENT_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(LIBEVENT_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(LIBEVENT_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libevent_extract: $(STATEDIR)/libevent.extract

$(STATEDIR)/libevent.extract: $(STATEDIR)/libevent.get
	@$(call targetinfo, $@)
	@$(call clean, $(LIBEVENT_DIR))
	@cd $(BUILDDIR) && zcat $(LIBEVENT_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libevent_prepare: $(STATEDIR)/libevent.prepare alsa_install ncurses_install

libevent_prepare_deps = \
	$(STATEDIR)/libevent.extract

LIBEVENT_PATH = PATH=$(CROSS_PATH)

LIBEVENT_AUTOCONF = \
	--host=$(CONFIG_GNU_HOST) \
	--prefix=$(INSTALLPATH) \
	--enable-shared=no \
   --exec-prefix=$(INSTALLPATH) \
   --includedir=$(INSTALLPATH)/include \
   --libdir=$(INSTALLPATH)/lib \
   --libexecdir=$(INSTALLPATH)/lib \
   --mandir=$(INSTALLPATH)/man \
   --infodir=$(INSTALLPATH)/info

$(STATEDIR)/libevent.prepare: $(libevent_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBEVENT_DIR)/config.cache)
	cd $(LIBEVENT_DIR) && aclocal && autoconf && automake --add-missing
	cd $(LIBEVENT_DIR) && \
		$(LIBEVENT_PATH) \
      $(CROSS_ENV) \
		./configure $(LIBEVENT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libevent_compile: $(STATEDIR)/libevent.compile

$(STATEDIR)/libevent.compile: $(STATEDIR)/libevent.prepare 
	@$(call targetinfo, $@)
	cd $(LIBEVENT_DIR) && $(LIBEVENT_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libevent_install: $(STATEDIR)/libevent.install

$(STATEDIR)/libevent.install: $(STATEDIR)/libevent.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(LIBEVENT_DIR) && $(LIBEVENT_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libevent_targetinstall: $(STATEDIR)/libevent.targetinstall

$(STATEDIR)/libevent.targetinstall: $(STATEDIR)/libevent.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libevent_clean: 
	rm -rf $(STATEDIR)/libevent.* $(LIBEVENT_DIR)

# vim: syntax=make
