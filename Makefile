#!make

SHELL=bash

.PHONY: clean
clean:
	rm -rf ./bin/*

.PHONY: build
build: clean
	mkdir ./bin
	go build ./ping.go -o ./bin/ping
