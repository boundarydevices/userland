# -*-makefile-*-
# $Id: expat.make,v 1.4 2005-12-04 17:22:42 ericn Exp $
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
ifeq (y, $(CONFIG_PIXMAN))
PACKAGES += expat
endif

#
# Paths and names 
#
EXPAT = expat-1.95.8
EXPAT_URL = http://easynews.dl.sourceforge.net/sourceforge/expat/$(EXPAT).tar.gz
EXPAT_SOURCE = $(CONFIG_ARCHIVEPATH)/$(EXPAT).tar.gz
EXPAT_DIR = $(BUILDDIR)/$(EXPAT)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

expat_get: $(STATEDIR)/expat.get

$(STATEDIR)/expat.get: $(EXPAT_SOURCE)
	@$(call targetinfo, $@)
	touch $@

$(EXPAT_SOURCE):
	@$(call targetinfo, $@)
	@cd $(CONFIG_ARCHIVEPATH) && wget $(EXPAT_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

expat_extract: $(STATEDIR)/expat.extract

$(STATEDIR)/expat.extract: $(STATEDIR)/expat.get
	@$(call targetinfo, $@)
	@$(call clean, $(EXPAT_DIR))
	@cd $(BUILDDIR) && zcat $(EXPAT_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

expat_prepare: $(STATEDIR)/expat.prepare

expat_prepare_deps = \
	$(STATEDIR)/expat.extract

EXPAT_PATH	=  PATH=$(CROSS_PATH)
EXPAT_AUTOCONF = --host=$(CONFIG_GNU_TARGET) \
	--prefix=$(INSTALLPATH)

ifdef CONFIG_EXPAT_SHARED
   EXPAT_AUTOCONF 	+=  --enable-shared=yes
else
   EXPAT_AUTOCONF 	+=  --enable-shared=no
   EXPAT_AUTOCONF 	+=  --enable-static=yes
endif

$(STATEDIR)/expat.prepare: $(expat_prepare_deps)
	@$(call targetinfo, $@)
	cd $(EXPAT_DIR) && \
		$(EXPAT_PATH) \
      $(CROSS_ENV) \
      ./configure $(EXPAT_AUTOCONF)
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

expat_compile: $(STATEDIR)/expat.compile

$(STATEDIR)/expat.compile: $(STATEDIR)/expat.prepare 
	@$(call targetinfo, $@)
	cd $(EXPAT_DIR) && $(EXPAT_PATH) make
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

expat_install: $(STATEDIR)/expat.install

expat_pc = $(INSTALLPATH)/lib/pkgconfig/expat.pc

$(STATEDIR)/expat.install: $(STATEDIR)/expat.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/include
	cd $(EXPAT_DIR) && $(EXPAT_PATH) make install
	echo "prefix=$(INSTALLPATH)" > $(expat_pc)
	echo "exec_prefix=$(INSTALLPATH)" >> $(expat_pc)
	echo "lib_dir=$(INSTALLPATH)/lib" >> $(expat_pc)
	echo "includedir=$(INSTALLPATH)/include" >> $(expat_pc)
	echo "Name: expat" >> $(expat_pc)
	echo "Description: An XML parsing library"
	echo "Version: 1.95.8" >> $(expat_pc)
	echo -E "Libs: -L$(INSTALLPATH)/lib -lexpat" >> $(expat_pc)
	echo -E "Cflags: -I$(INSTALLPATH)/include" >> $(expat_pc)
	cd $(EXPAT_DIR) && $(EXPAT_PATH) 
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

expat_targetinstall: $(STATEDIR)/expat.targetinstall

$(STATEDIR)/expat.targetinstall: $(STATEDIR)/expat.install
	@$(call targetinfo, $@)
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

expat_clean: 
	rm -rf $(STATEDIR)/expat.* $(EXPAT_DIR)

# vim: syntax=make
