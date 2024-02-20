#!/bin/bash

if [ ! -f ".env" ]; then
  echo "Create .env"
  exit 1
fi

source .env

if [ -z "${PING_DEST}" ]; then
  echo "Add ping destinations to the PING_DEST environment variable as comma separated values."
  exit 1
fi

if [ -z "${LOCATION}" ]; then
  echo "Set the LOCATION environment variable to indicate where this computer is located (what airport code)."
  exit 1
fi

go run ./run.go
