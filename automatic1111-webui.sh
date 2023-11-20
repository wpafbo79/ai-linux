#!/bin/bash

set -e -u -o pipefail;

declare progname=${0##*/};
declare progpath=${0%/*};

pushd "${progpath}";

source common.sh;

declare tag;

declare parentdir=automatic1111/;
declare projectsubdir=stable-diffusion-webui/;

aptinstall \
  libgl1 \
  libglib2.0-0 \
  libgoogle-perftools-dev \
  python3-pip \
  python3.10-venv;

mkdir -pv "${rootdir}${parentdir}";
cd "${rootdir}${parentdir}";

if [ ! -d "${projectsubdir}" ]; then
  git clone https://github.com/AUTOMATIC1111/stable-diffusion-webui.git "${projectsubdir}";
fi

cd "${projectsubdir}";

if [ ! -d venv ]; then
  python3.10 -m venv venv/;
fi

source venv/bin/activate;

python3.10 -m pip install --upgrade pip;
#python3.10 -m pip install --upgrade httpcore;
python3.10 -m pip install httpx==0.24.1;

tag=$(git tag | grep -Ev "(pre|RC)" | sort -r | head -n 1);

git checkout "${tag}";

linkcentraldir "textual_inversion_templates" textual_inversion_templates/;

linkconfigsdir "${parentdir}${projectsubdir}" config/;

linkmodelsdir "embeddings" embeddings/;

linkmodelsdir "codeformer" models/Codeformer/;
linkmodelsdir "deepbooru" models/deepbooru/;
linkmodelsdir "esrgan" models/ESRGAN/;
linkmodelsdir "gfpgan" models/GFPGAN/;
linkmodelsdir "hypernetworks" models/hypernetworks/;
linkmodelsdir "karlo" models/karlo/;
linkmodelsdir "ldsr" models/LDSR/;
linkmodelsdir "lora" models/Lora/;
linkmodelsdir "stable-diffusion" models/Stable-diffusion/;
linkmodelsdir "swinir" models/SwinIR/;
linkmodelsdir "vae" models/VAE/;
linkmodelsdir "vae-approx" models/VAE-approx/;

linkoutputsdir "${parentdir}${projectsubdir}" outputs/;

#mvlinkfile config.json config/;
#mvlinkfile params.txt config/;
#mvlinkfile styles.csv config/;
#mvlinkfile ui-config.json config/;

git restore webui-user.sh;
sed -e 's/#python_cmd="python3"/python_cmd="python3.10"/' webui-user.sh -i;
sed -e 's/#export COMMANDLINE_ARGS=""/#export COMMANDLINE_ARGS="--api --xformers"/' webui-user.sh -i;

./webui.sh;