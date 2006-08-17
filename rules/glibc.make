# -*-makefile-*-
# $Id: glibc.make,v 1.2 2006-08-17 15:48:36 ericn Exp $
#
# Copyright (C) 2002, 2003 by Pengutronix e.K., Hildesheim, Germany
#
# See CREDITS for details about who has contributed to this project. 
#
# For further information about the PTXdist project and license conditions
# see the README file.
#


$(ROOTDIR)/lib/ld-2.3.5.so: $(CROSS_LIB_DIR)/lib/ld-2.3.5.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libc-2.3.5.so: $(CROSS_LIB_DIR)/lib/libc-2.3.5.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libc.so.6: $(CROSS_LIB_DIR)/lib/libc.so.6 $(ROOTDIR)/lib/libc-2.3.5.so
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
                
$(ROOTDIR)/lib/libutil-2.3.5.so: $(CROSS_LIB_DIR)/lib/libutil-2.3.5.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libutil.so.1: $(CROSS_LIB_DIR)/lib/libutil.so.1 $(ROOTDIR)/lib/libutil-2.3.5.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libresolv-2.3.5.so: $(CROSS_LIB_DIR)/lib/libresolv-2.3.5.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libnss_dns-2.3.5.so: $(CROSS_LIB_DIR)/lib/libnss_dns-2.3.5.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libnss_files-2.3.5.so: $(CROSS_LIB_DIR)/lib/libnss_files-2.3.5.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libnss_dns.so.2: $(CROSS_LIB_DIR)/lib/libnss_dns.so.2 $(ROOTDIR)/lib/libnss_dns-2.3.5.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libnss_files.so.2: $(CROSS_LIB_DIR)/lib/libnss_files.so.2 $(ROOTDIR)/lib/libnss_files-2.3.5.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libcrypt-2.3.5.so: $(CROSS_LIB_DIR)/lib/libcrypt-2.3.5.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libcrypt.so.1: $(CROSS_LIB_DIR)/lib/libcrypt.so.1 $(ROOTDIR)/lib/libcrypt-2.3.5.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libm-2.3.5.so: $(CROSS_LIB_DIR)/lib/libm-2.3.5.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libm.so.6: $(CROSS_LIB_DIR)/lib/libm.so.6 $(ROOTDIR)/lib/libm-2.3.5.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libpthread-0.10.so: $(CROSS_LIB_DIR)/lib/libpthread-0.10.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libpthread.so.0: $(CROSS_LIB_DIR)/lib/libpthread.so.0 $(ROOTDIR)/lib/libpthread-0.10.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libdl-2.3.5.so: $(CROSS_LIB_DIR)/lib/libdl-2.3.5.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libdl.so.2: $(CROSS_LIB_DIR)/lib/libdl.so.2
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/ld-linux.so.2: $(CROSS_LIB_DIR)/lib/ld-linux.so.2
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@
                
$(ROOTDIR)/lib/libnsl-2.3.5.so: $(CROSS_LIB_DIR)/lib/libnsl-2.3.5.so
	mkdir -p $(ROOTDIR)/lib
	cp -fvd $< $@

$(ROOTDIR)/lib/libnsl.so.1: $(ROOTDIR)/lib/libnsl-2.3.5.so
	mkdir -p $(ROOTDIR)/lib
	pushd $(ROOTDIR)/lib && ln -s libnsl-2.3.5.so $@ && popd

$(ROOTDIR)/lib/libnsl.so: $(ROOTDIR)/lib/libnsl.so.1
	pushd $(ROOTDIR)/lib && ln -s libnsl.so.1 $@ && popd


