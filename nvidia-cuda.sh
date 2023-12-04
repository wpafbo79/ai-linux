#!/bin/bash

set -e -u -o pipefail;

declare progname=${0##*/};
declare progpath=${0%/*};

pushd "${progpath}";

source common.sh;

declare arch="x86_64";
declare keyring="cuda-keyring_1.1-1_all.deb";
declare os="wsl-ubuntu";

wget --verbose https://developer.download.nvidia.com/compute/cuda/repos/${os}/${arch}/${keyring};

"${elevate}" dpkg --install "${keyring}";

rm --verbose "${keyring}";

aptinstall \
  cuda-toolkit-12-3;
