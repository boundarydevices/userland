# -*-makefile-*-
# $Id: gdb.make,v 1.6 2009-06-16 00:32:04 ericn Exp $
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
ifeq (y, $(CONFIG_gdb))
PACKAGES += gdb
endif

#
# Paths and names 
#
gdb			= gdb-6.6
gdb_URL 	= ftp://ftp.gnu.org/gnu/gdb/$(gdb).tar.gz
gdb_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(gdb).tar.gz
gdb_DIR		= $(BUILDDIR)/$(gdb)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gdb_get: $(STATEDIR)/gdb.get

$(STATEDIR)/gdb.get: $(gdb_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(gdb_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(gdb_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gdb_extract: $(STATEDIR)/gdb.extract

$(STATEDIR)/gdb.extract: $(STATEDIR)/gdb.get
	@$(call targetinfo, $@)
	@$(call clean, $(gdb_DIR))
	@cd $(BUILDDIR) && tar -zxvf $(gdb_SOURCE)
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gdb_prepare: $(STATEDIR)/gdb.prepare

gdb_prepare_deps = \
	$(STATEDIR)/gdb.extract

GDB_TARGET_CONFIGURE_VARS:= \
	ac_cv_type_uintptr_t=yes \
	gt_cv_func_gettext_libintl=yes \
	ac_cv_func_dcgettext=yes \
	gdb_cv_func_sigsetjmp=yes \
	bash_cv_func_strcoll_broken=no \
	bash_cv_must_reinstall_sighandlers=no \
	bash_cv_func_sigsetjmp=present \
	bash_cv_have_mbstate_t=yes

gdb_PATH	=  PATH=$(CROSS_PATH)
gdb_AUTOCONF 	= \
	--host=$(CONFIG_GNU_TARGET) \
	--target=$(CONFIG_GNU_TARGET) \
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
   --infodir=/usr/info \
	--without-uiout \
	--disable-tui --disable-gdbtk --without-x \
	--disable-sim --disable-gdbserver \
	--without-included-gettext
      
gdbserver_AUTOCONF 	= \
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
   --infodir=/usr/info \
	--without-uiout \
	--disable-tui --disable-gdbtk --without-x \
	--disable-sim --enable-gdbserver \
	--without-included-gettext

#
# There appears to be a bug/issue in the makefiles for gdb
# that require (re)configuration between compilation of the
# cross-compiled gdbserver and the natively compiled gdb
#      

$(STATEDIR)/gdb.prepare: $(gdb_prepare_deps)
	@$(call targetinfo, $@)
	touch $@
   
# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gdb_compile: $(STATEDIR)/gdb.compile

$(STATEDIR)/gdb.compile: $(STATEDIR)/gdb.prepare 
	@$(call targetinfo, $@)
	cd $(gdb_DIR)/libiberty && $(GDB_TARGET_CONFIGURE_VARS) $(gdb_PATH) $(CROSS_ENV) ./configure $(gdb_AUTOCONF)
	cd $(gdb_DIR) && $(GDB_TARGET_CONFIGURE_VARS) $(gdb_PATH) $(CROSS_ENV) ./configure $(gdb_AUTOCONF)
	cd $(gdb_DIR)/intl && noconfigdirs=target-libiberty $(GDB_TARGET_CONFIGURE_VARS) $(gdb_PATH) $(CROSS_ENV) ./configure $(gdb_AUTOCONF)
	cd $(gdb_DIR) && $(gdb_PATH) $(CROSS_ENV) make all
	cd $(gdb_DIR)/gdb/gdbserver && make realclean && chmod a+x configure && $(GDB_TARGET_CONFIGURE_VARS) $(gdb_PATH) $(CROSS_ENV) ./configure $(gdbserver_AUTOCONF)
	cd $(gdb_DIR)/gdb/gdbserver && $(CROSS_ENV) $(gdb_PATH) make all
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gdb_install: $(STATEDIR)/gdb.install

$(STATEDIR)/gdb.install: $(STATEDIR)/gdb.compile
	@$(call targetinfo, $@)
	mkdir -p $(TOPDIR)/tools
	cd $(gdb_DIR) && install -c gdb/gdb $(TOPDIR)/tools/gdb
	cd $(gdb_DIR) && install -c gdb/gdbserver/gdbserver $(INSTALLPATH)/bin/gdbserver
#	cd $(gdb_DIR) && $(gdb_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

gdb_targetinstall: $(STATEDIR)/gdb.targetinstall

$(STATEDIR)/gdb.targetinstall: $(STATEDIR)/gdb.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

gdb_clean: 
	rm -rf $(STATEDIR)/gdb.* $(gdb_DIR)

# vim: syntax=make
