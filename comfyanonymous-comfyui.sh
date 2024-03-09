#!/bin/bash

set -e -u -o pipefail;

declare progname=${0##*/};
declare progpath=${0%/*};

pushd "${progpath}";

source common.sh;

declare tag;

declare parentdir=comfyanonymous/;
declare projectsubdir=comfyui/;

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

  git clone https://github.com/comfyanonymous/ComfyUI.git "${projectsubdir}";
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
  grep --extended-regexp --invert-match "(latest)" |
  sort --reverse --version-sort |
  head --lines=1 ||
  echo "HEAD");

if [ "${optupdate}" == "true" ]; then
  git checkout "${tag}";
fi

python -m pip install --upgrade pip;
python -m pip install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu121
python -m pip install -r requirements.txt

linkmodelsdir "clip" models/clip/;
linkmodelsdir "clip_vision" models/clip_vision/;
linkmodelsdir "controlnet" models/controlnet/;
linkmodelsdir "embeddings" models/embeddings/;
linkmodelsdir "gligen" models/gligen/;
linkmodelsdir "hypernetworks" models/hypernetworks/;
linkmodelsdir "lora" models/loras/;
linkmodelsdir "stable-diffusion" models/checkpoints/;
linkmodelsdir "stable-diffusion" models/diffusers/;
linkmodelsdir "t2i-adaptor" models/style_models/;
linkmodelsdir "unet" models/unet/;
linkmodelsdir "upscale_models" models/upscale_models/;
linkmodelsdir "vae" models/vae/;
linkmodelsdir "vae-approx" models/vae_approx/;

linkoutputsdir "${parentdir}${projectsubdir}" output/;

python main.py;
