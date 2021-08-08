SHELL:=/bin/bash
PWD ?= $(PWD)

.DEFAULT_GOAL := all

all: apkbuild build

.PHONY: apkbuild
apkbuild:
	cd ${PWD}/apk-build ; \
	make build

.PHONY: build
build: 
	cd ${PWD} ; \
	docker build -t securecompliance/gvm:no-data -t securecompliance/gvm:latest . ; \
	docker build --build-arg OPT_PDF=1 -t securecompliance/gvm:no-data-full . ; \
	docker build --build-arg SETUP=1 -t securecompliance/gvm:data . ; 
	docker build --build-arg SETUP=1 --build-arg OPT_PDF=1 -t securecompliance/gvm:data-full . ; 

run-full:
	mkdir -p ${PWD}/storage/postgres-db
	mkdir -p ${PWD}/storage/openvas-plugins
	mkdir -p ${PWD}/storage/gvm
	mkdir -p ${PWD}/storage/ssh
	docker run --rm --publish 8080:9392 --publish 5432:5432 --publish 2222:22 \
	--env DB_PASSWORD="postgres DB password" --env PASSWORD="webUI password" \
	--volume "${PWD}/storage/postgres-db:/opt/database" \
	--volume "${PWD}/storage/openvas-plugins:/var/lib/openvas/plugins" \
	--volume "${PWD}/storage/gvm:/var/lib/gvm" \
	--volume "${PWD}/storage/ssh:/etc/ssh" \
	--name gvm securecompliance/gvm:data-full