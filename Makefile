PREFIX=/usr
SYSCONFDIR=/etc
SHAREDSTATEDIR=/com
LOCALSTATEDIR=/var
MAINTAINER=$(USER)@$(shell hostname)

PACKAGE_URL=https://www.gnupg.org/

RELEASE=1.djh987
ARCH=amd64
PKG_DIR=fpm_pkg

COMPILE_ROOT=compile
COMPILE_ROOT_DIR=$(PWD)/$(COMPILE_ROOT)
COMPILE_LIB_DIR=$(COMPILE_ROOT_DIR)/usr/lib
COMPILE_BIN_DIR=$(COMPILE_ROOT_DIR)/usr/bin

GPGERROR_VERSION=1.20
GPGERROR_NAME=libgpg-error
GPGERROR_DIR=$(GPGERROR_NAME)-$(GPGERROR_VERSION)
GPGERROR_TAR=$(GPGERROR_DIR).tar.gz
GPGERROR_URL=ftp://ftp.gnupg.org/gcrypt/$(GPGERROR_NAME)/$(GPGERROR_TAR)
GPGERROR_CONFIG=$(GPGERROR_DIR)/config.status
GPGERROR_LIBRARY=$(COMPILE_LIB_DIR)/$(GPGERROR_NAME).so
GPGERROR_INSTALLER=installers/$(GPGERROR_NAME)_$(GPGERROR_VERSION)-$(RELEASE)_$(ARCH).deb

PINENTRY_VERSION=0.9.5
PINENTRY_NAME=pinentry
PINENTRY_DIR=$(PINENTRY_NAME)-$(PINENTRY_VERSION)
PINENTRY_TAR=$(PINENTRY_DIR).tar.bz2
PINENTRY_URL=ftp://ftp.gnupg.org/gcrypt/$(PINENTRY_NAME)/$(PINENTRY_TAR)
PINENTRY_CONFIG=$(PINENTRY_DIR)/config.status
PINENTRY_BINARY=$(COMPILE_BIN_DIR)/pinentry
PINENTRY_INSTALLER=installers/$(PINENTRY_NAME)_$(PINENTRY_VERSION)-$(RELEASE)_$(ARCH).deb

NPTH_VERSION=1.2
NPTH_NAME=npth
NPTH_DIR=$(NPTH_NAME)-$(NPTH_VERSION)
NPTH_TAR=$(NPTH_DIR).tar.bz2
NPTH_URL=ftp://ftp.gnupg.org/gcrypt/$(NPTH_NAME)/$(NPTH_TAR)
NPTH_CONFIG=$(NPTH_DIR)/config.status
NPTH_LIBRARY=$(COMPILE_LIB_DIR)/lib$(NPTH_NAME).so
NPTH_INSTALLER=installers/$(NPTH_NAME)_$(NPTH_VERSION)-$(RELEASE)_$(ARCH).deb

KSBA_VERSION=1.3.3
KSBA_NAME=libksba
KSBA_DIR=$(KSBA_NAME)-$(KSBA_VERSION)
KSBA_TAR=$(KSBA_DIR).tar.bz2
KSBA_URL=ftp://ftp.gnupg.org/gcrypt/$(KSBA_NAME)/$(KSBA_TAR)
KSBA_CONFIG=$(KSBA_DIR)/config.status
KSBA_LIBRARY=$(COMPILE_LIB_DIR)/$(KSBA_NAME).so
KSBA_INSTALLER=installers/$(KSBA_NAME)_$(KSBA_VERSION)-$(RELEASE)_$(ARCH).deb

