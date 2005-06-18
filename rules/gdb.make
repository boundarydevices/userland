# -*-makefile-*-
# $Id: gdb.make,v 1.2 2005-06-18 17:03:09 ericn Exp $
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
gdb			= gdb-5.3
gdb_URL 	= ftp://ftp.gnu.org/gnu/gdb/gdb-5.3.tar.gz
gdb_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(gdb).tar.gz
gdb_DIR		= $(BUILDDIR)/$(gdb)
gdb_PATCH   = generic-readline-xcompile.diff
gdb_PATCH_URL	= http://www.pengutronix.de/software/ptxdist/patches-cvs/gdb-5.3/generic/$(gdb_PATCH)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

gdb_get: $(STATEDIR)/gdb.get

$(STATEDIR)/gdb.get: $(gdb_SOURCE)  $(CONFIG_ARCHIVEPATH)/$(gdb_PATCH)
	@$(call targetinfo, $@)
	touch $@

$(gdb_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(gdb_URL)

$(CONFIG_ARCHIVEPATH)/$(gdb_PATCH):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(gdb_PATCH_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

gdb_extract: $(STATEDIR)/gdb.extract

$(STATEDIR)/gdb.extract: $(STATEDIR)/gdb.get
	@$(call targetinfo, $@)
	@$(call clean, $(gdb_DIR))
	@cd $(BUILDDIR) && tar -zxvf $(gdb_SOURCE)
	@cd $(BUILDDIR) && patch -p0 <$(CONFIG_ARCHIVEPATH)/$(gdb_PATCH)
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

gdb_prepare: $(STATEDIR)/gdb.prepare

gdb_prepare_deps = \
	$(STATEDIR)/gdb.extract

gdb_PATH	=  PATH=$(CROSS_PATH)
gdb_AUTOCONF 	= --prefix=$(INSTALLPATH) 
gdb_AUTOCONF  += --target=$(CONFIG_GNU_TARGET)
gdb_AUTOCONF  += --prefix=$(CROSS_LIB_DIR)
gdb_AUTOCONF  += --exec-prefix=$(INSTALLPATH)

$(STATEDIR)/gdb.prepare: $(gdb_prepare_deps)
	@$(call targetinfo, $@)
	cd $(gdb_DIR) && $(gdb_PATH) ./configure $(gdb_AUTOCONF)
	cd $(gdb_DIR)/gdb/gdbserver && chmod a+x configure && $(gdb_PATH) $(CROSS_ENV) ./configure $(gdb_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

gdb_compile: $(STATEDIR)/gdb.compile

$(STATEDIR)/gdb.compile: $(STATEDIR)/gdb.prepare 
	@$(call targetinfo, $@)
	cd $(gdb_DIR) && $(gdb_PATH) make all
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

gdb_install: $(STATEDIR)/gdb.install

$(STATEDIR)/gdb.install: $(STATEDIR)/gdb.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(gdb_DIR) && $(gdb_PATH) make install
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
