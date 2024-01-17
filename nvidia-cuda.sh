#!/bin/bash

set -e -u -o pipefail;

declare progname=${0##*/};
declare progpath=${0%/*};

pushd "${progpath}";

source common.sh;

declare arch="x86_64";
declare keyring="cuda-keyring_1.1-1_all.deb";
declare os="wsl-ubuntu";

downloadpkg https://developer.download.nvidia.com/compute/cuda/repos/${os}/${arch}/${keyring};

dpkginstall "${keyring}";

rm --force --verbose "${keyring}";

aptinstall \
  cuda-toolkit-11-8;