ASSUAN_NAME=libassuan
ASSUAN_VERSION=2.3.0
ASSUAN_DIR=$(ASSUAN_NAME)-$(ASSUAN_VERSION)
ASSUAN_TAR=$(ASSUAN_DIR).tar.bz2
ASSUAN_URL=ftp://ftp.gnupg.org/gcrypt/$(ASSUAN_NAME)/$(ASSUAN_TAR)
ASSUAN_CONFIG=$(ASSUAN_DIR)/config.status
ASSUAN_LIBRARY=$(COMPILE_LIB_DIR)/$(ASSUAN_NAME).so
ASSUAN_INSTALLER=installers/$(ASSUAN_NAME)_$(ASSUAN_VERSION)-$(RELEASE)_$(ARCH).deb

GCRYPT_NAME=libgcrypt
GCRYPT_VERSION=1.6.4
GCRYPT_DIR=$(GCRYPT_NAME)-$(GCRYPT_VERSION)
GCRYPT_TAR=$(GCRYPT_DIR).tar.gz
GCRYPT_URL=ftp://ftp.gnupg.org/gcrypt/$(GCRYPT_NAME)/$(GCRYPT_TAR)
GCRYPT_CONFIG=$(GCRYPT_DIR)/config.status
GCRYPT_LIBRARY=$(COMPILE_LIB_DIR)/$(GCRYPT_NAME).so
GCRYPT_INSTALLER=installers/$(GCRYPT_NAME)_$(GCRYPT_VERSION)-$(RELEASE)_$(ARCH).deb

GNUPG_NAME=gnupg
GNUPG_VERSION=2.1.9
GNUPG_DIR=$(GNUPG_NAME)-$(GNUPG_VERSION)
GNUPG_TAR=$(GNUPG_DIR).tar.bz2
GNUPG_URL=ftp://ftp.gnupg.org/gcrypt/$(GNUPG_NAME)/$(GNUPG_TAR)
GNUPG_CONFIG=$(GNUPG_DIR)/config.status
GNUPG_BINARY=$(COMPILE_BIN_DIR)/gpg2
GNUPG_INSTALLER=installers/$(GNUPG_NAME)_$(GNUPG_VERSION)-$(RELEASE)_$(ARCH).deb

GPG_HOMEDIR=gpg-homedir

.PHONY: all clean install
all: $(GPGERROR_INSTALLER) $(KSBA_INSTALLER) $(ASSUAN_INSTALLER) \
	$(NPTH_INSTALLER) $(GCRYPT_INSTALLER) $(PINENTRY_INSTALLER) \
	$(GNUPG_INSTALLER)

