PREFIX=/usr
SYSCONFDIR=/etc
SHAREDSTATEDIR=/com
LOCALSTATEDIR=/var
MAINTAINER=$(USER)@$(HOSTNAME)

PACKAGE_URL=https://www.gnupg.org/

RELEASE=1.djh987
ARCH=amd64


GPGERROR_VERSION=1.20
GPGERROR_NAME=libgpg-error

ASSUAN_NAME=libassuan
ASSUAN_VERSION=2.3.0

GPG_HOMEDIR=gpg-homedir

#install: all
#	sudo dpkg -i installers/*.deb

.PHONY: all clean install
all: installers/$(GPGERROR_NAME)_$(GPGERROR_VERSION)-$(RELEASE)_$(ARCH).deb \
	installers/$(ASSUAN_NAME)_$(ASSUAN_VERSION)-$(RELEASE)_$(ARCH).deb

clean:
	rm -f *.tgz
	rm -f *.tar.*
	rm -f *.tar.*.sig
	rm -f $(GPGERROR_NAME)-$(GPGERROR_VERSION)
	rm -f $(GPG_HOMEDIR)
	rm -rf installers

$(GPG_HOMEDIR)/pubring.gpg:
	mkdir -p $(@D) && \
	gpg --homedir $(@D) \
   		--keyserver keys.gnupg.net \
		--recv-keys 0x4F25E3B6 0xE0856959 0x33BD3F06 0x7EFD60D9 0xF7E48EDB

$(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz: $(GPG_HOMEDIR)/pubring.gpg
	curl -L -C - -o $@ \
		ftp://ftp.gnupg.org/gcrypt/$(GPGERROR_NAME)/$@ && \
	curl -L -C - -o $@.sig \
  		ftp://ftp.gnupg.org/gcrypt/$(GPGERROR_NAME)/$@.sig && \
	gpg --homedir $(GPG_HOMEDIR) --verify $@.sig

$(GPGERROR_NAME)-$(GPGERROR_VERSION)/config.status: $(GPGERROR_NAME)-$(GPGERROR_VERSION).tar.gz
	rm -rf $(@D) && \
	tar -xf $< && \
	cd $(@D)/ && \
	./configure --prefix=$(PREFIX) --sysconfdir=$(SYSCONFDIR) \
	    --sharedstatedir=$(SHAREDSTATEDIR) --localstatedir=$(LOCALSTATEDIR)

installers/$(GPGERROR_NAME)_$(GPGERROR_VERSION)-$(RELEASE)_$(ARCH).deb: $(GPGERROR_NAME)-$(GPGERROR_VERSION)/config.status
	cd $(GPGERROR_NAME)-$(GPGERROR_VERSION)/ && \
	mkdir -p fpm_pkg && \
	$(MAKE) && \
	make DESTDIR=$${PWD}/fpm_pkg install && \
	mkdir -p $(PWD)/$(@D) && \
	rm -f $(PWD)/$@ && \
	fpm -s dir -t deb \
	    -n $(GPGERROR_NAME) \
		-a $(ARCH) \
	    -v $(GPGERROR_VERSION) \
		-p $(PWD)/$@ \
		--url $(PACKAGE_URL) \
	    --iteration $(RELEASE) \
		--provides libgpg-error0 \
		--maintainer $(MAINTAINER) \
	    -C fpm_pkg

$(ASSUAN_NAME)-$(ASSUAN_VERSION).tar.bz2: $(GPG_HOMEDIR)/pubring.gpg
	curl -L -C - -o $@ \
		ftp://ftp.gnupg.org/gcrypt/$(ASSUAN_NAME)/$@ && \
	curl -L -C - -o $@.sig \
  		ftp://ftp.gnupg.org/gcrypt/$(ASSUAN_NAME)/$@.sig && \
	gpg --homedir $(GPG_HOMEDIR) --verify $@.sig && \
	touch $@

$(ASSUAN_NAME)-$(ASSUAN_VERSION)/config.status: $(ASSUAN_NAME)-$(ASSUAN_VERSION).tar.bz2
	rm -rf $(@D) && \
	tar -xf $< && \
	cd $(@D)/ && \
	./configure --prefix=$(PREFIX) --sysconfdir=$(SYSCONFDIR) \
	    --sharedstatedir=$(SHAREDSTATEDIR) --localstatedir=$(LOCALSTATEDIR)

installers/$(ASSUAN_NAME)_$(ASSUAN_VERSION)-$(RELEASE)_$(ARCH).deb: $(ASSUAN_NAME)-$(ASSUAN_VERSION)/config.status
	cd $(ASSUAN_NAME)-$(ASSUAN_VERSION)/ && \
	mkdir -p fpm_pkg && \
	$(MAKE) && \
	make DESTDIR=$${PWD}/fpm_pkg install && \
	mkdir -p $(PWD)/$(@D) && \
	rm -f $(PWD)/$@ && \
	fpm -s dir -t deb \
	    -n $(ASSUAN_NAME) \
		-a $(ARCH) \
	    -v $(ASSUAN_VERSION) \
		-p $(PWD)/$@ \
		--url $(PACKAGE_URL) \
	    --iteration $(RELEASE) \
		--provides libassuan20 \
		--depends '$(GPGERROR_NAME) (>= $(GPGERROR_VERSION))' \
		--maintainer $(MAINTAINER) \
	    -C fpm_pkg
