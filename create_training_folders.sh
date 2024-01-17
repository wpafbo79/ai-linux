#!/bin/bash

set -e -u -o pipefail;

declare progname=${0##*/};
declare progpath=${0%/*};

pushd "${progpath}";

source common.sh;

if [ $# -ne 1 ]; then
    echo "Illegal number of parameters";
    exit 1;
fi

declare basedir;
declare configfile;

declare base=$1;

basedir=$(echo "${centraltrainingdir}/${base}/" | tr -s "/");

mkdir \
  "${basedir}"{config,embeddings,logs,lora,orig,prep,trained} \
  "${basedir}"train/100_desc \
  -p -v;


configfile="${basedir}"config/v0.1.json;

if [ ! -f "${configfile}" ]; then
  cat << EOF > "${configfile}"
{
  "output_name": "${base}_v0.1",
  "sample_prompts": "${base} --w 512 -h 512 --s 30",
  "sample_sampler": "euler_a",
  "xformers": "xformers"
}
EOF
fi
