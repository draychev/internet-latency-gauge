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
	go build -o ./bin/ping ./ping.go

.PHONY: build
build: clean build-go build-docker