install: all
	sudo dpkg -i installers/*.deb

clean:
	rm -f *.tgz
	rm -f *.tar.*
	rm -f *.tar.*.sig
	rm -rf $(GPGERROR_DIR)
	rm -rf $(ASSUAN_DIR)
	rm -rf $(GPG_HOMEDIR)
	rm -rf installers
	rm -rf $(COMPILE_ROOT_DIR)

$(GPG_HOMEDIR)/pubring.gpg:
	mkdir -p $(@D) && \
	chmod -R go-rwx $(@D) && \
	gpg --homedir $(@D) \
   		--keyserver keys.gnupg.net \
		--recv-keys 0x4F25E3B6 0xE0856959 0x33BD3F06 0x7EFD60D9 0xF7E48EDB && \
	chmod -R go-rwx $(@D)

$(GPGERROR_TAR): $(GPG_HOMEDIR)/pubring.gpg
	curl -L -C - -o $@ \
		ftp://ftp.gnupg.org/gcrypt/$(GPGERROR_NAME)/$@ && \
	curl -L -C - -o $@.sig \
  		ftp://ftp.gnupg.org/gcrypt/$(GPGERROR_NAME)/$@.sig && \
	gpg --homedir $(GPG_HOMEDIR) --verify $@.sig

$(GPGERROR_CONFIG): $(GPGERROR_TAR)
	rm -rf $(@D) && \
	tar -xf $< && \
	cd $(@D)/ && \
	export PKG_CONFIG_SYSROOT_DIR=$(COMPILE_ROOT_DIR) && \
	./configure --prefix=$(PREFIX) --sysconfdir=$(SYSCONFDIR) \
	    --sharedstatedir=$(SHAREDSTATEDIR) --localstatedir=$(LOCALSTATEDIR) \
		--with-sysroot=$(COMPILE_ROOT_DIR)

$(GPGERROR_LIBRARY): $(GPGERROR_CONFIG)
	cd $(GPGERROR_DIR)/ && \
	mkdir -p $(COMPILE_ROOT_DIR) && \
	make DESTDIR=$(COMPILE_ROOT_DIR) install

$(GPGERROR_INSTALLER): $(GPGERROR_CONFIG)
	cd $(GPGERROR_DIR)/ && \
	mkdir -p $(GPGERROR_DIR)/$(PKG_DIR) && \
	make DESTDIR=$${PWD}/$(PKG_DIR) install && \
	mkdir -p $(PWD)/$(@D) && \
	rm -f $(PWD)/$@ && \
	find $(PKG_DIR) -depth -type d -empty -delete && \
    rm -rf $(PKG_DIR)/usr/share/info/dir && \
	fpm -s dir -t deb \
	    -n $(GPGERROR_NAME) \
		-a $(ARCH) \
	    -v $(GPGERROR_VERSION) \
		-p $(PWD)/$@ \
		--url $(PACKAGE_URL) \
	    --iteration $(RELEASE) \
		--provides libgpg-error0 \
		--provides libgpg-error-dev \
		--maintainer $(MAINTAINER) \
	    -C $(PKG_DIR)


$(NPTH_TAR): $(GPG_HOMEDIR)/pubring.gpg
	curl -L -C - -o $@ \
		ftp://ftp.gnupg.org/gcrypt/$(NPTH_NAME)/$@ && \
	curl -L -C - -o $@.sig \
  		ftp://ftp.gnupg.org/gcrypt/$(NPTH_NAME)/$@.sig && \
	gpg --homedir $(GPG_HOMEDIR) --verify $@.sig

$(NPTH_CONFIG): $(NPTH_TAR)
	rm -rf $(@D) && \
	tar -xf $< && \
	cd $(@D)/ && \
	export PKG_CONFIG_SYSROOT_DIR=$(COMPILE_ROOT_DIR) && \
	./configure --prefix=$(PREFIX) --sysconfdir=$(SYSCONFDIR) \
	    --sharedstatedir=$(SHAREDSTATEDIR) --localstatedir=$(LOCALSTATEDIR) \
		--with-sysroot=$(COMPILE_ROOT_DIR)

$(NPTH_LIBRARY): $(NPTH_CONFIG)
	cd $(NPTH_DIR)/ && \
	mkdir -p $(COMPILE_ROOT_DIR) && \
	make DESTDIR=$(COMPILE_ROOT_DIR) install

$(NPTH_INSTALLER): $(NPTH_LIBRARY) $(NPTH_CONFIG)
	cd $(NPTH_DIR)/ && \
	mkdir -p $(NPTH_DIR)/$(PKG_DIR) && \
	make DESTDIR=$${PWD}/$(PKG_DIR) install && \
	mkdir -p $(PWD)/$(@D) && \
	rm -f $(PWD)/$@ && \
	find $(PKG_DIR) -depth -type d -empty -delete && \
    rm -rf $(PKG_DIR)/usr/share/info/dir && \
	fpm -s dir -t deb \
	    -n $(NPTH_NAME) \
		-a $(ARCH) \
	    -v $(NPTH_VERSION) \
		-p $(PWD)/$@ \
		--url $(PACKAGE_URL) \
	    --iteration $(RELEASE) \
		--maintainer $(MAINTAINER) \
	    -C $(PKG_DIR)

$(KSBA_TAR): $(GPG_HOMEDIR)/pubring.gpg
	curl -L -C - -o $@ \
		ftp://ftp.gnupg.org/gcrypt/$(KSBA_NAME)/$@ && \
	curl -L -C - -o $@.sig \
  		ftp://ftp.gnupg.org/gcrypt/$(KSBA_NAME)/$@.sig && \
	gpg --homedir $(GPG_HOMEDIR) --verify $@.sig

$(KSBA_CONFIG): $(KSBA_TAR)
	rm -rf $(@D) && \
	tar -xf $< && \
	cd $(@D)/ && \
	export PKG_CONFIG_SYSROOT_DIR=$(COMPILE_ROOT_DIR) && \
	./configure --prefix=$(PREFIX) --sysconfdir=$(SYSCONFDIR) \
	    --sharedstatedir=$(SHAREDSTATEDIR) --localstatedir=$(LOCALSTATEDIR) \
		--with-sysroot=$(COMPILE_ROOT_DIR)

$(KSBA_LIBRARY): $(KSBA_CONFIG) $(GPGERROR_LIBRARY)
	cd $(KSBA_DIR)/ && \
	$(MAKE) && \
	make DESTDIR=$(COMPILE_ROOT_DIR) install

$(KSBA_INSTALLER): $(KSBA_LIBRARY) $(KSBA_CONFIG)
	cd $(KSBA_DIR)/ && \
	mkdir -p $(PKG_DIR) && \
	make DESTDIR=$${PWD}/$(PKG_DIR) install  && \
	mkdir -p $(PWD)/$(@D) && \
	rm -f $(PWD)/$@ && \
	find $(PKG_DIR) -depth -type d -empty -delete && \
    rm -rf $(PKG_DIR)/usr/share/info/dir && \
	fpm -s dir -t deb \
	    -n $(KSBA_NAME) \
		-a $(ARCH) \
	    -v $(KSBA_VERSION) \
		-p $(PWD)/$@ \
		--url $(PACKAGE_URL) \
	    --iteration $(RELEASE) \
		--provides libksba8 \
		--maintainer $(MAINTAINER) \
		-d '$(GPGERROR_NAME) (>= $(GPGERROR_VERSION))' \
	    -C $(PKG_DIR)

$(ASSUAN_TAR): $(GPG_HOMEDIR)/pubring.gpg
	curl -L -C - -o $@ \
		ftp://ftp.gnupg.org/gcrypt/$(ASSUAN_NAME)/$@ && \
	curl -L -C - -o $@.sig \
  		ftp://ftp.gnupg.org/gcrypt/$(ASSUAN_NAME)/$@.sig && \
	gpg --homedir $(GPG_HOMEDIR) --verify $@.sig

$(ASSUAN_CONFIG): $(ASSUAN_TAR)
	rm -rf $(@D) && \
	tar -xf $< && \
	cd $(@D)/ && \
	export PKG_CONFIG_SYSROOT_DIR=$(COMPILE_ROOT_DIR) && \
	./configure --prefix=$(PREFIX) --sysconfdir=$(SYSCONFDIR) \
	    --sharedstatedir=$(SHAREDSTATEDIR) --localstatedir=$(LOCALSTATEDIR) \
		--with-sysroot=$(COMPILE_ROOT_DIR)

$(ASSUAN_LIBRARY): $(ASSUAN_CONFIG) $(GPGERROR_LIBRARY)
	cd $(ASSUAN_DIR)/ && \
	$(MAKE) && \
	make DESTDIR=$(COMPILE_ROOT_DIR) install

$(ASSUAN_INSTALLER): $(ASSUAN_LIBRARY) $(ASSUAN_CONFIG)
	cd $(ASSUAN_DIR)/ && \
	mkdir -p $(PKG_DIR) && \
	make DESTDIR=$${PWD}/$(PKG_DIR) install  && \
	mkdir -p $(PWD)/$(@D) && \
	rm -f $(PWD)/$@ && \
	find $(PKG_DIR) -depth -type d -empty -delete && \
    rm -rf $(PKG_DIR)/usr/share/info/dir && \
	fpm -s dir -t deb \
	    -n $(ASSUAN_NAME) \
		-a $(ARCH) \
	    -v $(ASSUAN_VERSION) \
		-p $(PWD)/$@ \
		--url $(PACKAGE_URL) \
	    --iteration $(RELEASE) \
		--provides libgpg-error0 \
		--maintainer $(MAINTAINER) \
	    -C $(PKG_DIR)

$(GCRYPT_TAR): $(GPG_HOMEDIR)/pubring.gpg
	curl -L -C - -o $@ \
		ftp://ftp.gnupg.org/gcrypt/$(GCRYPT_NAME)/$@ && \
	curl -L -C - -o $@.sig \
  		ftp://ftp.gnupg.org/gcrypt/$(GCRYPT_NAME)/$@.sig && \
	gpg --homedir $(GPG_HOMEDIR) --verify $@.sig

$(GCRYPT_CONFIG): $(GCRYPT_TAR)
	rm -rf $(@D) && \
	tar -xf $< && \
	cd $(@D)/ && \
	export PKG_CONFIG_SYSROOT_DIR=$(COMPILE_ROOT_DIR) && \
	./configure --prefix=$(PREFIX) --sysconfdir=$(SYSCONFDIR) \
	    --sharedstatedir=$(SHAREDSTATEDIR) --localstatedir=$(LOCALSTATEDIR) \
		--with-sysroot=$(COMPILE_ROOT_DIR)

$(GCRYPT_LIBRARY): $(GCRYPT_CONFIG) $(GPGERROR_LIBRARY)
	cd $(GCRYPT_DIR)/ && \
	$(MAKE) && \
	make DESTDIR=$(COMPILE_ROOT_DIR) install

$(GCRYPT_INSTALLER): $(GCRYPT_LIBRARY) $(GCRYPT_CONFIG)
	cd $(GCRYPT_DIR)/ && \
	mkdir -p $(PKG_DIR) && \
	make DESTDIR=$${PWD}/$(PKG_DIR) install  && \
	mkdir -p $(PWD)/$(@D) && \
	rm -f $(PWD)/$@ && \
	find $(PKG_DIR) -depth -type d -empty -delete && \
    rm -rf $(PKG_DIR)/usr/share/info/dir && \
	fpm -s dir -t deb \
	    -n $(GCRYPT_NAME) \
		-a $(ARCH) \
	    -v $(GCRYPT_VERSION) \
		-p $(PWD)/$@ \
		--url $(PACKAGE_URL) \
	    --iteration $(RELEASE) \
		--provides libgpgcrypt20 \
		--replaces libgcrypt11-dev \
		--provides libgcrypt16-dev \
		--maintainer $(MAINTAINER) \
	    -C $(PKG_DIR)

$(PINENTRY_TAR): $(GPG_HOMEDIR)/pubring.gpg
	curl -L -C - -o $@ \
		ftp://ftp.gnupg.org/gcrypt/$(PINENTRY_NAME)/$@ && \
	curl -L -C - -o $@.sig \
  		ftp://ftp.gnupg.org/gcrypt/$(PINENTRY_NAME)/$@.sig && \
	gpg --homedir $(GPG_HOMEDIR) --verify $@.sig

$(PINENTRY_CONFIG): $(PINENTRY_TAR)
	rm -rf $(@D) && \
	tar -xf $< && \
	cd $(@D)/ && \
	export PKG_CONFIG_SYSROOT_DIR=$(COMPILE_ROOT_DIR) && \
	./configure --prefix=$(PREFIX) --sysconfdir=$(SYSCONFDIR) \
	    --sharedstatedir=$(SHAREDSTATEDIR) --localstatedir=$(LOCALSTATEDIR) \
		--enable-pinentry-curses --disable-pinentry-qt4 --enable-pinentry-tty \
		--with-sysroot=$(COMPILE_ROOT_DIR)

$(PINENTRY_BINARY): $(PINENTRY_CONFIG) $(ASSUAN_LIBRARY) $(GCRYPT_LIBRARY)
	cd $(PINENTRY_DIR)/ && \
	$(MAKE) && \
	make DESTDIR=$(COMPILE_ROOT_DIR) install

$(PINENTRY_INSTALLER): $(PINENTRY_BINARY) $(PINENTRY_CONFIG)
	cd $(PINENTRY_DIR)/ && \
	mkdir -p $(PKG_DIR) && \
	make DESTDIR=$${PWD}/$(PKG_DIR) install  && \
	mkdir -p $(PWD)/$(@D) && \
	rm -f $(PWD)/$@ && \
	find $(PKG_DIR) -depth -type d -empty -delete && \
    rm -rf $(PKG_DIR)/usr/share/info/dir && \
	fpm -s dir -t deb \
	    -n $(PINENTRY_NAME) \
		-a $(ARCH) \
	    -v $(PINENTRY_VERSION) \
		-p $(PWD)/$@ \
		--url $(PACKAGE_URL) \
	    --iteration $(RELEASE) \
		--provides pinentry-qt4 \
		--provides pinentry-gtk2 \
		--maintainer $(MAINTAINER) \
	    -C $(PKG_DIR)


$(GNUPG_TAR): $(GPG_HOMEDIR)/pubring.gpg
	curl -L -C - -o $@ \
		ftp://ftp.gnupg.org/gcrypt/$(GNUPG_NAME)/$@ && \
	curl -L -C - -o $@.sig \
  		ftp://ftp.gnupg.org/gcrypt/$(GNUPG_NAME)/$@.sig && \
	gpg --homedir $(GPG_HOMEDIR) --verify $@.sig

$(GNUPG_CONFIG): $(GNUPG_TAR) $(NPTH_LIBRARY)
	rm -rf $(@D) && \
	tar -xf $< && \
	cd $(@D)/ && \
	export PKG_CONFIG_SYSROOT_DIR=$(COMPILE_ROOT_DIR) && \
	./configure --prefix=$(PREFIX) --sysconfdir=$(SYSCONFDIR) \
	    --sharedstatedir=$(SHAREDSTATEDIR) --localstatedir=$(LOCALSTATEDIR) \
		--with-sysroot=$(COMPILE_ROOT_DIR)

$(GNUPG_BINARY): $(GNUPG_CONFIG) $(ASSUAN_LIBRARY) $(GCRYPT_LIBRARY) $(GPGERROR_LIBRARY) \
	$(KSBA_LIBRARY) $(NPTH_LIBRARY)
	cd $(GNUPG_DIR)/ && \
	$(MAKE) && \
	make DESTDIR=$(COMPILE_ROOT_DIR) install

$(GNUPG_INSTALLER): $(GNUPG_BINARY) $(GNUPG_CONFIG)
	cd $(GNUPG_DIR)/ && \
	mkdir -p $(PKG_DIR) && \
	make DESTDIR=$${PWD}/$(PKG_DIR) install  && \
	mkdir -p $(PWD)/$(@D) && \
	rm -f $(PWD)/$@ && \
	find $(PKG_DIR) -depth -type d -empty -delete && \
    rm -rf $(PKG_DIR)/usr/share/info/dir && \
	fpm -s dir -t deb \
	    -n $(GNUPG_NAME) \
		-a $(ARCH) \
	    -v $(GNUPG_VERSION) \
		-p $(PWD)/$@ \
		--url $(PACKAGE_URL) \
	    --iteration $(RELEASE) \
		--provides gpg2 \
		--provides gnupg2 \
		--provides gpgsm \
		--provides gnupg-agent \
		--maintainer $(MAINTAINER) \
	    -C $(PKG_DIR)
