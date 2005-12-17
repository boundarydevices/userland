# -*-makefile-*-
# $Id: glib.make,v 1.5 2005-12-17 19:41:06 ericn Exp $
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
ifeq (y, $(CONFIG_GLIB))
PACKAGES += glib
endif

#
# Paths and names 
#
GLIB			= glib-2.6.5
GLIB_URL 	= ftp://ftp.gtk.org/pub/gtk/v2.6/$(GLIB).tar.gz
GLIB_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(GLIB).tar.gz
GLIB_DIR		= $(BUILDDIR)/$(GLIB)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

glib_get: $(STATEDIR)/glib.get

$(STATEDIR)/glib.get: $(GLIB_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(GLIB_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(GLIB_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

glib_extract: $(STATEDIR)/glib.extract

$(STATEDIR)/glib.extract: $(STATEDIR)/glib.get
	@$(call targetinfo, $@)
	@$(call clean, $(GLIB_DIR))
	@cd $(BUILDDIR) && zcat $(GLIB_SOURCE) | tar -xvf -
	sed 's/#include "glib.h"/#include "bits\/posix1_lim.h"\n#include "glib.h"/' \
	< $(GLIB_DIR)/glib/giounix.c \
	> $(GLIB_DIR)/glib/giounix.c.patched
	cp $(GLIB_DIR)/glib/giounix.c $(GLIB_DIR)/glib/giounix.c.orig
	cp $(GLIB_DIR)/glib/giounix.c.patched $(GLIB_DIR)/glib/giounix.c
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

glib_prepare: $(STATEDIR)/glib.prepare

glib_prepare_deps = \
	$(STATEDIR)/glib.extract

GLIB_PATH	  =  PATH=$(CROSS_PATH)
GLIB_AUTOCONF = --host=$(CONFIG_GNU_TARGET) \
                --prefix=$(INSTALLPATH) \
                --cache-file=$(GLIB_DIR)/$(CONFIG_GNU_TARGET).cache

ifdef CONFIG_GLIB_SHARED
   GLIB_AUTOCONF 	+=  --shared
else
endif

$(STATEDIR)/glib.prepare: $(glib_prepare_deps)
	@$(call targetinfo, $@)
	cp $(TOPDIR)/rules/$(CONFIG_GNU_TARGET).cache $(GLIB_DIR)/$(CONFIG_GNU_TARGET).cache
	cd $(GLIB_DIR) && \
		$(GLIB_PATH) \
		$(CROSS_ENV) \
		./configure $(GLIB_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

glib_compile: $(STATEDIR)/glib.compile

$(STATEDIR)/glib.compile: \
   $(STATEDIR)/glib.prepare \
   $(INSTALLPATH)/lib/libdl.a
	@$(call targetinfo, $@)
	cd $(GLIB_DIR) && $(GLIB_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

glib_install: $(STATEDIR)/glib.install

$(STATEDIR)/glib.install: $(STATEDIR)/glib.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(GLIB_DIR) && $(GLIB_PATH) make install
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

glib_targetinstall: $(STATEDIR)/glib.targetinstall

$(STATEDIR)/glib.targetinstall: $(STATEDIR)/glib.install
	@$(call targetinfo, $@)
	touch $@

$(ROOTDIR)/lib/libnsl.so.1: $(CROSS_LIB_DIR)/lib/libnsl.so.1
	cp $< $@ && chmod a+rwx $@
	PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libresolv-2.3.5.so: $(CROSS_LIB_DIR)/lib/libresolv-2.3.5.so
	cp $< $@ && chmod a+rwx $@
	PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libresolv.so.2: $(ROOTDIR)/lib/libresolv-2.3.5.so
	cd $(ROOTDIR)/lib/ && ln -s $> $@

$(ROOTDIR)/lib/libc-2.3.5.so: $(CROSS_LIB_DIR)/lib/libc-2.3.5.so
	cp $< $@ && chmod a+rwx $@

$(ROOTDIR)/lib/libc.so.6: $(ROOTDIR)/lib/libc-2.3.5.so
	cd $(ROOTDIR)/lib/ && ln -s $< $@

$(ROOTDIR)/lib/libgcc_s.so.1 \
$(ROOTDIR)/lib/libstdc++.so.6.0.3:
	cp -d $(CROSS_LIB_DIR)/lib/$(shell basename $@) $@ && chmod a+rw $@

$(ROOTDIR)/lib/libstdc++.so \
$(ROOTDIR)/lib/libstdc++.so.6: $(ROOTDIR)/lib/libstdc++.so.6.0.3
	cd $(ROOTDIR)/lib && ln -s $(shell basename $<) $(shell basename $@)

$(ROOTDIR)/lib/libutil.so.1: $(CROSS_LIB_DIR)/lib/libutil.so.1
	cp $< $@
	PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libnss_dns.so.2: $(CROSS_LIB_DIR)/lib/libnss_dns.so.2
	cp $< $@
	PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libnss_files.so.2: $(CROSS_LIB_DIR)/lib/libnss_files.so.2
	cp $< $@
	PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libcrypt.so.1: $(CROSS_LIB_DIR)/lib/libcrypt.so.1
	cp $< $@
	PATH=$(CROSS_PATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libm.so.6: $(CROSS_LIB_DIR)/lib/libm.so.6
	cp -d $(CROSS_LIB_DIR)/lib/libm.so* $(ROOTDIR)/lib/
	cp -d $(CROSS_LIB_DIR)/lib/libm-*.so* $(ROOTDIR)/lib/
	PATH=$(CROSS_PATH) $(CROSSSTRIP) $(ROOTDIR)/lib/libm-2.2.3.so

$(ROOTDIR)/lib/libpthread.so.0: $(CROSS_LIB_DIR)/lib/libpthread.so.0
	cp -d $(CROSS_LIB_DIR)/lib/libpthread-0.10.so $(ROOTDIR)/lib/ && chmod a+rw $(ROOTDIR)/lib/libpthread-0.10.so
	cp -d $(CROSS_LIB_DIR)/lib/libpthread.so.0 $(ROOTDIR)/lib/ && chmod a+rw $(ROOTDIR)/lib/libpthread.so.0
	PATH=$(CROSS_PATH) $(CROSSSTRIP) $(ROOTDIR)/lib/libpthread-*.so

$(ROOTDIR)/lib/ld-2.3.5.so: $(CROSS_LIB_DIR)/lib/ld-2.3.5.so
	cp -f $< $@

$(ROOTDIR)/lib/ld-linux.so.2: $(ROOTDIR)/lib/ld-2.3.5.so
	cd $(ROOTDIR)/lib/ && ln -s ld-2.3.5.so ld-linux.so.2

$(ROOTDIR)/lib/libdl.so.2: $(CROSS_LIB_DIR)/lib/libdl.so.2
	cp -f $< $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

glib_clean: 
	rm -rf $(STATEDIR)/glib.* $(GLIB_DIR)

# vim: syntax=make
