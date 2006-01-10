# -*-makefile-*-
# $Id: xfree450.make,v 1.3 2006-01-10 04:37:44 ericn Exp $
#
# Copyright (C) 2003 by Robert Schwebel <r.schwebel@pengutronix.de>
#             Pengutronix <info@pengutronix.de>, Germany
#          
# See CREDITS for details about who has contributed to this project.
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

# FIXME: replace by xlibs/xserver (or ipkgize it)

#
# We provide this package
#
ifdef PTXCONF_XFREE450
PACKAGES += xfree450
endif

#
# Paths and names
#
XFREE450_VERSION	= 4.5.0
XFREE450		= XFree86-$(XFREE450_VERSION)
XFREE450_SUFFIX		= tgz
XFREE450_DIR		= $(BUILDDIR)/xc
XFREE450_BUILDDIR	= $(BUILDDIR)/xc-build
COMPILER_PREFIX = $(CONFIG_GNU_TARGET)-

XFREE450_URL_BASE		= ftp://ftp.xfree86.org/pub/XFree86/4.5.0/source/$(XFREE450)-src
XFREE450_SOURCE_BASE = $(CONFIG_ARCHIVEPATH)/$(XFREE450)-src

XFREE450_1_URL		= $(XFREE450_URL_BASE)-1.$(XFREE450_SUFFIX)
XFREE450_1_SOURCE	= $(XFREE450_SOURCE_BASE)-1.$(XFREE450_SUFFIX)
XFREE450_2_URL		= $(XFREE450_URL_BASE)-2.$(XFREE450_SUFFIX)
XFREE450_2_SOURCE	= $(XFREE450_SOURCE_BASE)-2.$(XFREE450_SUFFIX)
XFREE450_3_URL		= $(XFREE450_URL_BASE)-3.$(XFREE450_SUFFIX)
XFREE450_3_SOURCE	= $(XFREE450_SOURCE_BASE)-3.$(XFREE450_SUFFIX)
XFREE450_4_URL		= $(XFREE450_URL_BASE)-4.$(XFREE450_SUFFIX)
XFREE450_4_SOURCE	= $(XFREE450_SOURCE_BASE)-4.$(XFREE450_SUFFIX)
XFREE450_5_URL		= $(XFREE450_URL_BASE)-5.$(XFREE450_SUFFIX)
XFREE450_5_SOURCE	= $(XFREE450_SOURCE_BASE)-5.$(XFREE450_SUFFIX)
XFREE450_6_URL		= $(XFREE450_URL_BASE)-6.$(XFREE450_SUFFIX)
XFREE450_6_SOURCE	= $(XFREE450_SOURCE_BASE)-6.$(XFREE450_SUFFIX)
XFREE450_7_URL		= $(XFREE450_URL_BASE)-7.$(XFREE450_SUFFIX)
XFREE450_7_SOURCE	= $(XFREE450_SOURCE_BASE)-7.$(XFREE450_SUFFIX)


# ----------------------------------------------------------------------------
# Get
# ----------------------------------------------------------------------------

xfree450_get: $(STATEDIR)/xfree450.get

xfree450_get_deps	= $(XFREE450_1_SOURCE) \
                    $(XFREE450_2_SOURCE) \
                    $(XFREE450_3_SOURCE) \
                    $(XFREE450_4_SOURCE) \
                    $(XFREE450_5_SOURCE) \
                    $(XFREE450_6_SOURCE) \
                    $(XFREE450_7_SOURCE)

$(STATEDIR)/xfree450.get: $(xfree450_get_deps)
	@$(call targetinfo, $@)
	@$(call get_patches, $(XFREE450))
	touch $@

$(XFREE450_SOURCE_BASE)-%.$(XFREE450_SUFFIX):
	$(call targetinfo, $@)
	echo "target $@, stem $*"
	echo "calling get $(XFREE450_URL_BASE)-$*.$(XFREE450_SUFFIX)"
	cd $(CONFIG_ARCHIVEPATH) && wget $(XFREE450_URL_BASE)-$*.$(XFREE450_SUFFIX)

# ----------------------------------------------------------------------------
# Extract
# ----------------------------------------------------------------------------

xfree450_extract: $(STATEDIR)/xfree450.extract

xfree450_extract_deps	=  $(STATEDIR)/xfree450.get

