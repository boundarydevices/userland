# -*-makefile-*-
# $Id: glibc.make,v 1.14 2008-07-25 04:43:38 ericn Exp $
#
# Copyright (C) 2002, 2003 by Pengutronix e.K., Hildesheim, Germany
#
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

LD_LINUX=ld-linux.so.$(subst ",,$(CONFIG_LD_LINUX_VER))
GLIBC_VER=$(subst ",,$(CONFIG_GLIBC_VER))
GLIBC_PATH=$(subst ",,$(CONFIG_GLIBC_PATH))
GCC_PATH=$(subst ",,$(CONFIG_GCC_PATH))

NSLPATH=$(GLIBC_PATH)
STDCPP_PATH=$(GCC_PATH)/lib
SETGLIBCPATH=PATH=$(CROSS_PATH) 
CPPLIBS:=$(shell ls $(STDCPP_PATH)/libstdc++*.so*)

$(ROOTDIR)/lib/ld-$(GLIBC_VER).so: $(NSLPATH)/lib/ld-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(SETGLIBCPATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libc.so.6: $(NSLPATH)/lib/libc-$(GLIBC_VER).so
	cd $(ROOTDIR)/lib/ && ln -sf $< $@
                
$(ROOTDIR)/lib/libgcc_s.so.1: $(GCC_PATH)/lib/libgcc_s.so.1
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(SETGLIBCPATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libstdc++.so.6: 
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $(STDCPP_PATH)/libstdc++\*.so\* $(ROOTDIR)/lib/
	$(SETGLIBCPATH) $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libstdc++.so: $(ROOTDIR)/lib/libstdc++.so.6
	cd $(ROOTDIR)/lib/ && ln -sf $< $@
                
$(ROOTDIR)/lib/libutil-$(GLIBC_VER).so: $(NSLPATH)/lib/libutil-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(SETGLIBCPATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libutil.so.1: $(ROOTDIR)/lib/libutil-$(GLIBC_VER).so
	cd $(ROOTDIR)/lib && ln -sf libnsl-$(GLIBC_VER).so $@

$(ROOTDIR)/lib/libresolv-$(GLIBC_VER).so: $(NSLPATH)/lib/libresolv-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(SETGLIBCPATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libnss_dns-$(GLIBC_VER).so: $(NSLPATH)/lib/libnss_dns-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(SETGLIBCPATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libnss_dns.so.2: $(ROOTDIR)/lib/libnss_dns-$(GLIBC_VER).so
	cd $(ROOTDIR)/lib/ && ln -sf $< $@
                
$(ROOTDIR)/lib/libnss_files-$(GLIBC_VER).so: $(NSLPATH)/lib/libnss_files-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(SETGLIBCPATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libnss_files.so.2: $(ROOTDIR)/lib/libnss_files-$(GLIBC_VER).so
	cd $(ROOTDIR)/lib/ && ln -sf $< $@
                
$(ROOTDIR)/lib/libcrypt-$(GLIBC_VER).so: $(NSLPATH)/lib/libcrypt-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(SETGLIBCPATH) $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libcrypt.so.1: $(ROOTDIR)/lib/libcrypt-$(GLIBC_VER).so
	cd $(ROOTDIR)/lib && ln -sf $< $@
                
$(ROOTDIR)/lib/libm-$(GLIBC_VER).so: $(NSLPATH)/lib/libm-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(SETGLIBCPATH) $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libm.so.6: $(ROOTDIR)/lib/libm-$(GLIBC_VER).so
	cd $(ROOTDIR)/lib/ && ln -sf $< $@
                
$(ROOTDIR)/lib/libpthread-$(GLIBC_VER).so: $(NSLPATH)/lib/libpthread-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(SETGLIBCPATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libpthread.so.0: $(ROOTDIR)/lib/libpthread-$(GLIBC_VER).so
	cd $(ROOTDIR)/lib/ && ln -sf $< $@
                
$(ROOTDIR)/lib/libdl-$(GLIBC_VER).so: $(NSLPATH)/lib/libdl-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(SETGLIBCPATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libdl.so.2: $(ROOTDIR)/lib/libdl-$(GLIBC_VER).so
	cd $(ROOTDIR)/lib/ && ln -sf $< $@
                
$(ROOTDIR)/lib/$(LD_LINUX): $(NSLPATH)/lib/$(LD_LINUX)
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(SETGLIBCPATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libnsl-$(GLIBC_VER).so: $(NSLPATH)/lib/libnsl-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(SETGLIBCPATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libnsl.so.1: $(ROOTDIR)/lib/libnsl-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cd $(ROOTDIR)/lib && ln -sf libnsl-$(GLIBC_VER).so $@

$(ROOTDIR)/lib/libnsl.so: $(ROOTDIR)/lib/libnsl.so.1
	cd $(ROOTDIR)/lib && ln -s libnsl.so.1 $@

$(ROOTDIR)/lib/libthread_db-1.0.so: $(GLIBC_PATH)/libthread_db-1.0.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(SETGLIBCPATH) $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libthread_db.so: $(ROOTDIR)/lib/libthread_db-1.0.so
	cd $(ROOTDIR)/lib && ln -s $(notdir $<) $(notdir $@)

$(ROOTDIR)/lib/libthread_db.so.1:  $(ROOTDIR)/lib/libthread_db-1.0.so
	cd $(ROOTDIR)/lib && ln -s $(notdir $<) $(notdir $@)

