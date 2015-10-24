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


#install: all
#	sudo dpkg -i installers/*.deb

.PHONY: all clean install
all: installers/$(GPGERROR_NAME)_$(GPGERROR_VERSION)-$(RELEASE)_$(ARCH).deb

clean:
	rm -f *.tgz
	rm -f *.tar.*
	rm -f *.tar.*.sig
	rm -f $(GPGERROR_NAME)-$(GPGERROR_VERSION)
	rm -f $(GPG_HOMEDIR)
	rm -rf installers

$(GPG_HOMEDIR):
	mkdir -p $(GPG_HOMEDIR) && \
	gpg --homedir $(GPG_HOMEDIR) \
   		--keyserver keys.gnupg.net \
		--recv-keys 0x4F25E3B6 0xE0856959 0x33BD3F06 0x7EFD60D9 0xF7E48EDB

$(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz: $(GPG_HOMEDIR)
	curl -L -C - -o $(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz \
		ftp://ftp.gnupg.org/gcrypt/libgpg-error/$(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz && \
	curl -L -C - -o $(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz.sig \
  		ftp://ftp.gnupg.org/gcrypt/libgpg-error/$(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz.sig && \
	gpg --homedir $(GPG_HOMEDIR) --verify $(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz.sig && \
	touch $(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz

$(GPGERROR_NAME)-$(GPGERROR_VERSION)/config.status: $(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz
	rm -rf $(GPGERROR_NAME)-$(GPGERROR_VERSION)/ && \
	tar -xf $(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz && \
	cd $(GPGERROR_NAME)-$(GPGERROR_VERSION)/ && \
	./configure --prefix=$(PREFIX) --sysconfdir=$(SYSCONFDIR) \
	    --sharedstatedir=$(SHAREDSTATEDIR) --localstatedir=$(LOCALSTATEDIR) && \
	touch $(GPGERROR_NAME)-$(GPGERROR_VERSION)

installers/$(GPGERROR_NAME)_$(GPGERROR_VERSION)-$(RELEASE)_$(ARCH).deb: $(GPGERROR_NAME)-$(GPGERROR_VERSION)/config.status
	cd $(GPGERROR_NAME)-$(GPGERROR_VERSION)/ && \
	mkdir -p fpm_pkg && \
	$(MAKE) && \
	make DESTDIR=$${PWD}/fpm_pkg install && \
	rm -rf $(PWD)/installers && \
	mkdir -p $(PWD)/installers && \
	fpm -s dir -t deb \
	    -n $(GPGERROR_NAME) \
		-a $(ARCH) \
	    -v $(GPGERROR_VERSION) \
		-p $(PWD)/installers/$(GPGERROR_NAME)_$(GPGERROR_VERSION)-$(RELEASE)_$(ARCH).deb \
		--url $(PACKAGE_URL) \
	    --iteration $(RELEASE) \
		--provides libgpg-error0 \
	    -C fpm_pkg
