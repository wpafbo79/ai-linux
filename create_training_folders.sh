#!/bin/bash

set -e -u -o pipefail

if [ $# -ne 1 ]; then
    echo "Illegal number of parameters"
    exit 1
fi

mkdir -p -v "$1"/{embeddings,logs,orig,prep,train,trained}/
