#!/bin/bash

set -e -u -o pipefail;

declare progname=${0##*/};
declare progpath=${0%/*};

pushd "${progpath}";

source common.sh;

declare tag;

declare parentdir=bmaltais/;
declare projectsubdir=kohya_ss/;

aptinstall \
  libgl1 \
  libglib2.0-0 \
  libgoogle-perftools-dev \
  python3-pip \
  python3-tk \
  python3.10-venv;

cd "${progpath}";
./nvidia-cuda.sh;

mkdir --parents --verbose "${rootdir}${parentdir}";
cd "${rootdir}${parentdir}";

if [ ! -d "${projectsubdir}" ]; then
  git clone https://github.com/bmaltais/kohya_ss.git "${projectsubdir}";
fi

cd "${projectsubdir}";

if [ ! -d venv ]; then
  python3.10 -m venv venv/;
fi

source venv/bin/activate;

python3.10 -m pip install --upgrade pip;

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:/usr/lib/wsl/lib/:/usr/local/cuda/lib64/;

tag=$(git tag |
  grep --extended-regexp --invert-match "(pre|RC)" |
  sort --reverse --version-sort |
  head --lines=1);

git checkout "${tag}";

linkcentraldir "training-data" training-data/;

linklogsdir "${parentdir}${projectsubdir}" logs/;

linkmodelsdir "embeddings" embeddings/;

./setup.sh --no-git-update;

./gui.sh;
