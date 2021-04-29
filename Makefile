VERSION ?= $(shell git tag --points-at HEAD | sed 's/^v//')
VERSION += 0-git-$(shell git rev-parse --short HEAD)
VERSION := $(word 1, $(VERSION))

PREFIX  ?= /usr

all:
	@echo "Nekofetch doesn't need to be compiled, run 'make install' to install"

debs: options iphoneos-armdeb amd64deb

debroots: options iphoneos-armdebroot amd64debroot

controls: options iphoneos-armcontrol amd64control

options:
	@echo "VERSION: $(VERSION)"

install:
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	install -m 0755 nekofetch $(DESTDIR)$(PREFIX)/bin/nekofetch
	@echo "You may need to install jq, jp2a, and neofetch"
	@echo "imagemagick is also required to use the kitty image backend"

uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/nekofetch

iphoneos-armcontrol:
	cp control.template iphoneos-armcontrol
	sed -i 's/PACKAGE/com.propr.nekofetch/' iphoneos-armcontrol
	sed -i 's/ARCH/iphoneos-arm/' iphoneos-armcontrol
	sed -i 's/VERSION/$(VERSION)/' iphoneos-armcontrol
amd64control:
	cp control.template amd64control
	sed -i 's/PACKAGE/nekofetch/' amd64control
	sed -i 's/ARCH/amd64/' amd64control
	sed -i 's/VERSION/$(VERSION)/' amd64control

iphoneos-armdebroot: iphoneos-armcontrol
	mkdir -p iphoneos-armdebroot/DEBIAN
	mkdir -p iphoneos-armdebroot/usr/bin
	mkdir -p iphoneos-armdebroot/usr/share/doc/nekofetch
	cp iphoneos-armcontrol iphoneos-armdebroot/DEBIAN/control
	cp LICENSE iphoneos-armdebroot/usr/share/doc/nekofetch/copyright
	cp nekofetch iphoneos-armdebroot/usr/bin/nekofetch
amd64debroot: amd64control
	mkdir -p amd64debroot/DEBIAN
	mkdir -p amd64debroot/usr/bin
	mkdir -p amd64debroot/usr/share/doc/nekofetch
	cp amd64control amd64debroot/DEBIAN/control
	cp LICENSE amd64debroot/usr/share/doc/nekofetch/copyright
	cp nekofetch amd64debroot/usr/bin/nekofetch

iphoneos-armdeb: iphoneos-armdebroot
	dpkg-deb -b "iphoneos-armdebroot" "com.propr.nekofetch_$(VERSION)_iphoneos-arm.deb"
amd64deb: amd64debroot
	dpkg-deb -b "amd64debroot" "nekofetch_$(VERSION)_amd64.deb"

clean:
	rm -rf iphoneos-armdebroot amd64debroot
	rm -f iphoneos-armcontrol amd64control
	rm -f com.propr.nekofetch_*_iphoneos-arm.deb nekofetch_*_amd64.deb

.PHONY: all debs debroots controls options install uninstall iphoneos-armdeb amd64deb clean
