#
# rules.mak
#
# Core rules for reading and parsing (unquoting) .config file vars
# 

#
# should be included after .config
#  -include .config
#

#
# print out header information
#
targetinfo = echo;					\
	TG=`echo $(1) | sed -e "s,/.*/,,g"`; 		\
	LINE=`echo target: $$TG |sed -e "s/./-/g"`;	\
	echo $$LINE;					\
	echo target: $$TG;				\
	echo $$LINE;					\
	echo;						\
	echo $@ : $^ | sed -e "s@$(TOPDIR)@@g" -e "s@/src/@@g" -e "s@/state/@@g" >> $(DEP_OUTPUT)

makepkgconfig = echo creating pkgconfig file $(6);	\
	echo -e "prefix=$(INSTALLPATH)"\
           "\nexec_prefix=$(INSTALLPATH)" \
           "\nlibdir=$(INSTALLPATH)/lib" \
           "\nincludedir=$(INSTALLPATH)/include" \
           "\nName: $(1)" \
           "\nDescription: $(2)" \
           "\nVersion: $(3)" \
           "\nLibs: $(4)" \
           "\nCflags: $(5)" \
        > $(6)

CONFIG_ARCHIVEPATH := $(subst ",,$(CONFIG_ARCHIVEPATH))
CONFIG_INSTALLPATH := $(subst ",,$(CONFIG_INSTALLPATH))
CONFIG_TOOLCHAINPATH := $(subst ",,$(CONFIG_TOOLCHAINPATH))
CONFIG_ROOT := $(subst ",,$(CONFIG_ROOT))

$(CONFIG_ARCHIVEPATH):
	mkdir $(CONFIG_ARCHIVEPATH)
	chmod a+rw $(CONFIG_ARCHIVEPATH)

