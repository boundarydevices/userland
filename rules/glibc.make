# -*-makefile-*-
# $Id: glibc.make,v 1.7 2007-10-09 00:52:26 ericn Exp $
#
# Copyright (C) 2002, 2003 by Pengutronix e.K., Hildesheim, Germany
#
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

GLIBC_VER=2.3.3
STDCPP_PATH=usr/lib
LD_LINUX=ld-linux.so.3

$(ROOTDIR)/lib/ld-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/ld-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libc-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/libc-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libc.so.6: $(CROSS_LIB_DIR)/lib/libc.so.6 $(ROOTDIR)/lib/libc-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libgcc_s.so.1: $(CROSS_LIB_DIR)/lib/libgcc_s.so.1
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libstdc++.so: $(CROSS_LIB_DIR)/$(STDCPP_PATH)/libstdc++.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libstdc++.so.6: $(CROSS_LIB_DIR)/$(STDCPP_PATH)/libstdc++.so.6
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libstdc++.so.6.0.3: $(CROSS_LIB_DIR)/$(STDCPP_PATH)/libstdc++.so.6.0.3
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libutil-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/libutil-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libutil.so.1: $(CROSS_LIB_DIR)/lib/libutil.so.1 $(ROOTDIR)/lib/libutil-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libresolv-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/libresolv-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libnss_dns-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/libnss_dns-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libnss_files-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/libnss_files-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libnss_dns.so.2: $(CROSS_LIB_DIR)/lib/libnss_dns.so.2 $(ROOTDIR)/lib/libnss_dns-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libnss_files.so.2: $(CROSS_LIB_DIR)/lib/libnss_files.so.2 $(ROOTDIR)/lib/libnss_files-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libcrypt-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/libcrypt-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libcrypt.so.1: $(CROSS_LIB_DIR)/lib/libcrypt.so.1 $(ROOTDIR)/lib/libcrypt-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libm-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/libm-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libm.so.6: $(CROSS_LIB_DIR)/lib/libm.so.6 $(ROOTDIR)/lib/libm-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libpthread-0.10.so: $(CROSS_LIB_DIR)/lib/libpthread-0.10.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libpthread.so.0: $(CROSS_LIB_DIR)/lib/libpthread.so.0 $(ROOTDIR)/lib/libpthread-0.10.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libdl-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/libdl-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libdl.so.2: $(CROSS_LIB_DIR)/lib/libdl.so.2
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/$(LD_LINUX): $(CROSS_LIB_DIR)/lib/$(LD_LINUX)
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@
                
$(ROOTDIR)/lib/libnsl-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/libnsl-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libnsl.so.1: $(ROOTDIR)/lib/libnsl-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cd $(ROOTDIR)/lib && ln -s libnsl-$(GLIBC_VER).so $@

$(ROOTDIR)/lib/libnsl.so: $(ROOTDIR)/lib/libnsl.so.1
	cd $(ROOTDIR)/lib && ln -s libnsl.so.1 $@

$(ROOTDIR)/lib/libthread_db-1.0.so: $(CROSS_LIB_DIR)/lib/libthread_db-1.0.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@ && $(CROSSSTRIP) $@

$(ROOTDIR)/lib/libthread_db.so: $(ROOTDIR)/lib/libthread_db-1.0.so
	cd $(ROOTDIR)/lib && ln -s $(notdir $<) $(notdir $@)

$(ROOTDIR)/lib/libthread_db.so.1:  $(ROOTDIR)/lib/libthread_db-1.0.so
	cd $(ROOTDIR)/lib && ln -s $(notdir $<) $(notdir $@)

