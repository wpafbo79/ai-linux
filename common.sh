declare centraldir=~/ai/;
declare centralconfigsdir=${centraldir}configs/;
declare centrallogsdir=${centraldir}logs/;
declare centralmodelsdir=${centraldir}models/;
declare centraloutputsdir=${centraldir}outputs/;
declare elevate="";
declare rootdir=~/devel/github/;

if ! [ $(id --user) == 0 ]; then
  echo "Script may require root priviledge.";
  elevate="sudo";
fi

function _linkdir() {
  declare usagelink;

  declare commonsubdir=${1};
  declare usagepath=${2};

  usagelink=${usagepath%/};

  if [ ! -L "${usagelink}" ]; then
    mkdir --parents --verbose "${commonsubdir}";
    mkdir --parents --verbose "${usagepath}";

    rsync --archive --hard-links --ignore-existing --update --verbose "${usagepath}/" "${commonsubdir}";

    mv --verbose "${usagelink}"{,.orig};

    ln --force --symbolic "${commonsubdir}" "${usagelink}";
  fi
}

function aptinstall() {
  declare grepstr;
  declare installedcnt;

  declare packagecnt=${#};
  declare packagelist="${@}";

  grepstr="^($(echo ${packagelist} | tr " " "|"))/";

  installedcnt=$(apt list --installed |
      grep --extended-regexp "${grepstr}" |
      wc --lines) || :

  if [ ${installedcnt} -ne ${packagecnt} ]; then
    "${elevate}" apt-get update;
    "${elevate}" apt-get install ${packagelist} --yes;
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

function linklogsdir() {
  declare usagelink;

  declare commonsubdir=${1};
  declare usagepath=${2};

  _linkdir "${centrallogsdir}/${commonsubdir}" "${usagepath}";
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
    mkdir --parents --verbose "${dir}";

    cp --archive --no-clobber --verbose "${file}" "${dir}";
    mv --verbose "${file}"{,.orig}

    ln --force --symbolic "${dir}/${file}" .;
  fi
}
