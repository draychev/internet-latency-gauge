#!make

SHELL=bash

.PHONY: clean
clean:
	rm -rf ./bin/*

.PHONY: build
build: clean
	mkdir -p ./bin
	go build -o ./bin/ping ./ping.go
