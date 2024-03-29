#!/bin/bash

set -e -u -o pipefail;

declare progname=${0##*/};
declare progpath=${0%/*};

pushd ${progpath};

source common.sh;

declare parentdir=vladmandic/;
declare projectsubdir=automatic/;

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
  python3.10-venv;

mkdir --parents --verbose "${rootdir}${parentdir}";
cd "${rootdir}${parentdir}";

if [ ! -d "${projectsubdir}" ]; then
  optupdate="true";

  git clone https://github.com/vladmandic/automatic.git "${projectsubdir}";
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

python -m pip install --upgrade pip;
#python -m pip install --upgrade httpcore;
#python -m pip install httpx==0.24.1;

linkmodelsdir "chainner" models/chaiNNer/;
linkmodelsdir "codeformer" models/Codeformer/;
linkmodelsdir "controlnet" models/ControlNet/;
linkmodelsdir "diffusers" models/Diffusers/;
linkmodelsdir "embeddings" models/embeddings/;
linkmodelsdir "esrgan" models/ESRGAN/;
linkmodelsdir "gfpgan" models/GFPGAN/;
linkmodelsdir "hypernetworks" models/hypernetworks/;
linkmodelsdir "karlo" models/karlo/;
linkmodelsdir "ldsr" models/LDSR/;
linkmodelsdir "lora" models/Lora/;
linkmodelsdir "realesrgan" models/RealESRGAN/;
linkmodelsdir "reference" models/Reference/;
linkmodelsdir "scunet" models/SCUNet/;
linkmodelsdir "sdupscale" models/SDUpscale/;
linkmodelsdir "stable-diffusion" models/Stable-diffusion/;
linkmodelsdir "styles" models/styles/;
linkmodelsdir "swinir" models/SwinIR/;
linkmodelsdir "vae" models/VAE/;
linkmodelsdir "vae-approx" models/VAE-approx/;

linkoutputsdir "${parentdir}${projectsubdir}" outputs/;

#mvlinkfile config.json config/;
#mvlinkfile params.txt config/;
#mvlinkfile styles.csv config/;
#mvlinkfile ui-config.json config/;

./webui.sh;
