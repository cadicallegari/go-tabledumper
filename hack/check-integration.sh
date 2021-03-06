#!/usr/bin/env bash

set -o errexit
set -o nounset

if [ $# -eq 0 ]; then
    for d in $(go list ./... | grep -v vendor); do
        go test -v -race -timeout=100s -tags=integration $d
    done
    exit
fi

pkg=$1
testname=$2
echo "Running test pkg:" $pkg " name: " $testname
go test -v -race -timeout=100s -tags=integration $pkg --run $testname