$(STATEDIR)/xfree450.extract: $(xfree450_extract_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFREE450_DIR))
	@cd $(BUILDDIR) && zcat $(XFREE450_1_SOURCE) | tar -xvf -
	@cd $(BUILDDIR) && zcat $(XFREE450_2_SOURCE) | tar -xvf -
	@cd $(BUILDDIR) && zcat $(XFREE450_3_SOURCE) | tar -xvf -
	@cd $(BUILDDIR) && zcat $(XFREE450_4_SOURCE) | tar -xvf -
	@cd $(BUILDDIR) && zcat $(XFREE450_5_SOURCE) | tar -xvf -
	@cd $(BUILDDIR) && zcat $(XFREE450_6_SOURCE) | tar -xvf -
	@cd $(BUILDDIR) && zcat $(XFREE450_7_SOURCE) | tar -xvf -
	@$(call patchin, $(XFREE450), $(XFREE450_DIR))
	touch $@

# ----------------------------------------------------------------------------
# Prepare
# ----------------------------------------------------------------------------

xfree450_prepare: $(STATEDIR)/xfree450.prepare

#
# dependencies
#
xfree450_prepare_deps =  \
	$(STATEDIR)/xfree450.extract \
	$(STATEDIR)/zlib.install \
	$(STATEDIR)/ncurses.install \
	$(STATEDIR)/libpng.install \
	
#   $(STATEDIR)/virtual-xchain.install

XFREE450_PATH	=  PATH=$(CROSS_PATH)
XFREE450_ENV	=  XCURSORGEN=xcursorgen

$(STATEDIR)/xfree450.prepare: $(xfree450_prepare_deps)
	@$(call targetinfo, $@)
	@$(call clean, $(XFREE450_BUILDDIR))

