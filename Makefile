SHELL := bash
PATH := bin:${PATH}
DATE := `date '+%Y%m%d'`
THIS_DIR:=$(shell pwd)

build:
		docker build --rm --no-cache -t nginx-build .

pkg:
		docker build --rm --no-cache -t nginx-pkg - < Dockerfile.pkg
		docker run -it -v "$(CURDIR)/pkg":/pkg nginx-pkg /pkg.sh

image:
		docker build --rm -t nginx-luajit-run - < Dockerfile.image

.PHONY: build
