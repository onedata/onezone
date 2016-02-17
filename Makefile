# distro for package building (oneof: wily, fedora-23-x86_64)
DISTRIBUTION            ?= none
DOCKER_RELEASE          ?= development
DOCKER_REG_USER         ?= ""
DOCKER_REG_PASSWORD     ?= ""
DOCKER_REG_EMAIL        ?= ""

ONEZONE_VERSION	        ?= $(shell git describe --tags --always | tr - .)
ONEZONE_BUILD           ?= 1
CLUSTER_MANAGER_VERSION	?= $(shell git -C cluster_manager describe --tags --always | tr - .)
OZ_WORKER_VERSION       ?= $(shell git -C oz_worker describe --tags --always | tr - .)
OZ_PANEL_VERSION        ?= $(shell git -C onepanel describe --tags --always | tr - .)

.PHONY: package.tar.gz

all: build

##
## Macros
##

make = $(1)/make.py -s $(1) -r .
clean = $(call make, $(1)) clean
make_rpm = $(call make, $(1)) -e DISTRIBUTION=$(DISTRIBUTION) --privileged --group mock -i onedata/rpm_builder $(2)
mv_rpm = mv $(1)/package/packages/*.src.rpm package/$(DISTRIBUTION)/SRPMS && \
	mv $(1)/package/packages/*.x86_64.rpm package/$(DISTRIBUTION)/x86_64
make_deb = $(call make, $(1)) -e DISTRIBUTION=$(DISTRIBUTION) --privileged --group sbuild -i onedata/deb_builder $(2)
mv_deb = mv $(1)/package/packages/*.orig.tar.gz package/$(DISTRIBUTION)/source && \
	mv $(1)/package/packages/*.dsc package/$(DISTRIBUTION)/source && \
	mv $(1)/package/packages/*.diff.gz package/$(DISTRIBUTION)/source || \
	mv $(1)/package/packages/*.debian.tar.xz package/$(DISTRIBUTION)/source && \
	mv $(1)/package/packages/*_amd64.changes package/$(DISTRIBUTION)/source && \
	mv $(1)/package/packages/*_amd64.deb package/$(DISTRIBUTION)/binary-amd64
unpack = tar xzf $(1).tar.gz

##
## Submodules
##

branch = $(shell git rev-parse --abbrev-ref HEAD)
submodules:
	./onedata_submodules.sh init
ifeq ($(branch),develop)
	./onedata_submodules.sh update --remote
else
	./onedata_submodules.sh update
endif

##
## Build
##

build: build_onepanel build_oz_worker build_cluster_manager

build_onepanel: submodules
	$(call make, onepanel) -e REL_TYPE=globalregistry

build_oz_worker: submodules
	$(call make, oz_worker)

build_cluster_manager: submodules
	$(call make, cluster_manager)

##
## Test
##

test_packaging: submodules
	./test_run.py --test-dir tests/packaging -s

##
## Clean
##

clean_all: clean_onepanel clean_oz_worker clean_cluster_manager clean_packages

clean_onepanel:
	$(call clean, onepanel) -e REL_TYPE=globalregistry

clean_oz_worker:
	$(call clean, oz_worker)

clean_cluster_manager:
	$(call clean, cluster_manager)

clean_packages:
	rm -rf onezone_meta/onezone.spec \
		onezone_meta/onezone/DEBIAN/control \
		onezone_meta/package package

##
## RPM packaging
##

rpm: rpm_onepanel rpm_oz_worker rpm_cluster_manager
	cp -f onezone_meta/onezone.spec.template onezone_meta/onezone.spec
	sed -i 's/{{onezone_version}}/$(ONEZONE_VERSION)/g' onezone_meta/onezone.spec
	sed -i 's/{{onezone_build}}/$(ONEZONE_BUILD)/g' onezone_meta/onezone.spec
	sed -i 's/{{cluster_manager_version}}/$(CLUSTER_MANAGER_VERSION)/g' onezone_meta/onezone.spec
	sed -i 's/{{oz_worker_version}}/$(OZ_WORKER_VERSION)/g' onezone_meta/onezone.spec
	sed -i 's/{{oz_panel_version}}/$(OZ_PANEL_VERSION)/g' onezone_meta/onezone.spec

	bamboos/docker/make.py -i onedata/rpm_builder --privileged --group mock -c \
	        mock --buildsrpm --spec onezone_meta/onezone.spec \
	        --sources onezone_meta --root $(DISTRIBUTION) \
	        --resultdir onezone_meta/package/packages

	bamboos/docker/make.py -i onedata/rpm_builder --privileged --group mock -c \
	        mock --rebuild onezone_meta/package/packages/*.src.rpm \
	        --root $(DISTRIBUTION) --resultdir onezone_meta/package/packages

	$(call mv_rpm, onezone_meta)

rpm_onepanel: clean_onepanel rpmdirs
	$(call make_rpm, onepanel, package) -e REL_TYPE=globalregistry
	$(call mv_rpm, onepanel)

rpm_oz_worker: clean_oz_worker rpmdirs
	$(call make_rpm, oz_worker, package)
	$(call mv_rpm, oz_worker)

rpm_cluster_manager: clean_cluster_manager rpmdirs
	$(call make_rpm, cluster_manager, package)
	$(call mv_rpm, cluster_manager)

rpmdirs:
	mkdir -p package/$(DISTRIBUTION)/SRPMS package/$(DISTRIBUTION)/x86_64

##
## DEB packaging
##

deb: deb_onepanel deb_oz_worker deb_cluster_manager
	cp -f onezone_meta/onezone/DEBIAN/control.template onezone_meta/onezone/DEBIAN/control
	sed -i 's/{{onezone_version}}/$(ONEZONE_VERSION)/g' onezone_meta/onezone/DEBIAN/control
	sed -i 's/{{onezone_build}}/$(ONEZONE_BUILD)/g' onezone_meta/onezone/DEBIAN/control
	sed -i 's/{{cluster_manager_version}}/$(CLUSTER_MANAGER_VERSION)/g' onezone_meta/onezone/DEBIAN/control
	sed -i 's/{{oz_worker_version}}/$(OZ_WORKER_VERSION)/g' onezone_meta/onezone/DEBIAN/control
	sed -i 's/{{oz_panel_version}}/$(OZ_PANEL_VERSION)/g' onezone_meta/onezone/DEBIAN/control

	bamboos/docker/make.py -s onezone_meta -r . -c 'dpkg-deb -b onezone'
	mv onezone_meta/onezone.deb package/$(DISTRIBUTION)/binary-amd64/onezone_$(ONEZONE_VERSION)-$(ONEZONE_BUILD)_amd64.deb

deb_onepanel: clean_onepanel debdirs
	$(call make_deb, onepanel, package) -e REL_TYPE=globalregistry
	$(call mv_deb, onepanel)

deb_oz_worker: clean_oz_worker debdirs
	$(call make_deb, oz_worker, package)
	$(call mv_deb, oz_worker)

deb_cluster_manager: clean_cluster_manager debdirs
	$(call make_deb, cluster_manager, package)
	$(call mv_deb, cluster_manager)

debdirs:
	mkdir -p package/$(DISTRIBUTION)/source package/$(DISTRIBUTION)/binary-amd64

##
## Package artifact
##

package.tar.gz:
	tar -chzf package.tar.gz package

##
## Docker artifact
##

docker:
	./dockerbuild.py --user $(DOCKER_REG_USER) --password $(DOCKER_REG_PASSWORD) \
                         --email $(DOCKER_REG_EMAIL) --build-arg RELEASE=$(DOCKER_RELEASE) \
                         --name onezone --publish --remove packaging
