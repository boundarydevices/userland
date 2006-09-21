# -*-makefile-*-
# $Id: glibc.make,v 1.3 2006-09-21 22:39:16 ericn Exp $
#
# Copyright (C) 2002, 2003 by Pengutronix e.K., Hildesheim, Germany
#
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#

GLIBC_VER=2.3.5

$(ROOTDIR)/lib/ld-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/ld-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libc-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/libc-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libc.so.6: $(CROSS_LIB_DIR)/lib/libc.so.6 $(ROOTDIR)/lib/libc-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libgcc_s.so.1: $(CROSS_LIB_DIR)/lib/libgcc_s.so.1
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libstdc++.so: $(CROSS_LIB_DIR)/lib/libstdc++.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libstdc++.so.6: $(CROSS_LIB_DIR)/lib/libstdc++.so.6
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libstdc++.so.6.0.3: $(CROSS_LIB_DIR)/lib/libstdc++.so.6.0.3
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libutil-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/libutil-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libutil.so.1: $(CROSS_LIB_DIR)/lib/libutil.so.1 $(ROOTDIR)/lib/libutil-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libresolv-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/libresolv-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libnss_dns-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/libnss_dns-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libnss_files-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/libnss_files-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libnss_dns.so.2: $(CROSS_LIB_DIR)/lib/libnss_dns.so.2 $(ROOTDIR)/lib/libnss_dns-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libnss_files.so.2: $(CROSS_LIB_DIR)/lib/libnss_files.so.2 $(ROOTDIR)/lib/libnss_files-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libcrypt-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/libcrypt-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libcrypt.so.1: $(CROSS_LIB_DIR)/lib/libcrypt.so.1 $(ROOTDIR)/lib/libcrypt-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libm-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/libm-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libm.so.6: $(CROSS_LIB_DIR)/lib/libm.so.6 $(ROOTDIR)/lib/libm-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libpthread-0.10.so: $(CROSS_LIB_DIR)/lib/libpthread-0.10.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libpthread.so.0: $(CROSS_LIB_DIR)/lib/libpthread.so.0 $(ROOTDIR)/lib/libpthread-0.10.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libdl-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/libdl-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libdl.so.2: $(CROSS_LIB_DIR)/lib/libdl.so.2
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/ld-linux.so.2: $(CROSS_LIB_DIR)/lib/ld-linux.so.2
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libnsl-$(GLIBC_VER).so: $(CROSS_LIB_DIR)/lib/libnsl-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libnsl.so.1: $(ROOTDIR)/lib/libnsl-$(GLIBC_VER).so
	mkdir -p $(ROOTDIR)/lib
	pushd $(ROOTDIR)/lib && ln -s libnsl-$(GLIBC_VER).so $@ && popd

$(ROOTDIR)/lib/libnsl.so: $(ROOTDIR)/lib/libnsl.so.1
	pushd $(ROOTDIR)/lib && ln -s libnsl.so.1 $@ && popd


