
PREFIX=/usr
SYSCONFDIR=/etc
SHAREDSTATEDIR=/com
LOCALSTATEDIR=/var

PACKAGE_URL=https://www.gnupg.org/

RELEASE=1.djh987
ARCH=amd64
GPGERROR_VERSION=1.20
GPGERROR_NAME=libgpg-error

GPG_HOMEDIR=gpg-homedir

.PHONY: all install

install: all
	sudo dpkg -i target/*.deb

all: target/$(GPGERROR_NAME)_$(GPGERROR_VERSION)-$(RELEASE)_$(ARCH).deb

target:
	mkdir target

build:
	mkdir build

$(GPG_HOMEDIR):
	mkdir -p $(GPG_HOMEDIR); \
	gpg --homedir $(GPG_HOMEDIR) \
	    --recv-keys 0x4F25E3B6 0xE0856959 0x33BD3F06 0x7EFD60D9 0xF7E48EDB

$(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz: $(GPG_HOMEDIR)
	curl -L -C - -o $(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz \
		ftp://ftp.gnupg.org/gcrypt/libgpg-error/$(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz && \
	curl -L -C - -o $(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz.sig \
  		ftp://ftp.gnupg.org/gcrypt/libgpg-error/$(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz.sig && \
	gpg --homedir $(GPG_HOMEDIR) --verify $(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz.sig

target/$(GPGERROR_NAME)_$(GPGERROR_VERSION)-$(RELEASE)_$(ARCH).deb: target \
	$(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz
	tar -xf $(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz && \
	cd $(GPGERROR_NAME)-$(GPGERROR_VERSION)/ && \
	./configure --prefix=$(PREFIX) --sysconfdir=$(SYSCONFDIR) \
	    --sharedstatedir=$(SHAREDSTATEDIR) --localstatedir=$(LOCALSTATEDIR) && \
	mkdir fpm_pkg && \
	$(MAKE) DESTDIR=fpm_pkg && \
	make install && \
	fpm -s dir -t deb \
	    -n $(GPGERROR_NAME) \
		-a $(ARCH) \
	    -v $(GPGERROR_VERSION) \
		-p target/$(GPGERROR_NAME)_$(GPGERROR_VERSION)-$(RELEASE)_$(ARCH).deb \
		--url $(PACKAGE_URL) \
		--maintainer $(MAINTAINER) \
	    --iteration $(RELEASE) \
		--provides libgpg-error0 \
	    -C fpm_pkg