#	# Out-of-Tree build preparation
	install -d $(XFREE450_BUILDDIR)
	cd $(XFREE450_DIR)/config/util && make -f Makefile.ini lndir
	cd $(XFREE450_BUILDDIR) && $(XFREE450_DIR)/config/util/lndir $(XFREE450_DIR)
	cp $(CONFIG_XFREE450_CONFIG) $(XFREE450_BUILDDIR)/config/cf/host.def
	cd $(XFREE450_BUILDDIR) && mkdir cross_compiler
	for i in $(CONFIG_TOOLCHAINPATH)/bin/*; do ln -s $$i $(XFREE450_BUILDDIR)/cross_compiler; done
	ln -sf $(CONFIG_TOOLCHAINPATH)/bin/$(COMPILER_PREFIX)cpp $(XFREE450_BUILDDIR)/cross_compiler/cpp
	ln -sf $(CONFIG_TOOLCHAINPATH)/bin/$(COMPILER_PREFIX)gcov $(XFREE450_BUILDDIR)/cross_compiler/gcov
	ln -sf $(CONFIG_TOOLCHAINPATH)/bin/$(COMPILER_PREFIX)gcc $(XFREE450_BUILDDIR)/cross_compiler/cc
	ln -sf $(CONFIG_TOOLCHAINPATH)/bin/$(COMPILER_PREFIX)g++ $(XFREE450_BUILDDIR)/cross_compiler/
	ln -sf $(CONFIG_TOOLCHAINPATH)/bin/$(COMPILER_PREFIX)gcc $(XFREE450_BUILDDIR)/cross_compiler/gcc
	ln -sf $(CONFIG_TOOLCHAINPATH)/bin/$(COMPILER_PREFIX)ld $(XFREE450_BUILDDIR)/cross_compiler/ld
	ln -sf $(CONFIG_TOOLCHAINPATH)/bin/$(COMPILER_PREFIX)ar $(XFREE450_BUILDDIR)/cross_compiler/ar
	ln -sf $(CONFIG_TOOLCHAINPATH)/bin/$(COMPILER_PREFIX)ranlib $(XFREE450_BUILDDIR)/cross_compiler/ranlib
	ln -sf $(COMPILER_PREFIX)g++ $(XFREE450_BUILDDIR)/cross_compiler/g++
	ln -sf g++ $(XFREE450_BUILDDIR)/cross_compiler/c++

	touch $@

# ----------------------------------------------------------------------------
# Compile
# ----------------------------------------------------------------------------

xfree450_compile: $(STATEDIR)/xfree450.compile

xfree450_compile_deps =  $(STATEDIR)/xfree450.prepare

$(STATEDIR)/xfree450.compile: $(xfree450_compile_deps)
	@$(call targetinfo, $@)

	#
	# FIXME: tweak, tweak...
	#
	echo "UGGLY HACK WARNING: creating symlink to host xcursorgen (chicken&egg problem)"
	mkdir -p $(INSTALLPATH)/usr/X11R6/bin
	ln -sf `which xcursorgen` $(INSTALLPATH)/usr/X11R6/bin/xcursorgen
	ln -sf `which mkfontdir` $(INSTALLPATH)/usr/X11R6/bin/mkfontdir

	cd $(XFREE450_BUILDDIR) && \
		$(XFREE450_ENV) DESTDIR=$(INSTALLPATH) \
		make World \
          BOOTSTRAPCFLAGS="-I$(INSTALLPATH)/include" \
          DESTDIR=$(INSTALLPATH) \
          PreIncDir=$(INSTALLPATH)/include \
          CROSSCOMPILEDIR=$(XFREE450_BUILDDIR)/cross_compiler | tee make.log

	touch $@

# ----------------------------------------------------------------------------
# Install
# ----------------------------------------------------------------------------

xfree450_install: $(STATEDIR)/xfree450.install

$(STATEDIR)/xfree450.install: $(STATEDIR)/xfree450.compile
	@$(call targetinfo, $@)

	# These links are set incorrectly :-(
	# ln -sf $(XFREE450_BUILDDIR)/programs/Xserver/hw/xfree86/xf86Date.h $(XFREE450_BUILDDIR)/config/cf/date.def
	# ln -sf $(XFREE450_BUILDDIR)/programs/Xserver/hw/xfree86/xf86Version.h $(XFREE450_BUILDDIR)/config/cf/version.def

	cd $(XFREE450_BUILDDIR) && \
		$(XFREE450_ENV) DESTDIR=$(INSTALLPATH) \
		make install

	# 'make install' copies the pkg-config '.pc' files to the 
	# wrong location: we usually search them here...
	 
	rm -f $(INSTALLPATH)/lib/pkgconfig/fontconfig.pc
	cp $(INSTALLPATH)/usr/X11R6/lib/pkgconfig/fontconfig.pc \
	   $(INSTALLPATH)/lib/pkgconfig/
	rm -f $(INSTALLPATH)/lib/pkgconfig/xcursor.pc
	cp $(INSTALLPATH)/usr/X11R6/lib/pkgconfig/xcursor.pc \
	   $(INSTALLPATH)/lib/pkgconfig/
	rm -f $(INSTALLPATH)/lib/pkgconfig/xft.pc
	cp $(INSTALLPATH)/usr/X11R6/lib/pkgconfig/xft.pc \
	   $(INSTALLPATH)/lib/pkgconfig/

	# Now fix the paths: 
	perl -i -p -e "s,/usr/X11R6,$(INSTALLPATH)/usr/X11R6,g" \
		$(INSTALLPATH)/lib/pkgconfig/fontconfig.pc
	perl -i -p -e "s,/usr/X11R6,$(INSTALLPATH)/usr/X11R6,g" \
		$(INSTALLPATH)/lib/pkgconfig/xcursor.pc
	perl -i -p -e "s,/usr/X11R6,$(INSTALLPATH)/usr/X11R6,g" \
		$(INSTALLPATH)/lib/pkgconfig/xft.pc

	# libXft does also need libXrender:
	perl -i -p -e "s,-lXft,-lXext -lXft,g" \
		$(INSTALLPATH)/lib/pkgconfig/xft.pc

	touch $@

# ----------------------------------------------------------------------------
# Target-Install
# ----------------------------------------------------------------------------

xfree450_targetinstall: $(STATEDIR)/xfree450.targetinstall

xfree450_targetinstall_deps =  $(STATEDIR)/xfree450.compile
xfree450_targetinstall_deps += $(STATEDIR)/ncurses.targetinstall
xfree450_targetinstall_deps += $(STATEDIR)/libpng125.targetinstall
xfree450_targetinstall_deps += $(STATEDIR)/zlib.targetinstall

$(STATEDIR)/xfree450.targetinstall: $(xfree450_targetinstall_deps)
	@$(call targetinfo, $@)

#	# These links are set incorrectly :-(
	ln -sf $(XFREE450_BUILDDIR)/programs/Xserver/hw/xfree86/xf86Date.h $(XFREE450_BUILDDIR)/config/cf/date.def
	ln -sf $(XFREE450_BUILDDIR)/programs/Xserver/hw/xfree86/xf86Version.h $(XFREE450_BUILDDIR)/config/cf/version.def

#	# FIXME: this is somehow not being built...
	touch $(XFREE450_BUILDDIR)/fonts/encodings/encodings.dir
	cd $(XFREE450_BUILDDIR) && make install DESTDIR=$(ROOTDIR)

#	# FIXME: correct path? 
	cp -f $(XFREE450_BUILDDIR)/lib/freetype2/libfreetype.so.6.3.3 $(ROOTDIR)/lib
	ln -sf libfreetype.so.6.3.3 $(ROOTDIR)/lib/libfreetype.so.6
	ln -sf libfreetype.so.6.3.3 $(ROOTDIR)/lib/libfreetype.so

	touch $@

# ----------------------------------------------------------------------------
# Clean
# ----------------------------------------------------------------------------

xfree450_clean:
	rm -rf $(STATEDIR)/xfree450.*
	rm -rf $(XFREE450_DIR) $(XFREE450_BUILDDIR)

# vim: syntax=make
