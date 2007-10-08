# -*-makefile-*-
# $Id: ncurses.make,v 1.3 2007-10-08 21:06:10 ericn Exp $
#
# Copyright (C) 2002, 2003 by Pengutronix e.K., Hildesheim, Germany
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifeq (y, $(CONFIG_NCURSES))
PACKAGES += ncurses
endif

#
# Paths and names 
#
NCURSES_VERSION	= 5.3
NCURSES		= ncurses-$(NCURSES_VERSION)
NCURSES_SUFFIX	= tar.gz
NCURSES_URL	= http://ftp.gnu.org/pub/gnu/ncurses/$(NCURSES).$(NCURSES_SUFFIX)
NCURSES_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(NCURSES).$(NCURSES_SUFFIX)
NCURSES_DIR	= $(BUILDDIR)/$(NCURSES)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

ncurses_get: $(STATEDIR)/ncurses.get

$(STATEDIR)/ncurses.get: $(NCURSES_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(NCURSES_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(NCURSES_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

ncurses_extract: $(STATEDIR)/ncurses.extract

$(STATEDIR)/ncurses.extract: $(STATEDIR)/ncurses.get
	@$(call targetinfo, $@)
	@$(call clean, $(NCURSES_DIR))
	@cd $(BUILDDIR) && zcat $(NCURSES_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

ncurses_prepare: $(STATEDIR)/ncurses.prepare

#
# dependencies
#
ncurses_prepare_deps =  \
	$(STATEDIR)/ncurses.extract

NCURSES_PATH	= PATH=$(CROSS_PATH)
NCURSES_ENV 	= $(CROSS_ENV)

#
# RSC: --with-build-cflags: ncurses seems to forget to include it's own
# include directory...
#

NCURSES_AUTOCONF =  $(CROSS_AUTOCONF)
NCURSES_AUTOCONF += \
	--host=$(CONFIG_GNU_HOST) \
	--prefix=$(INSTALLPATH) \
	--exec-prefix=$(INSTALLPATH) \
	--sysconfdir=$(INSTALLPATH)/etc \
	--localstatedir=$(INSTALLPATH)/var \
	--with-shared \
	--disable-nls \
	--disable-rpath \
	--without-ada \
	--enable-const \
	--enable-overwrite \
	--with-terminfo-dirs=$(INSTALLPATH)/usr/share/terminfo \
	--with-default-terminfo-dir=$(INSTALLPATH)/usr/share/terminfo \
	--with-build-cc=$(HOSTCC) \
	--with-build-cflags=-I../include \
	--with-build-ldflags= \
	--with-build-cppflags= \
	--with-install-prefix= \
	--with-build-libs= 

ifndef PTXCONF_CXX
NCURSES_AUTOCONF += --without-cxx-binding
endif

$(STATEDIR)/ncurses.prepare: $(ncurses_prepare_deps)
	@$(call targetinfo, $@)
	cd $(NCURSES_DIR) && \
		$(NCURSES_PATH) $(NCURSES_ENV) \
                DESTDIR='' \
		./configure $(NCURSES_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

ncurses_compile: $(STATEDIR)/ncurses.compile

$(STATEDIR)/ncurses.compile: $(STATEDIR)/ncurses.prepare 
	@$(call targetinfo, $@)
#
# the two tools make_hash and make_keys are compiled for the host system
# these tools are needed later in the compile progress
#
# it's not good to pass target CFLAGS to the host compiler :)
# so override these
#
	cd $(NCURSES_DIR)/ncurses && $(NCURSES_PATH) make CFLAGS='' CXXFLAGS='' make_hash make_keys
	cd $(NCURSES_DIR) && $(NCURSES_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

ncurses_install: $(STATEDIR)/ncurses.install

$(STATEDIR)/ncurses.install: $(STATEDIR)/ncurses.compile
	@$(call targetinfo, $@)
	mkdir -p $(INSTALLPATH)/include/ncurses
	cp -fv $(NCURSES_DIR)/include/*.h $(INSTALLPATH)/include/ncurses
	cp -fv $(NCURSES_DIR)/lib/*.a $(INSTALLPATH)/lib
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

ncurses_targetinstall: $(STATEDIR)/ncurses.targetinstall

$(STATEDIR)/ncurses.targetinstall: $(STATEDIR)/ncurses.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

ncurses_clean: 
	rm -rf $(STATEDIR)/ncurses.* $(NCURSES_DIR)
	rm -rf $(IMAGEDIR)/ncurses_* 

# vim: syntax=make
