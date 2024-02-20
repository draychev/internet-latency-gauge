#!make

SHELL=bash

.PHONY: clean
clean:
	rm -rf ./bin/*

.PHONY: build-docker
build-docker:
	docker build -t internet-latency-gauge .

.PHONY: build-go
build-go: clean
	mkdir -p ./bin
	CGO_ENABLED=0 go build -a -ldflags '-extldflags "-static"' -o ./bin/ping ./ping.go

.PHONY: build
build: clean build-go build-docker
