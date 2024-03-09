#!/bin/bash

set -e -u -o pipefail;

declare progname=${0##*/};
declare progpath=${0%/*};

pushd "${progpath}";

source common.sh;

declare tag;

declare parentdir=automatic1111/;
declare projectsubdir=stable-diffusion-webui/;

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

  git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "${projectsubdir}";
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

python3.10 -m pip install --upgrade pip;
#python3.10 -m pip install --upgrade httpcore;
python3.10 -m pip install httpx==0.24.1;

linkcentraldir "textual_inversion_templates" textual_inversion_templates/;

linkconfigsdir "${parentdir}${projectsubdir}" config/;

linkmodelsdir "embeddings" embeddings/;

linkmodelsdir "blip" models/BLIP/;
linkmodelsdir "clip-interrogator" models/clip-interrogator/;
linkmodelsdir "codeformer" models/Codeformer/;
linkmodelsdir "controlnet" models/ControlNet/;
linkmodelsdir "deepbooru" models/deepbooru/;
linkmodelsdir "esrgan" models/ESRGAN/;
linkmodelsdir "gfpgan" models/GFPGAN/;
linkmodelsdir "hed" models/hed/;
linkmodelsdir "hypernetworks" models/hypernetworks/;
linkmodelsdir "karlo" models/karlo/;
linkmodelsdir "ldsr" models/LDSR/;
linkmodelsdir "lora" models/Lora/;
linkmodelsdir "lycoris" models/LyCORIS/;
linkmodelsdir "mlsd" models/mlsd/;
linkmodelsdir "normal_bae" models/normal_bae/;
linkmodelsdir "opencv" models/opencv/;
linkmodelsdir "openpose" models/openpose/;
linkmodelsdir "pidinet" models/pidinet/;
linkmodelsdir "realesrgan" models/RealESRGAN/;
linkmodelsdir "stable-diffusion" models/Stable-diffusion/;
linkmodelsdir "swinir" models/SwinIR/;
linkmodelsdir "torch_deepdanbooru" models/torch_deepdanbooru/;
linkmodelsdir "vae" models/VAE/;
linkmodelsdir "vae-approx" models/VAE-approx/;

linkoutputsdir "${parentdir}${projectsubdir}" outputs/;

mvlinkfile config.json config/;
mvlinkfile params.txt config/;
mvlinkfile styles.csv config/;
mvlinkfile ui-config.json config/;

git restore webui-user.sh;
sed \
  --expression='s/#python_cmd="python3"/python_cmd="python3.10"/' \
  --expression='s/#export COMMANDLINE_ARGS=""/#export COMMANDLINE_ARGS="--api --xformers"/' \
  webui-user.sh \
  --in-place;

./webui.sh;
