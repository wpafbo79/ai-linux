declare centraldir=~/ai/;
declare centralconfigsdir=${centraldir}configs/;
declare centralmodelsdir=${centraldir}models/;
declare centraloutputsdir=${centraldir}outputs/;
declare elevate="";
declare rootdir=~/devel/github/;

if ! [ $(id -u) == 0 ]; then
  echo "Script may require root priviledge.";
  elevate="sudo";
fi

function _linkdir() {
  declare usagelink;

  declare commonsubdir=${1};
  declare usagepath=${2};

  usagelink=${usagepath%/};

  if [ ! -L "${usagelink}" ]; then
    mkdir -pv "${commonsubdir}";
    mkdir -pv "${usagepath}";

    rsync -aHuv --ignore-existing "${usagepath}/" "${commonsubdir}";

    mv -v "${usagelink}"{,.orig};

    ln -fs "${commonsubdir}" "${usagelink}";
  fi
}

function aptinstall() {
  declare grepstr;
  declare installedcnt;

  declare packagecnt=${#};
  declare packagelist="${@}";

  grepstr="($(echo ${packagelist} | tr " " "|"))/";

  installedcnt=$(apt list --installed |
      grep -E "${grepstr}" |
      wc -l);

  if [ ${installedcnt} -ne ${packagecnt} ]; then
    $elevate apt-get install ${packagelist} -y;
  fi
}

function linkcentraldir() {
  declare usagelink;

  declare commonsubdir=${1};
  declare usagepath=${2};

  _linkdir "${centraldir}/${commonsubdir}" "${usagepath}";
}

function linkconfigsdir() {
  declare usagelink;

  declare commonsubdir=${1};
  declare usagepath=${2};

  _linkdir "${centralconfigsdir}/${commonsubdir}" "${usagepath}";
}

function linkmodelsdir() {
  declare usagelink;

  declare commonsubdir=${1};
  declare usagepath=${2};

  _linkdir "${centralmodelsdir}/${commonsubdir}" "${usagepath}";
}

function linkoutputsdir() {
  declare usagelink;

  declare commonsubdir=${1};
  declare usagepath=${2};

  _linkdir "${centraloutputsdir}/${commonsubdir}" "${usagepath}";
}

function mvlinkfile() {
  declare file=${1};
  declare dir=${2};

  touch "${file}";

  if [ ! -L "${file}" ]; then
    mkdir -pv "${dir}";

    cp -anv "${file}" "${dir}";
    mv -v "${file}"{,.orig}

    ln -fs "${dir}/${file}" .;
  fi
}
