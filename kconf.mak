kconf.tar.gz: 
	wget http://boundarydevices.com/$@

kconf/Makefile: kconf.tar.gz
	tar -zxvf $<

kconf/mconf: kconf/Makefile
	make -C kconf all

all: kconf/mconf
