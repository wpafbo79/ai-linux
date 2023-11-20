#!/bin/bash

set -e -u -o pipefail;

declare progname=${0##*/};
declare progpath=${0%/*};

pushd ${progpath};

source common.sh;

declare parentdir=vladmandic/;
declare projectsubdir=automatic/;

aptinstall \
  libgl1 \
  libglib2.0-0 \
  libgoogle-perftools-dev \
  python3-pip \
  python3.10-venv;

mkdir -pv "${rootdir}${parentdir}";
cd "${rootdir}${parentdir}";

if [ ! -d "${projectsubdir}" ]; then
  git clone https://github.com/vladmandic/automatic.git "${projectsubdir}";
fi

cd "${projectsubdir}";

if [ ! -d venv ]; then
  python3.10 -m venv venv/;
fi

source venv/bin/activate;

python3.10 -m pip install --upgrade pip;
#python3.10 -m pip install --upgrade httpcore;
#python3.10 -m pip install httpx==0.24.1;

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
