# -*-makefile-*-
# $Id: libpng.make,v 1.7 2005-11-23 14:49:43 ericn Exp $
#
# Copyright (C) 2003 by Robert Schwebel <r.schwebel@pengutronix.de>
#                       Pengutronix <info@pengutronix.de>, Germany
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

#
# We provide this package
#
ifdef CONFIG_LIBPNG
PACKAGES += libpng
endif

#
# Paths and names
#
LIBPNG_VERSION	= 1.2.8
LIBPNG		= libpng-$(LIBPNG_VERSION)
LIBPNG_SUFFIX	= tar.gz
LIBPNG_URL		= http://download.sourceforge.net/libpng/$(LIBPNG).$(LIBPNG_SUFFIX)
LIBPNG_SOURCE	= $(CONFIG_ARCHIVEPATH)/$(LIBPNG).$(LIBPNG_SUFFIX)
LIBPNG_DIR		= $(BUILDDIR)/$(LIBPNG)

# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

libpng_get: $(STATEDIR)/libpng.get

libpng_get_deps	=  $(LIBPNG_SOURCE)

$(STATEDIR)/libpng.get: $(libpng_get_deps)
	@$(call targetinfo, $@)
	touch $@

$(LIBPNG_SOURCE):
	@$(call targetinfo, $@)
	cd $(CONFIG_ARCHIVEPATH) && wget $(LIBPNG_URL)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

libpng_extract: $(STATEDIR)/libpng.extract

libpng_extract_deps	=  $(STATEDIR)/libpng.get

$(STATEDIR)/libpng.extract: $(libpng_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBPNG_DIR))
	@cd $(BUILDDIR) && zcat $(LIBPNG_SOURCE) | tar -xvf -
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

libpng_prepare: $(STATEDIR)/libpng.prepare

#
# dependencies
#
libpng_prepare_deps =  \
	$(STATEDIR)/libpng.extract 

LIBPNG_PATH	=  PATH=$(CROSS_PATH)
LIBPNG_ENV 	=  $(CROSS_ENV)
INSTALLPATH_ESCAPED = $(subst /,\/, $(INSTALLPATH))

$(STATEDIR)/libpng.prepare: $(libpng_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(LIBPNG_BUILDDIR))
	cp $(LIBPNG_DIR)/scripts/makefile.linux $(LIBPNG_DIR)/Makefile
	echo "installpath = $(INSTALLPATH_ESCAPED)"
	perl -i -p -e "s/CC=/CC?=/g" $(LIBPNG_DIR)/Makefile
	perl -i -p -e "s/ZLIBINC=..\/zlib/ZLIBINC=$(INSTALLPATH_ESCAPED)\/include/g" $(LIBPNG_DIR)/Makefile
	perl -i -p -e "s/ZLIBLIB=..\/zlib/ZLIBLIB=$(INSTALLPATH_ESCAPED)\/lib/g" $(LIBPNG_DIR)/Makefile
	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

libpng_compile: $(STATEDIR)/libpng.compile

libpng_compile_deps =  $(STATEDIR)/libpng.prepare
libpng_compile_deps += $(STATEDIR)/zlib.install

$(STATEDIR)/libpng.compile: $(libpng_compile_deps)
	@$(call targetinfo, $@)
	$(LIBPNG_PATH) $(LIBPNG_ENV) make -C $(LIBPNG_DIR)
	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

libpng_install: $(STATEDIR)/libpng.install
libpng_pc = $(INSTALLPATH)/lib/pkgconfig/libpng.pc
libpng2_pc = $(INSTALLPATH)/lib/pkgconfig/libpng2.pc


$(STATEDIR)/libpng.install: $(STATEDIR)/libpng.compile
	@$(call targetinfo, $@)
	install -d $(INSTALLPATH)/lib
	install $(LIBPNG_DIR)/*.h $(INSTALLPATH)/include/
	install $(LIBPNG_DIR)/*.a $(INSTALLPATH)/lib
	cd $(INSTALLPATH)/lib && rm -f libpng12.a && ln -s libpng.a libpng12.a
	@mkdir -p $(INSTALLPATH)/lib/pkgconfig
	@chmod 755 $(INSTALLPATH)/lib/pkgconfig
	$(call makepkgconfig, libpng, "libpng12", "1.2.8", \
      "-L$(INSTALLPATH)/lib -lpng -lz -lm", "-I$(INSTALLPATH)/include", \
      $(libpng_pc) )
	$(call makepkgconfig, libpng, "libpng12", "1.2.8", \
      "-L$(INSTALLPATH)/lib -lpng -lz -lm", "-I$(INSTALLPATH)/include", \
      $(libpng2_pc) )
	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

libpng_targetinstall: $(STATEDIR)/libpng.targetinstall

libpng_targetinstall_deps	=  $(STATEDIR)/libpng.compile

$(STATEDIR)/libpng.targetinstall: $(libpng_targetinstall_deps)
	@$(call targetinfo, $@)
	install -d $(ROOTDIR)/lib
	install $(LIBPNG_DIR)/libpng12.so.0.1.2.5 $(ROOTDIR)/lib
	$(LIBPNG_PATH) $(CROSSSTRIP) $(ROOTDIR)/lib/libpng12.so.0.1.2.5
	ln -sf libpng12.so.0.1.2.5 $(ROOTDIR)/lib/libpng12.so.0
	ln -sf libpng12.so.0.1.2.5 $(ROOTDIR)/lib/libpng12.so
	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

libpng_clean:
	rm -rf $(STATEDIR)/libpng.*
	rm -rf $(LIBPNG_DIR)

# vim: syntax=make
