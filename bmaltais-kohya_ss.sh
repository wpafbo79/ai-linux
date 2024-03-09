#!/bin/bash

set -e -u -o pipefail;

declare progname=${0##*/};
declare progpath=${0%/*};

pushd "${progpath}";

source common.sh;

declare tag;

declare parentdir=bmaltais/;
declare projectsubdir=kohya_ss/;

declare optupdate="false";

while getopts ":u" arg; do
  case $arg in
    u) # Update the codebase
      optupdate="true";
      ;;
  esac
done

aptinstall \
  libgl1 \
  libglib2.0-0 \
  libgoogle-perftools-dev \
  python3-pip \
  python3-tk \
  python3.10-venv;

cd "${progpath}";
./nvidia-cuda.sh;

export LD_LIBRARY_PATH=${LD_LIBRARY_PATH:-}:/usr/lib/wsl/lib/:/usr/local/cuda/lib64/;

mkdir --parents --verbose "${rootdir}${parentdir}";
cd "${rootdir}${parentdir}";

if [ ! -d "${projectsubdir}" ]; then
  optupdate="true";

  git clone https://github.com/bmaltais/kohya_ss.git "${projectsubdir}";
fi

cd "${projectsubdir}";

if [ "${optupdate}" == "true" ]; then
  git fetch --all;
  git checkout master;
  git pull;
fi

if [ ! -d venv ]; then
  python3.10 -m venv venv/;
fi

source venv/bin/activate;

tag=$(git tag |
  grep --extended-regexp --invert-match "(pre|RC)" |
  sort --reverse --version-sort |
  head --lines=1);

if [ "${optupdate}" == "true" ]; then
  git checkout "${tag}";
fi

python -m pip install --upgrade pip;
python -m pip install scipy;

linkcentraldir "training-data" training-data/;

linklogsdir "${parentdir}${projectsubdir}" logs/;

linkmodelsdir "embeddings" embeddings/;

./setup.sh --no-git-update;

./gui.sh;
