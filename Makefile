BINARY := go-cli-sandbox
MAKEFILE_DIR := $(dir $(abspath $(lastword $(MAKEFILE_LIST))))

PATH := $(PATH):${MAKEFILE_DIR}bin
SHELL := env PATH="$(PATH)" /bin/bash
# for go
export CGO_ENABLED = 0
GOARCH = amd64

COMMIT=$(shell git rev-parse HEAD)
BRANCH=$(shell git rev-parse --abbrev-ref HEAD)
GIT_URL=local-git://

LDFLAGS := -ldflags "-X main.VERSION=${VERSION} -X main.COMMIT=${COMMIT} -X main.BRANCH=${BRANCH}"

build: build-linux

build-default:
	go build ${LDFLAGS} -o build/${BINARY}

build-linux:
	GOOS=linux GOARCH=${GOARCH} go build ${LDFLAGS} -o build/${BINARY}-linux-${GOARCH} .

prepare: mod

mod:
	go mod download

test:
	go test $(shell go list ${MAKEFILE_DIR}/...)

lint:
	if ! [ -x bin/golangci-lint ]; then \
		wget -O - -q https://raw.githubusercontent.com/golangci/golangci-lint/master/install.sh| sh -s v1.24.0 ; \
	fi
	golangci-lint run --concurrency 2

vet:
	go vet ./...

clean:
	git clean -f -X app bin build

.PHONY:	test clean
