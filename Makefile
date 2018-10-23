# Default git branch to build in RPM
ifndef GITBRANCH
GITBRANCH=HEAD
endif

all: docs

doc docs:
	$(MAKE) -C doc html

deb:
	dpkg-buildpackage -us -uc
	lintian | tee -a lintian.log

upload_packages: deb
	aptly/upload_packages.sh

include_packages:
	aptly/include_packages.sh

publish_packages:
	aptly/publish_packages.sh

vagrant: deb
	cd vagrant && vagrant up --provision

ansible: deb
	cd vagrant && ./elephant-shed.yml $(ANSIBLE_ARGS)

deploy_openpower: vagrant/inventory.openpower
	cd vagrant && ./elephant-shed.yml $(ANSIBLE_ARGS) \
	  -i inventory.openpower \
	  -e "repo=http"

clean:
	$(MAKE) -C doc clean
	$(MAKE) -C grafana clean
	rm -rf rpm/SOURCES/ rpm/SPECS rpm/BUILD rpm/BUILDROOT rpm/RPMS rpm/SRPMS

# rpm

DPKG_VERSION=$(shell sed -ne '1s/.*(//; 1s/).*//p' debian/changelog)
RPMDIR=$(CURDIR)/rpm/
TARBALL=$(RPMDIR)/SOURCES/elephant-shed_$(DPKG_VERSION).tar.xz
TMATESOURCE=$(CURDIR)/rpm/SOURCES/$(shell rpmspec --srpm --query --queryformat '%{Source}' rpm/tmate.spec)

rpmbuild: $(TMATESOURCE) $(TARBALL)
	rpmbuild -D"%_topdir $(RPMDIR)" --define='version $(DPKG_VERSION)' -ba rpm/tmate.spec
	rpmbuild -D"%_topdir $(RPMDIR)" --define='version $(DPKG_VERSION)' -ba rpm/elephant-shed.spec

$(TMATESOURCE):
	mkdir -p rpm/SOURCES
	spectool -S -g -C rpm/SOURCES rpm/tmate.spec

$(TARBALL):
	mkdir -p $(dir $(TARBALL))
	git archive --prefix=elephant-shed-$(DPKG_VERSION)/ $(GITBRANCH) | xz > $(TARBALL)
