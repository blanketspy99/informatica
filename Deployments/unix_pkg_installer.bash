#!/usr/bin/env bash
#
# Purpose: A wrapper for all Unix package managers
# License: Fair license (http://www.opensource.org/licenses/fair)
# Source : http://github.com/icy/pacapt/
# Version: 2.4.3
# Authors: Anh K. Huynh et al.

# Copyright (C) 2010 - 2020 \
#                           | 10sr (10sr)
#                           | Alexander Dupuy (dupuy)
#                           | Anh K. Huynh (icy)
#                           | Antony Lee (anntzer)
#                           | Alex Lyon (Arcterus)
#                           | Carl X. Su (bcbcarl)
#                           | Cuong Manh Le (Gnouc)
#                           | Daniel YC Lin (dlintw)
#                           | Danny George (dangets)
#                           | Darshit Shah (darnir)
#                           | Dmitry Kudriavtsev (dkudriavtsev)
#                           | Eric Crosson (EricCrosson)
#                           | Evan Relf (evanrelf)
#                           | GijsTimmers (GijsTimmers)
#                           | Hà-Dương Nguyễn (cmpitg)
#                           | Huy Ngô (NgoHuy)
#                           | James Pearson (xiongchiamiov)
#                           | Janne Heß (dasJ)
#                           | Jiawei Zhou (4679)
#                           | Karol Blazewicz
#                           | Kevin Brubeck (unhammer)
#                           | Konrad Borowski (xfix)
#                           | Kylie McClain (somasis)
#                           | Valerio Pizzi (Pival81)
#                           | Siôn Le Roux (sinisterstuf)
#                           | Thiago Perrotta (thiagowfx)
#                           | Vojtech Letal (letalvoj)
#
# Usage of the works is permitted provided that this instrument is
# retained with the works, so that any entity that uses the works is
# notified of this instrument.
#
# DISCLAIMER: THE WORKS ARE WITHOUT WARRANTY.
#

_print_pacapt_version() {
  cat <<_EOF_
pacapt version '2.4.3'

Copyright (C) 2010 - 2020 \\
                          | 10sr (10sr)
                          | Alexander Dupuy (dupuy)
                          | Anh K. Huynh (icy)
                          | Antony Lee (anntzer)
                          | Alex Lyon (Arcterus)
                          | Carl X. Su (bcbcarl)
                          | Cuong Manh Le (Gnouc)
                          | Daniel YC Lin (dlintw)
                          | Danny George (dangets)
                          | Darshit Shah (darnir)
                          | Dmitry Kudriavtsev (dkudriavtsev)
                          | Eric Crosson (EricCrosson)
                          | Evan Relf (evanrelf)
                          | GijsTimmers (GijsTimmers)
                          | Hà-Dương Nguyễn (cmpitg)
                          | Huy Ngô (NgoHuy)
                          | James Pearson (xiongchiamiov)
                          | Janne Heß (dasJ)
                          | Jiawei Zhou (4679)
                          | Karol Blazewicz
                          | Kevin Brubeck (unhammer)
                          | Konrad Borowski (xfix)
                          | Kylie McClain (somasis)
                          | Valerio Pizzi (Pival81)
                          | Siôn Le Roux (sinisterstuf)
                          | Thiago Perrotta (thiagowfx)
                          | Vojtech Letal (letalvoj)

Usage of the works is permitted provided that this
instrument is retained with the works, so that any
entity that uses the works is notified of this instrument.

DISCLAIMER: THE WORKS ARE WITHOUT WARRANTY.
_EOF_
}

export PACAPT_VERSION='2.4.3'

_help() {
  cat <<'EOF'
NAME
  pacapt - An `ArchLinux`'s pacman-like wrapper for many package managers.

SYNTAX

  $ pacapt <option(s)> <operation(s)> <package(s)>

BASIC OPTIONS

    -h or --help    print this help message
    -P              print supported operations
    -V              print version information

SYSGET STYLE OPERATIONS

  update                        Update package database
  upgrade                       Upgrade system
  install <options> <packages>  Install some packages
  search  <options> <package>   Search some package
  remove  <options> <packages>  Remove some packages
  autoremove                    Remove orphans (WIP; may not work correctly)
  clean                         Clean package manager caches

PACMAN STYLE OPERATIONS

  Query
    -Q              list all installed packages
    -Qc <package>   show package's changelog
    -Qe [<package>] only list explicitly installed packages
    -Qi <package>   print package status
    -Ql <package>   list package's files
    -Qm             list installed packages that aren't available
                    in any installation source
    -Qo <file>      query package that provides <file>
    -Qp <file>      query a package file (don't use package database)
    -Qs <package>   search for installed package

  Synchronize
    -S <package>    install package(s)
    -Sg             list groups
    -Sg <group>     list packages in group
    -Ss <package>   search for packages
    -Su             upgrade the system
    -Sy             update package database
    -Suy            update package database, then upgrade the system

  Remove / Clean up
    -R <packages>   remove some packages
    -Sc             delete old downloaded packages
    -Scc            delete all downloaded packages
    -Sccc           clean variant files.
                    (debian) See also http://dragula.viettug.org/blogs/646

  Upgrade
    -U              upgrade or add package from local file path (or remote uri)

OPTIONS

    -w              download packages but don't install them
    --noconfirm     don't wait for user's confirmation

EXAMPLES

  1. To install a package from Debian's backports repository
      $ pacapt -S foobar -t lenny-backports
      $ pacapt -S -- -t lenny-backports foobar

  2. To update package database and then update your system
      $ pacapt -Syu

  3. To download a package without installing it
      $ pacapt -Sw foobar


ENVIRONMENT

  PACAPT_DEBUG

    This is useful for debugging purpose. The variable can be set to `auto`
    or any valid packager. For example, on `Debian` system the two following
    commands are the same and they will print out what the script would do:

        PACAPT_DEBUG=auto pacman -Su
        PACAPT_DEBUG=dpkg pacman -Su

NOTES

  When being executed on Arch-based system, the tool simply invokes
  the system package manager (`/usr/bin/pacman`).

  Though you can specify option by its own word, for example,
      $ pacapt -S -y -u

  it's always the best to combine them
      $ pacapt -Syu

READMORE

  Please visit https://github.com/icy/pacapt.
EOF

}




_error() {
  echo >&2 "Error: $*"
  return 1
}

_warn() {
  echo >&2 "Warning: $*"
  return 0
}

_die() {
  echo >&2 "$@"
  exit 1
}

_not_implemented() {
  # shellcheck disable=2153
  echo >&2 "${_PACMAN}: '${_POPT}:${_SOPT}:${_TOPT}' operation is invalid or not implemented."
  return 1
}

_removing_is_dangerous() {
  echo >&2 "${_PACMAN}: removing with '$*' is too dangerous"
  return 1
}

_issue2pacman() {
  local _pacman

  _pacman="$1"; shift

  # The following line is added by Daniel YC Lin to support SunOS.
  #
  #   [ `uname` = "$1" ] && _PACMAN="$_pacman" && return
  #
  # This is quite tricky and fast, however I don't think it works
  # on Linux/BSD systems. To avoid extra check, I slightly modify
  # the code to make sure it's only applicable on SunOS.
  #
  [[ "$(uname)" == "SunOS" ]] && _PACMAN="$_pacman" && return

  $GREP -qis "$@" /etc/issue \
  && _PACMAN="$_pacman" && return

  $GREP -qis "$@" /etc/os-release \
  && _PACMAN="$_pacman" && return
}

_PACMAN_detect() {
  _PACMAN_found_from_script_name && return

  _issue2pacman sun_tools "SunOS" && return
  _issue2pacman pacman "Arch Linux" && return
  _issue2pacman dpkg "Debian GNU/Linux" && return
  _issue2pacman dpkg "Ubuntu" && return
  _issue2pacman cave "Exherbo Linux" && return
  _issue2pacman yum "CentOS" && return
  _issue2pacman yum "Red Hat" && return
  #
  # FIXME: The multiple package issue.
  #
  # On #63, Huy commented out this line. This is because new generation
  # of Fedora uses `dnf`, and `yum` becomes a legacy tool. On old Fedora
  # system, `yum` is still detectable by looking up `yum` binary.
  #
  # I'm not sure how to support this case easily. Let's wait, e.g, 5 years
  # from now to make `dnf` becomes a default? Oh no!
  #
  # And here why `pacman` is still smart. Debian has a set of tools.
  # Fedora has `yum` (and a set of add-ons). Now Fedora moves to `dnf`.
  # This means that a package manager is not a heart of a system ;)
  #
  # _issue2pacman yum "Fedora" && return
  _issue2pacman zypper "SUSE" && return
  _issue2pacman pkg_tools "OpenBSD" && return
  _issue2pacman pkg_tools "Bitrig" && return
  _issue2pacman apk "Alpine Linux" && return

  [[ -z "$_PACMAN" ]] || return

  # Prevent a loop when this script is installed on non-standard system
  if [[ -x "/usr/bin/pacman" ]]; then
    $GREP -q "${FUNCNAME[0]}" '/usr/bin/pacman' >/dev/null 2>&1
    [[ $? -ge 1 ]] && _PACMAN="pacman" \
    && return
  fi

  [[ -x "/usr/bin/apt-get" ]] && _PACMAN="dpkg" && return
  [[ -x "/data/data/com.termux/files/usr/bin/apt-get" ]] && _PACMAN="dpkg" && return
  [[ -x "/usr/bin/cave" ]] && _PACMAN="cave" && return
  [[ -x "/usr/bin/dnf" ]] && _PACMAN="dnf" && return
  [[ -x "/usr/bin/yum" ]] && _PACMAN="yum" && return
  [[ -x "/opt/local/bin/port" ]] && _PACMAN="macports" && return
  [[ -x "/usr/bin/emerge" ]] && _PACMAN="portage" && return
  [[ -x "/usr/bin/zypper" ]] && _PACMAN="zypper" && return
  [[ -x "/usr/sbin/pkg" ]] && _PACMAN="pkgng" && return
  # make sure pkg_add is after pkgng, FreeBSD base comes with it until converted
  [[ -x "/usr/sbin/pkg_add" ]] && _PACMAN="pkg_tools" && return
  [[ -x "/usr/sbin/pkgadd" ]] && _PACMAN="sun_tools" && return
  [[ -x "/sbin/apk" ]] && _PACMAN="apk" && return
  [[ -x "/usr/bin/tazpkg" ]] && _PACMAN="tazpkg" && return
  [[ -x "/usr/bin/swupd" ]] && _PACMAN="swupd" && return

  command -v brew >/dev/null && _PACMAN="homebrew" && return

  return 1
}

_translate_w() {

  echo "$_EOPT" | $GREP -q ":w:" || return 0

  local _opt=
  local _ret=0

  case "$_PACMAN" in
  "dpkg")     _opt="-d";;
  "cave")     _opt="-f";;
  "macports") _opt="fetch";;
  "portage")  _opt="--fetchonly";;
  "zypper")   _opt="--download-only";;
  "pkgng")    _opt="fetch";;
  "yum")      _opt="--downloadonly";
    if ! rpm -q 'yum-downloadonly' >/dev/null 2>&1; then
      _error "'yum-downloadonly' package is required when '-w' is used."
      _ret=1
    fi
    ;;
  "tazpkg")
    _error "$_PACMAN: Use '$_PACMAN get' to download and save packages to current directory."
    _ret=1
    ;;
  "apk")      _opt="fetch";;
  *)
    _opt=""
    _ret=1

    _error "$_PACMAN: Option '-w' is not supported/implemented."
    ;;
  esac

  echo $_opt
  return "$_ret"
}

_translate_debug() {
  echo "$_EOPT" | $GREP -q ":v:" || return 0

  case "$_PACMAN" in
  "tazpkg")
    _error "$_PACMAN: Option '-v' (debug) is not supported/implemented by tazpkg"
    return 1
    ;;
  esac

  echo "-v"
}

_translate_noconfirm() {

  echo "$_EOPT" | $GREP -q ":noconfirm:" || return 0

  local _opt=
  local _ret=0

  case "$_PACMAN" in
  # FIXME: Update environment DEBIAN_FRONTEND=noninteractive
  # FIXME: There is also --force-yes for a stronger case
  "dpkg")   _opt="--yes";;
  "dnf")    _opt="--assumeyes";;
  "yum")    _opt="--assumeyes";;
  # FIXME: pacman has 'assume-yes' and 'assume-no'
  # FIXME: zypper has better mode. Similar to dpkg (Debian).
  "zypper") _opt="--no-confirm";;
  "pkgng")  _opt="-y";;
  "tazpkg") _opt="--auto";;
  *)
    _opt=""
    _ret=1
    _error "$_PACMAN: Option '--noconfirm' is not supported/implemented."
    ;;
  esac

  echo $_opt
  return $_ret
}

_translate_all() {
  local _args=""
  local _debug=
  local _noconfirm=

  _debug="$(_translate_debug)"
  _noconfirm="$(_translate_noconfirm)"
  _args="$(_translate_w)" || return 1
  _args="${_args}${_noconfirm:+ }${_noconfirm}" || return 1
  _args="${_args}${_debug:+ }${_debug}" || return 1

  export _EOPT="${_args# }"
}

_print_supported_operations() {
  local _pacman="$1"
  echo -n "pacapt($_pacman): available operations:"
  # shellcheck disable=2016
  $GREP -E "^${_pacman}_[^ \\t]+\\(\\)" "$0" \
  | $AWK -F '(' '{print $1}' \
  | sed -e "s/${_pacman}_//g" \
  | while read -r O; do
      echo -n " $O"
    done
  echo
}


export _SUPPORTED_EXTERNALS="
  :conda
  :tlmgr
  :texlive
  :gem
  :npm
  :pip
"
readonly _SUPPORTED_EXTERNALS

_PACMAN_found_from_script_name() {
  local _tmp_name=
  local _pacman=

  _tmp_name="${BASH_SOURCE[0]:-?}"
  if [[ "$_tmp_name" == "?" ]]; then
    _error "Unable to get script name."
    return 1
  fi

  _tmp_name="${_tmp_name##*/}" # base name (remove everything before the last `/`)
  _tmp_name="${_tmp_name%.*}"  # remove extension if any (remove everything from the last `.`)
  _pacman="${_tmp_name##*-}"   # remove every thing before the last `-`

  if grep -Eq -e ":$_pacman[[:space:]]*" <<< "$_SUPPORTED_EXTERNALS"; then
    export _PACMAN="$_pacman"
    return 0
  else
    export _PACMAN=""
    return 1
  fi
}



_apk_init() {
  :
}

apk_Q() {
  if [[ -z "$_TOPT" ]]; then
    apk info
  else
    _not_implemented
  fi
}

apk_Qi() {
  apk info -a -- "$@"
}

apk_Ql() {
  apk info -L -- "$@"
}

apk_Qo() {
  apk info --who-owns -- "$@"
}

apk_Qs() {
  apk info -- "*${*}*"
}

apk_Qu() {
  apk version -l '<'
}

apk_R() {
  apk del -- "$@"
}

apk_Rn() {
  apk del --purge -- "$@"
}

apk_Rns() {
  apk del --purge -r -- "$@"
}

apk_Rs() {
  apk del -r -- "$@"
}

apk_S() {
  case ${_EOPT} in
    # Download only
    ("fetch") shift
              apk fetch        -- "$@" ;;
          (*) apk add   $_TOPT -- "$@" ;;
  esac
}

apk_Sc() {
  apk cache -v clean
}

apk_Scc() {
  rm -rf /var/cache/apk/*
}

apk_Sccc() {
  apk_Scc
}

apk_Si() {
  apk_Qi "$@"
}

apk_Sii() {
  apk info -r -- "$@"
}

apk_Sl() {
  apk search -v -- "$@"
}

apk_Ss() {
  apk_Sl "$@"
}

apk_Su() {
  apk upgrade
}

apk_Suy() {
  if [ "$#" -gt 0 ]; then
    apk add -U -u -- "$@"
  else
    apk upgrade -U -a
  fi
}

apk_Sy() {
  apk update
}

apk_Sw() {
  apk fetch -- "$@"
}

apk_U() {
  apk add --allow-untrusted -- "$@"
}



_cave_init() {
  shopt -u globstar
}

cave_Q() {
  if [[ "$_TOPT" == "q" ]]; then
    cave show -f "${@:-world}" \
    | grep -v '^$'
  else
    cave show -f "${@:-world}"
  fi
}

cave_Qi() {
  cave show "$@"
}

cave_Ql() {
  if [[ -n "$*" ]]; then
    cave contents "$@"
    return
  fi

  cave show -f "${@:-world}" \
  | grep -v '^$' \
  | while read -r _pkg; do
      if [[ "$_TOPT" == "q" ]]; then
        cave --color no contents "$_pkg"
      else
        cave contents "$_pkg"
      fi
    done
}

cave_Qo() {
  cave owner "$@"
}

cave_Qp() {
  _not_implemented
}

cave_Qu() {
  if [[ -z "$*" ]];then
    cave resolve -c world \
    | grep '^u.*' \
    | while read -r _pkg; do
        echo "$_pkg" | cut -d'u' -f2-
      done
  else
    cave resolve -c world \
    | grep '^u.*' \
    | grep -- "$@"
  fi
}

cave_Qs() {
  cave show -f world | grep -- "$@"
}

cave_Rs() {
  if [[ "$_TOPT" == "" ]]; then
    cave uninstall -r "$@" \
    && echo "Control-C to stop uninstalling..." \
    && sleep 2s \
    && cave uninstall -xr "$@"
  else
    cave purge "$@" \
    && echo "Control-C to stop uninstalling (+ dependencies)..." \
    && sleep 2s \
    && cave purge -x "$@"
  fi
}

cave_Rn() {
  _not_implemented
}

cave_Rns() {
  _not_implemented
}

cave_R() {
  cave uninstall "$@" \
  && echo "Control-C to stop uninstalling..." \
  && sleep 2s \
  && cave uninstall -x "$@"
}

cave_Si() {
  cave show "$@"
}

cave_Suy() {
  cave sync && cave resolve -c "${@:-world}" \
  && echo "Control-C to stop upgrading..." \
  && sleep 2s \
  && cave resolve -cx "${@:-world}"
}

cave_Su() {
  cave resolve -c "$@" \
  && echo "Control-C to stop upgrading..." \
  && sleep 2s \
  && cave resolve -cx "$@"
}

cave_Sy() {
  cave sync "$@"
}

cave_Ss() {
  cave search "$@"
}

cave_Sc() {
  cave fix-cache "$@"
}

cave_Scc() {
  cave fix-cache "$@"
}

cave_Sccc() {
  #rm -fv /var/cache/paludis/*
  _not_implemented
}

cave_S() {
  cave resolve $_TOPT "$@" \
  && echo "Control-C to stop installing..." \
  && sleep 2s \
  && cave resolve -x $_TOPT "$@"
}

cave_U() {
  _not_implemented
}



_conda_init() {
  :
}

conda_Q() {
  if [[ $# -gt 0 ]]; then
    conda list "$(python -c 'import sys; print("^" + "|".join(sys.argv[1:]) + "$")' "$@")"
  else
    conda list
  fi
}

conda_R() {
  conda remove "$@"
}

conda_S() {
  conda install "$@"
}

conda_Sc() {
  conda clean --all "$@"
}

conda_Si() {
  conda search "$@" --info
}

conda_Ss() {
  conda search "*$@*"
}

conda_Suy() {
  conda update --all "$@"
}




_dnf_init() {
  :
}

dnf_S() {
  dnf install $_TOPT "$@"
}

dnf_Sc() {
  dnf clean expire-cache "$@"
}

dnf_Scc() {
  dnf clean packages "$@"
}

dnf_Sccc() {
  dnf clean all "$@"
}

dnf_Si() {
  dnf info "$@"
}

dnf_Sg() {
  if [[ $# -gt 0 ]]; then
    dnf group info "$@"
  else
    dnf group list
  fi
}

dnf_Sl() {
  dnf list available "$@"
}

dnf_Ss() {
  dnf search "$@"
}

dnf_Su() {
  dnf upgrade "$@"
}

dnf_Suy() {
  dnf upgrade "$@"
}

dnf_Sw() {
  dnf download "$@"
}

dnf_Sy() {
  dnf clean expire-cache && dnf check-update
}

dnf_Q() {
  if [[ "$_TOPT" == "q" ]]; then
    rpm -qa --qf "%{NAME}\\n"
  elif [[ "$_TOPT" == "" ]]; then
    rpm -qa --qf "%{NAME} %{VERSION}\\n"
  else
    _not_implemented
  fi
}

dnf_Qc() {
  rpm -q --changelog "$@"
}

dnf_Qe() {
  dnf repoquery --userinstalled "$@"
}

dnf_Qi() {
  dnf info "$@"
}

dnf_Ql() {
  rpm -ql "$@"
}

dnf_Qm() {
  dnf list extras
}

dnf_Qo() {
  rpm -qf "$@"
}

dnf_Qp() {
  rpm -qp "$@"
}

dnf_Qs() {
  rpm -qa "*${*}*"
}

dnf_Qu() {
  dnf list updates "$@"
}

dnf_R() {
  dnf remove "$@"
}

dnf_U() {
  dnf install "$@"
}



_dpkg_init() {
  :
}

dpkg_Q() {
  if [[ "$_TOPT" == "q" ]]; then
    dpkg -l \
    | grep -E '^[hi]i' \
    | awk '{print $2}'
  elif [[ "$_TOPT" == "" ]]; then
    dpkg -l "$@" \
    | grep -E '^[hi]i'
  else
    _not_implemented
  fi
}

dpkg_Qi() {
  dpkg-query -s "$@"
}

dpkg_Ql() {
  if [[ -n "$*" ]]; then
    dpkg-query -L "$@"
    return
  fi

  dpkg -l \
  | grep -E '^[hi]i' \
  | awk '{print $2}' \
  | while read -r _pkg; do
      if [[ "$_TOPT" == "q" ]]; then
        dpkg-query -L "$_pkg"
      else
        dpkg-query -L "$_pkg" \
        | while read -r _line; do
            echo "$_pkg $_line"
          done
      fi
    done
}

dpkg_Qo() {
  dpkg-query -S "$@"
}

dpkg_Qp() {
  dpkg-deb -I "$@"
}

dpkg_Qu() {
  apt-get upgrade --trivial-only "$@"
}

dpkg_Qs() {
  # dpkg >= 1.16.2 dpkg-query -W -f='${db:Status-Abbrev} ${binary:Package}\t${Version}\t${binary:Summary}\n'
  dpkg-query -W -f='${Status} ${Package}\t${Version}\t${Description}\n' \
  | grep -E '^((hold)|(install)|(deinstall))' \
  | sed -r -e 's#^(\w+ ){3}##g' \
  | grep -Ei "${@:-.}"
}

dpkg_Rs() {
  if [[ "$_TOPT" == "" ]]; then
    apt-get autoremove "$@"
  else
    _not_implemented
  fi
}

dpkg_Rn() {
  apt-get purge "$@"
}

dpkg_Rns() {
  apt-get --purge autoremove "$@"
}

dpkg_R() {
  apt-get remove "$@"
}

dpkg_Si() {
  apt-cache show "$@"
}

dpkg_Suy() {
  apt-get update \
  && apt-get upgrade "$@" \
  && apt-get dist-upgrade "$@"
}

dpkg_Su() {
  apt-get upgrade "$@" \
  && apt-get dist-upgrade "$@"
}


dpkg_Sy() {
  apt-get update "$@"
}

dpkg_Ss() {
  apt-cache search "$@"
}

dpkg_Sc() {
  apt-get clean "$@"
}

dpkg_Scc() {
  apt-get autoclean "$@"
}

dpkg_S() {
  apt-get install $_TOPT "$@"
}

dpkg_U() {
  dpkg -i "$@"
}

dpkg_Sii() {
  apt-cache rdepends "$@"
}

dpkg_Sccc() {
  rm -fv /var/cache/apt/*.bin
  rm -fv /var/cache/apt/archives/*.*
  rm -fv /var/lib/apt/lists/*.*
  apt-get autoclean
}



_homebrew_init() {
  :
}

homebrew_Qi() {
  brew info "$@"
}

homebrew_Ql() {
  brew list "$@"
}

homebrew_Qo() {
  local pkg prefix cellar

  # FIXME: What happens if the file is not exectutable?
  cd "$(dirname -- "$(which "$@")")" || return
  pkg="$(pwd -P)/$(basename -- "$@")"
  prefix="$(brew --prefix)"
  cellar="$(brew --cellar)"

  for package in $cellar/*; do
    files=(${package}/*/${pkg/#$prefix\//})
    if [[ -e "${files[${#files[@]} - 1]}" ]]; then
      echo "${package/#$cellar\//}"
      break
    fi
  done
}

homebrew_Qc() {
  brew log "$@"
}

homebrew_Qu() {
  brew outdated | grep "$@"
}

homebrew_Qs() {
  brew list | grep "$@"
}

homebrew_Q() {
  if [[ "$_TOPT" == "" ]]; then
    if [[ "$*" == "" ]]; then
      brew list
    else
      brew list | grep "$@"
    fi
  else
    _not_implemented
  fi
}

homebrew_Rs() {
    which join > /dev/null
    if [ $? -ne 0 ]; then
      _die "pacapt: join binary does not exist in system."
    fi

    which sort > /dev/null
    if [ $? -ne 0 ]; then
      _die "pacapt: sort binary does not exist in system."
    fi

    if [[ "$@" == "" ]]; then
      _die "pacapt: ${FUNCNAME[0]} requires arguments"
    fi

    for _target in $@;
    do
      brew rm $_target

      while [ "$(join <(sort <(brew leaves)) <(sort <(brew deps $_target)))" != "" ]
      do
        brew rm $(join <(sort <(brew leaves)) <(sort <(brew deps $_target)))
      done
    done

}

homebrew_R() {
  brew remove "$@"
}

homebrew_Si() {
  brew info "$@"
}

homebrew_Suy() {
  brew update \
  && brew upgrade "$@"
}

homebrew_Su() {
  brew upgrade "$@"
}

homebrew_Sy() {
  brew update "$@"
}

homebrew_Ss() {
  brew search "$@"
}

homebrew_Sc() {
  brew cleanup "$@"
}

homebrew_Scc() {
  brew cleanup -s "$@"
}

homebrew_Sccc() {
  # See more discussion in
  #   https://github.com/icy/pacapt/issues/47

  local _dcache

  _dcache="$(brew --cache)"
  case "$_dcache" in
  ""|"/"|" ")
    _error "${FUNCNAME[0]}: Unable to delete '$_dcache'."
    ;;

  *)
    # FIXME: This is quite stupid!!! But it's an easy way
    # FIXME: to avoid some warning from #shellcheck.
    # FIXME: Please note that, $_dcache is not empty now.
    rm -rf "${_dcache:-/x/x/x/x/x/x/x/x/x/x/x//x/x/x/x/x/}/"
    ;;
  esac
}

homebrew_S() {
  2>&1 brew install $_TOPT "$@" \
  | awk '{print; if ($0 ~ /brew cask install/) { exit(126); }}'
  ret=( ${PIPESTATUS[*]} )
  if [[ "${ret[1]}" == 126 ]]; then
    echo >&2 ":: Now trying with brew/cask..."
    brew cask install $_TOPT "$@"
  else
    return "${ret[0]}"
  fi
}



_macports_init() {
  :
}

macports_Ql() {
  port contents "$@"
}

macports_Qo() {
  port provides "$@"
}

macports_Qc() {
  port log "$@"
}

macports_Qu() {
  port outdated "$@"
}

macports_Rs() {
  if [[ "$_TOPT" == "" ]]; then
    port uninstall --follow-dependencies "$@"
  else
    _not_implemented
  fi
}

macports_R() {
  port uninstall "$@"
}

macports_Si() {
  port info "$@"
}

macports_Suy() {
  port selfupdate \
  && port upgrade outdated "$@"
}

macports_Su() {
  port upgrade outdate "$@"
}

macports_Sy() {
  port selfupdate "$@"
}

macports_Ss() {
  port search "$@"
}

macports_Sc() {
  port clean --all inactive "$@"
}

macports_Scc() {
  port clean --all installed "$@"
}

macports_S() {
  if [[ "$_TOPT" == "fetch" ]]; then
    port patch "$@"
  else
    port install "$@"
  fi
}



_pkgng_init() {
  :
}

pkgng_Qi() {
  pkg info "$@"
}

pkgng_Ql() {
  pkg info -l "$@"
}

pkgng_Qo() {
  pkg which "$@"
}

pkgng_Qp() {
  pkg query -F "$@" '%n %v'
}

pkgng_Qu() {
  pkg upgrade -n "$@"
}

pkgng_Q() {
  if [[ "$_TOPT" == "q" ]]; then
    pkg query '%n' "$@"
  elif [[ "$_TOPT" == "" ]]; then
    pkg query '%n %v' "$@"
  else
    _not_implemented
  fi
}

pkgng_Rs() {
  if [[ "$_TOPT" == "" ]]; then
    pkg remove "$@"
    pkg autoremove
  else
    _not_implemented
  fi
}

pkgng_R() {
  pkg remove "$@"
}

pkgng_Si() {
  pkg search -S name -ef "$@"
}

pkgng_Suy() {
  pkg upgrade "$@"
}

pkgng_Su() {
  pkg upgrade -U "$@"
}

pkgng_Sy() {
  pkg update "$@"
}

pkgng_Ss() {
  pkg search "$@"
}

pkgng_Sc() {
  pkg clean "$@"
}

pkgng_Scc() {
  pkg clean -a "$@"
}

pkgng_S() {
  if [[ "$_TOPT" == "fetch" ]]; then
    pkg fetch "$@"
  else
    pkg install "$@"
  fi
}



_pkg_tools_init() {
  :
}

pkg_tools_Qi() {
  # disable searching mirrors for packages
  export PKG_PATH=
  pkg_info "$@"
}

pkg_tools_Ql() {
  export PKG_PATH=
  pkg_info -L "$@"
}

pkg_tools_Qo() {
  export PKG_PATH=
  pkg_info -E "$@"
}

pkg_tools_Qp() {
  _not_implemented
}

pkg_tools_Qu() {
  export PKG_PATH=
  pkg_add -u "$@"
}

pkg_tools_Q() {
  export PKG_PATH=
  # the dash after the pkg name is so we don't catch partial matches
  # because all packages in openbsd have the format 'pkgname-pkgver'
  if [[ "$_TOPT" == "q" && ! -z "$*" ]]; then
    pkg_info -q | grep "^${*}-"
  elif [[ "$_TOPT" == "q" && -z "$*" ]];then
    pkg_info -q
  elif [[ "$_TOPT" == "" && ! -z "$*" ]]; then
    pkg_info | grep "^${*}-"
  elif [[ "$_TOPT" == "" && -z "$*" ]];then
    pkg_info
  else
    _not_implemented
  fi
}

pkg_tools_Rs() {
  if [[ "$_TOPT" == "" ]]; then
    pkg_delete -D dependencies "$@"
  else
    _not_implemented
  fi
}

pkg_tools_Rn() {
  if [[ "$_TOPT" == "" ]];then
    pkg_delete -c "$@"
  else
    _not_implemented
  fi
}

pkg_tools_Rns() {
  _not_implemented
}

pkg_tools_R() {
  pkg_delete "$@"
}

pkg_tools_Si() {
  pkg_info "$@"
}

pkg_tools_Sl() {
  pkg_info -L "$@"
}

pkg_tools_Suy() {
  # pkg_tools doesn't really have any concept of a database
  # there's actually not really any database to update, so
  # this function is mostly just for convienience since on arch
  # doing -Su is normally a bad thing to do since it's a partial upgrade

  pkg_tools_Su "$@"
}

pkg_tools_Su() {
  pkg_add -u "$@"
}

pkg_tools_Sy() {
  _not_implemented
}

pkg_tools_Ss() {
  if [[ -z "$*" ]];then
    _not_implemented
  else
    pkg_info -Q "$@"
  fi
}

pkg_tools_Sc() {
  # by default no cache directory is used
  if [[ -z "$PKG_CACHE" ]];then
    echo "You have no cache directory set, set \$PKG_CACHE for a cache directory."
  elif [[ ! -d "$PKG_CACHE" ]];then
    echo "You have a cache directory set, but it does not exist. Create \"$PKG_CACHE\"."
  else
    _removing_is_dangerous "rm -rf $PKG_CACHE/*"
  fi
}

pkg_tools_Scc() {
  _not_implemented
}

pkg_tools_S() {
  pkg_add "$@"
}



_portage_init() {
  :
}

portage_Qi() {
  emerge --info "$@"
}

portage_Ql() {
  if [[ -x '/usr/bin/qlist' ]]; then
    qlist "$@"
  elif [[ -x '/usr/bin/equery' ]]; then
    equery files "$@"
  else
    _error "'portage-utils' or 'gentoolkit' package is required to perform this opreation."
  fi
}

portage_Qo() {
  if [[ -x '/usr/bin/equery' ]]; then
    equery belongs "$@"
  else
    _error "'gentoolkit' package is required to perform this operation."
  fi
}

portage_Qc() {
  emerge -p --changelog "$@"
}

portage_Qu() {
  emerge -uvN "$@"
}

portage_Q() {
  if [[ "$_TOPT" == "" ]]; then
    if [[ -x '/usr/bin/eix' ]]; then
      eix -I "$@"
    elif [[ -x '/usr/bin/equery' ]]; then
      equery list -i "$@"
    else
      LS_COLORS=never \
      ls -1 -d /var/db/pkg/*/*
    fi
  else
    _not_implemented
  fi
}

portage_Rs() {
  if [[ "$_TOPT" == "" ]]; then
    emerge --depclean world "$@"
  else
    _not_implemented
  fi
}

portage_R() {
  emerge --depclean "@"
}

portage_Si() {
  emerge --info "$@"
}

portage_Suy() {
  if [[ -x '/usr/bin/layman' ]]; then
    layman --sync-all \
    && emerge --sync \
    && emerge -auND world "$@"
  else
    emerge --sync \
    && emerge -uND world "$@"
  fi
}

portage_Su() {
  emerge -uND world "$@"
}

portage_Sy() {
  if [[ -x "/usr/bin/layman" ]]; then
    layman --sync-all \
    && emerge --sync "$@"
  else
    emerge --sync "$@"
  fi
}

portage_Ss() {
  if [[ -x "/usr/bin/eix" ]]; then
    eix "$@"
  else
    emerge --search "$@"
  fi
}

portage_Sc() {
  if [[ -x "/usr/bin/eclean-dist" ]]; then
    eclean-dist -d -t1m -s50 -f "$@"
  else
    _error "'gentoolkit' package is required to perform this operation."
  fi
}

portage_Scc() {
  if [[ -x "/usr/bin/eclean" ]]; then
    eclean -i distfiles "$@"
  else
    _error "'gentoolkit' package is required to perform this operation."
  fi
}

portage_Sccc() {
  rm -fv /usr/portage/distfiles/*.*
}

portage_S() {
  emerge "$@"
}



_sun_tools_init() {
  # The purpose of `if` is to make sure this function
  # can be invoked on other system (Linux, BSD).
  if [[ "$(uname)" == "SunOS" ]]; then
    export GREP=/usr/xpg4/bin/grep
    export AWK=nawk
  fi
}

sun_tools_Qi() {
  pkginfo -l "$@"
}

sun_tools_Ql() {
  pkginfo -l "$@"
}

sun_tools_Qo() {
  $GREP "$@" /var/sadm/install/contents
}

sun_tools_Qs() {
  pkginfo | $GREP -i "$@"
}

sun_tools_Q() {
  # the dash after the pkg name is so we don't catch partial matches
  # because all packages in openbsd have the format 'pkgname-pkgver'
  if [[ "$_TOPT" == "q" && ! -z "$*" ]]; then
    pkginfo | $GREP "$@"
  elif [[ "$_TOPT" == "q" && -z "$*" ]]; then
    pkginfo
  else
    pkginfo "$@"
  fi
}

sun_tools_R() {
  pkgrm "$@"
}

sun_tools_U() {
  pkgadd "$@"
}



_swupd_init() {
  :
}

swupd_Qk() {
  swupd verify "$@"
}

swupd_Qo() {
  swupd search "$@"
}

swupd_Qs() {
  swupd search "$@"
}

swupd_R() {
  swupd bundle-remove "$@"
}

swupd_Suy() {
  swupd update
}

swupd_Su() {
  swupd update
}

swupd_Sy() {
  swupd search -i
  swupd update
}

swupd_Ss() {
  swupd search "$@"
}

swupd_S() {
  swupd bundle-add "$@"
}


_tazpkg_init() {
  :
}

tazpkg_Q() {
  if [[ "$_TOPT" == "q" ]]; then
    tazpkg list "$@" \
    | awk '{ if (NF == 2 || NF == 3) { print $1; }}'
  elif [[ "$_TOPT" == "" ]]; then
    tazpkg list "$@"
  else
    _not_implemented
  fi
}

tazpkg_Qi() {
  tazpkg info "$@"
}

tazpkg_Ql() {
  if [[ -z "$*" ]]; then
    _not_implemented
    return
  fi

  if [[ "$_TOPT" == "q" ]]; then
    {
      tazpkg list-files "$@"
      tazpkg list-config "$@"
    } \
    | grep ^/
  else
    tazpkg list-files "$@"
    tazpkg list-config "$@"
  fi
}

tazpkg_Sy() {
  tazpkg recharge
}

tazpkg_Su() {
  tazpkg up
}

tazpkg_Suy() {
  tazpkg_Sy \
  && tazpkg_Su
}

tazpkg_S() {
  local _forced=""

  if grep -q -- "--forced" <<<"$*"; then
    _forced="--forced"
  fi

  while (( $# )); do
    if [[ "$1" == "--forced" ]]; then
      _forced="--forced"
      shift
      continue
    fi

    tazpkg get-install "$1" $_forced
    shift
  done
}

tazpkg_R() {
  local _auto=""

  if grep -q -- "--auto" <<<"$*"; then
    _auto="--auto"
  fi

  while (( $# )); do
    if [[ "$1" == "--auto" ]]; then
      _auto="--auto"
      shift
      continue
    fi

    tazpkg remove "$1" $_auto
    shift
  done
}

tazpkg_Sc() {
  tazpkg clean-cache
}

tazpkg_Scc() {
  tazpkg clean-cache
  cd /var/lib/tazpkg/ \
  && {
    rm -fv \
      ./*.bak \
      ID \
      packages.* \
      files.list.*
  }
}

tazpkg_Ss() {
  tazpkg search "$@"
}

tazpkg_Qo() {
  tazpkg search-pkgname "$@"
}

tazpkg_U() {
  local _forced=""

  if grep -q -- "--forced" <<<"$*"; then
    _forced="--forced"
  fi

  while (( $# )); do
    if [[ "$1" == "--forced" ]]; then
      _forced="--forced"
      shift
      continue
    fi

    tazpkg install "$1" $_forced
    shift
  done
}



_tlmgr_init() {
  :
}

tlmgr_Qi() {
  tlmgr info --only-installed "$@"
}

tlmgr_Qk() {
  tlmgr check files
}

tlmgr_Ql() {
  tlmgr info --only-installed --list "$@"
}

tlmgr_R() {
  tlmgr remove "$@"
}

tlmgr_S() {
  tlmgr install "$@"
}

tlmgr_Si() {
  tlmgr info "$@"
}

tlmgr_Sl() {
  tlmgr info
}

tlmgr_Ss() {
  tlmgr search --global "$@"
}

tlmgr_Suy() {
  tlmgr update --all
}

tlmgr_U() {
  tlmgr install --file "$@"
}



_yum_init() {
  :
}

yum_Q() {
  if [[ "$_TOPT" == "q" ]]; then
    rpm -qa --qf "%{NAME}\\n"
  elif [[ "$_TOPT" == "" ]]; then
    rpm -qa --qf "%{NAME} %{VERSION}\\n"
  else
    _not_implemented
  fi
}

yum_Qi() {
  yum info "$@"
}

yum_Qs() {
  rpm -qa "*${*}*"
}

yum_Ql() {
  rpm -ql "$@"
}

yum_Qo() {
  rpm -qf "$@"
}

yum_Qp() {
  rpm -qp "$@"
}

yum_Qc() {
  rpm -q --changelog "$@"
}

yum_Qu() {
  yum list updates "$@"
}

yum_Qm() {
  yum list extras "$@"
}

yum_Rs() {
  if [[ "$_TOPT" == "" ]]; then
    yum erase "$@"
  else
    _not_implemented
  fi
}

yum_R() {
  yum erase "$@"
}

yum_Si() {
  yum info "$@"
}

yum_Suy() {
  yum update "$@"
}

yum_Su() {
  yum update "$@"
}

yum_Sy() {
  yum check-update "$@"
}

yum_Ss() {
  yum -C search "$@"
}

yum_Sc() {
  yum clean expire-cache "$@"
}

yum_Scc() {
  yum clean packages "$@"
}

yum_Sccc() {
  yum clean all "$@"
}

yum_S() {
  yum install $_TOPT "$@"
}

yum_U() {
  yum localinstall "$@"
}

yum_Sii() {
  yum resolvedep "$@"
}



_zypper_init() {
  :
}

zypper_Qc() {
  rpm -q --changelog "$@"
}

zypper_Qi() {
  zypper info "$@"
}

zypper_Ql() {
  rpm -ql "$@"
}

zypper_Qu() {
  zypper list-updates "$@"
}

zypper_Qm() {
  zypper search -si "$@" \
  | grep 'System Packages'
}

zypper_Qo() {
  rpm -qf "$@"
}

zypper_Qp() {
  rpm -qip "$@"
}

zypper_Qs() {
  zypper search --installed-only "$@"
}

zypper_Q() {
  if [[ "$_TOPT" == "q" ]]; then
    zypper search -i "$@" \
    | grep ^i \
    | awk '{print $3}'
  elif [[ "$_TOPT" == "" ]]; then
    zypper search -i "$@"
  else
    _not_implemented
  fi
}

zypper_Rs() {
  if [[ "$_TOPT" == "s" ]]; then
    zypper remove "$@" --clean-deps
  else
    _not_implemented
  fi
}

zypper_R() {
  zypper remove "$@"
}

zypper_Rn() {
  # Remove configuration files
  while read -r file; do
    if [[ -f "$file" ]]; then
      rm -fv "$file"
    fi
  done < <(rpm -ql "$@")

  # Now remove the package per-se
  zypper remove "$@"
}

zypper_Rs() {
  if [[ "$_TOPT" == "s" ]]; then
    zypper remove "$@" --clean-deps
  else
    _not_implemented
  fi
}

zypper_Rns() {
  # Remove configuration files
  while read -r file; do
    if [[ -f "$file" ]]; then
      rm -fv "$file"
    fi
  done < <(rpm -ql "$@")

  zypper remove "$@" --clean-deps
}

zypper_Suy() {
  zypper dup "$@"
}

zypper_Sy() {
  zypper refresh "$@"
}

zypper_Sl() {
  if [[ $# -eq 0 ]]; then
    zypper pa -R
  else
    zypper pa -r "$@"
  fi
}

zypper_Ss() {
  zypper search "$@"
}

zypper_Su() {
  zypper --no-refresh dup "$@"
}

zypper_Sc() {
  zypper clean "$@"
}

zypper_Scc() {
  zypper clean "$@"
}

zypper_Sccc() {
  # Not way to do this in zypper
  _not_implemented
}

zypper_Si() {
  zypper info --requires "$@"
}

zypper_Sii() {
  # Ugly and slow, but does the trick
  local packages=

  packages="$(zypper pa -R | cut -d \| -f 3 | tr -s '\n' ' ')"
  for package in $packages; do
    zypper info --requires "$package" \
    | grep -q "$@" && echo $package
  done
}

zypper_S() {
  zypper install $_TOPT "$@"
}

zypper_Sw() {
  zypper install --download-only "$@"
}

zypper_U() {
  zypper install "$@"
}
_validate_operation() {
  case "$1" in
  "apk_Q") ;;
  "apk_Qi") ;;
  "apk_Ql") ;;
  "apk_Qo") ;;
  "apk_Qs") ;;
  "apk_Qu") ;;
  "apk_R") ;;
  "apk_Rn") ;;
  "apk_Rns") ;;
  "apk_Rs") ;;
  "apk_S") ;;
  "apk_Sc") ;;
  "apk_Scc") ;;
  "apk_Sccc") ;;
  "apk_Si") ;;
  "apk_Sii") ;;
  "apk_Sl") ;;
  "apk_Ss") ;;
  "apk_Su") ;;
  "apk_Suy") ;;
  "apk_Sy") ;;
  "apk_Sw") ;;
  "apk_U") ;;
  "cave_Q") ;;
  "cave_Qi") ;;
  "cave_Ql") ;;
  "cave_Qo") ;;
  "cave_Qp") ;;
  "cave_Qu") ;;
  "cave_Qs") ;;
  "cave_Rs") ;;
  "cave_Rn") ;;
  "cave_Rns") ;;
  "cave_R") ;;
  "cave_Si") ;;
  "cave_Suy") ;;
  "cave_Su") ;;
  "cave_Sy") ;;
  "cave_Ss") ;;
  "cave_Sc") ;;
  "cave_Scc") ;;
  "cave_Sccc") ;;
  "cave_S") ;;
  "cave_U") ;;
  "conda_Q") ;;
  "conda_R") ;;
  "conda_S") ;;
  "conda_Sc") ;;
  "conda_Si") ;;
  "conda_Ss") ;;
  "conda_Suy") ;;
  "dnf_S") ;;
  "dnf_Sc") ;;
  "dnf_Scc") ;;
  "dnf_Sccc") ;;
  "dnf_Si") ;;
  "dnf_Sg") ;;
  "dnf_Sl") ;;
  "dnf_Ss") ;;
  "dnf_Su") ;;
  "dnf_Suy") ;;
  "dnf_Sw") ;;
  "dnf_Sy") ;;
  "dnf_Q") ;;
  "dnf_Qc") ;;
  "dnf_Qe") ;;
  "dnf_Qi") ;;
  "dnf_Ql") ;;
  "dnf_Qm") ;;
  "dnf_Qo") ;;
  "dnf_Qp") ;;
  "dnf_Qs") ;;
  "dnf_Qu") ;;
  "dnf_R") ;;
  "dnf_U") ;;
  "dpkg_Q") ;;
  "dpkg_Qi") ;;
  "dpkg_Ql") ;;
  "dpkg_Qo") ;;
  "dpkg_Qp") ;;
  "dpkg_Qu") ;;
  "dpkg_Qs") ;;
  "dpkg_Rs") ;;
  "dpkg_Rn") ;;
  "dpkg_Rns") ;;
  "dpkg_R") ;;
  "dpkg_Si") ;;
  "dpkg_Suy") ;;
  "dpkg_Su") ;;
  "dpkg_Sy") ;;
  "dpkg_Ss") ;;
  "dpkg_Sc") ;;
  "dpkg_Scc") ;;
  "dpkg_S") ;;
  "dpkg_U") ;;
  "dpkg_Sii") ;;
  "dpkg_Sccc") ;;
  "homebrew_Qi") ;;
  "homebrew_Ql") ;;
  "homebrew_Qo") ;;
  "homebrew_Qc") ;;
  "homebrew_Qu") ;;
  "homebrew_Qs") ;;
  "homebrew_Q") ;;
  "homebrew_Rs") ;;
  "homebrew_R") ;;
  "homebrew_Si") ;;
  "homebrew_Suy") ;;
  "homebrew_Su") ;;
  "homebrew_Sy") ;;
  "homebrew_Ss") ;;
  "homebrew_Sc") ;;
  "homebrew_Scc") ;;
  "homebrew_Sccc") ;;
  "homebrew_S") ;;
  "macports_Ql") ;;
  "macports_Qo") ;;
  "macports_Qc") ;;
  "macports_Qu") ;;
  "macports_Rs") ;;
  "macports_R") ;;
  "macports_Si") ;;
  "macports_Suy") ;;
  "macports_Su") ;;
  "macports_Sy") ;;
  "macports_Ss") ;;
  "macports_Sc") ;;
  "macports_Scc") ;;
  "macports_S") ;;
  "pkgng_Qi") ;;
  "pkgng_Ql") ;;
  "pkgng_Qo") ;;
  "pkgng_Qp") ;;
  "pkgng_Qu") ;;
  "pkgng_Q") ;;
  "pkgng_Rs") ;;
  "pkgng_R") ;;
  "pkgng_Si") ;;
  "pkgng_Suy") ;;
  "pkgng_Su") ;;
  "pkgng_Sy") ;;
  "pkgng_Ss") ;;
  "pkgng_Sc") ;;
  "pkgng_Scc") ;;
  "pkgng_S") ;;
  "pkg_tools_Qi") ;;
  "pkg_tools_Ql") ;;
  "pkg_tools_Qo") ;;
  "pkg_tools_Qp") ;;
  "pkg_tools_Qu") ;;
  "pkg_tools_Q") ;;
  "pkg_tools_Rs") ;;
  "pkg_tools_Rn") ;;
  "pkg_tools_Rns") ;;
  "pkg_tools_R") ;;
  "pkg_tools_Si") ;;
  "pkg_tools_Sl") ;;
  "pkg_tools_Suy") ;;
  "pkg_tools_Su") ;;
  "pkg_tools_Sy") ;;
  "pkg_tools_Ss") ;;
  "pkg_tools_Sc") ;;
  "pkg_tools_Scc") ;;
  "pkg_tools_S") ;;
  "portage_Qi") ;;
  "portage_Ql") ;;
  "portage_Qo") ;;
  "portage_Qc") ;;
  "portage_Qu") ;;
  "portage_Q") ;;
  "portage_Rs") ;;
  "portage_R") ;;
  "portage_Si") ;;
  "portage_Suy") ;;
  "portage_Su") ;;
  "portage_Sy") ;;
  "portage_Ss") ;;
  "portage_Sc") ;;
  "portage_Scc") ;;
  "portage_Sccc") ;;
  "portage_S") ;;
  "sun_tools_Qi") ;;
  "sun_tools_Ql") ;;
  "sun_tools_Qo") ;;
  "sun_tools_Qs") ;;
  "sun_tools_Q") ;;
  "sun_tools_R") ;;
  "sun_tools_U") ;;
  "swupd_Qk") ;;
  "swupd_Qo") ;;
  "swupd_Qs") ;;
  "swupd_R") ;;
  "swupd_Suy") ;;
  "swupd_Su") ;;
  "swupd_Sy") ;;
  "swupd_Ss") ;;
  "swupd_S") ;;
  "tazpkg_Q") ;;
  "tazpkg_Qi") ;;
  "tazpkg_Ql") ;;
  "tazpkg_Sy") ;;
  "tazpkg_Su") ;;
  "tazpkg_Suy") ;;
  "tazpkg_S") ;;
  "tazpkg_R") ;;
  "tazpkg_Sc") ;;
  "tazpkg_Scc") ;;
  "tazpkg_Ss") ;;
  "tazpkg_Qo") ;;
  "tazpkg_U") ;;
  "tlmgr_Qi") ;;
  "tlmgr_Qk") ;;
  "tlmgr_Ql") ;;
  "tlmgr_R") ;;
  "tlmgr_S") ;;
  "tlmgr_Si") ;;
  "tlmgr_Sl") ;;
  "tlmgr_Ss") ;;
  "tlmgr_Suy") ;;
  "tlmgr_U") ;;
  "yum_Q") ;;
  "yum_Qi") ;;
  "yum_Qs") ;;
  "yum_Ql") ;;
  "yum_Qo") ;;
  "yum_Qp") ;;
  "yum_Qc") ;;
  "yum_Qu") ;;
  "yum_Qm") ;;
  "yum_Rs") ;;
  "yum_R") ;;
  "yum_Si") ;;
  "yum_Suy") ;;
  "yum_Su") ;;
  "yum_Sy") ;;
  "yum_Ss") ;;
  "yum_Sc") ;;
  "yum_Scc") ;;
  "yum_Sccc") ;;
  "yum_S") ;;
  "yum_U") ;;
  "yum_Sii") ;;
  "zypper_Qc") ;;
  "zypper_Qi") ;;
  "zypper_Ql") ;;
  "zypper_Qu") ;;
  "zypper_Qm") ;;
  "zypper_Qo") ;;
  "zypper_Qp") ;;
  "zypper_Qs") ;;
  "zypper_Q") ;;
  "zypper_Rs") ;;
  "zypper_R") ;;
  "zypper_Rn") ;;
  "zypper_Rs") ;;
  "zypper_Rns") ;;
  "zypper_Suy") ;;
  "zypper_Sy") ;;
  "zypper_Sl") ;;
  "zypper_Ss") ;;
  "zypper_Su") ;;
  "zypper_Sc") ;;
  "zypper_Scc") ;;
  "zypper_Sccc") ;;
  "zypper_Si") ;;
  "zypper_Sii") ;;
  "zypper_S") ;;
  "zypper_Sw") ;;
  "zypper_U") ;;
  *) return 1 ;;
  esac
}



set -u
unset GREP_OPTIONS

: "${PACAPT_DEBUG=}"  # Show what will be going
: "${GREP:=grep}"     # Need to update in, e.g, _sun_tools_init
: "${AWK:=awk}"       # Need to update in, e.g, _sun_tools_init

_sun_tools_init       # Dirty tricky patch for SunOS

export PACAPT_DEBUG GREP AWK

_POPT=""    # primary operation
_SOPT=""    # secondary operation
_TOPT=""    # options for operations
_EOPT=""    # extra options (directly given to package manager)
            # these options will be translated by (_translate_all) method.
_PACMAN=""  # name of the package manager

_PACMAN_detect \
|| _die "'pacapt' doesn't support your package manager."

if [[ -z "$PACAPT_DEBUG" ]]; then
  [[ "$_PACMAN" != "pacman" ]] \
  || exec "/usr/bin/pacman" "$@"
elif [[ "$PACAPT_DEBUG" != "auto" ]]; then
  _PACMAN="$PACAPT_DEBUG"
fi

case "${1:-}" in
"update")     shift; set -- -Sy   "$@" ;;
"upgrade")    shift; set -- -Su   "$@" ;;
"install")    shift; set -- -S    "$@" ;;
"search")     shift; set -- -Ss   "$@" ;;
"remove")     shift; set -- -R    "$@" ;;
"autoremove") shift; set -- -Rs   "$@" ;;
"clean")      shift; set -- -Scc  "$@" ;;
esac

while :; do
  _args="${1-}"

  [[ "${_args:0:1}" == "-" ]] || break

  case "${_args}" in
  "--help")
    _help
    exit 0
    ;;

  "--noconfirm")
    shift
    _EOPT="$_EOPT:noconfirm:"
    continue
    ;;

  "-"|"--")
    shift
    break
    ;;
  esac

  i=1
  while [[ "$i" -lt "${#_args}" ]]; do
    _opt="${_args:$i:1}"
    (( i ++ ))

    case "$_opt" in
    h)
      _help
      exit 0
      ;;
    V)
      _print_pacapt_version;
      exit 0
      ;;
    P)
      _print_supported_operations "$_PACMAN"
      exit 0
      ;;

    Q|S|R|U)
      if [[ -n "$_POPT" && "$_POPT" != "$_opt" ]]; then
        _error "Only one operation may be used at a time"
        exit 1
      fi
      _POPT="$_opt"
      ;;

    # Comment 2015 May 26th: This part deals with the 2nd option.
    # Most of the time, there is only one 2nd option. But some
    # operation may need extra and/or duplicate (e.g, Sy <> Syy).
    #
    # See also
    #
    # * https://github.com/icy/pacapt/issues/13
    #
    #   This implementation works, but with a bug. #Rsn works
    #   but #Rns is translated to #Rn (incorrectly.)
    #   Thanks Huy-Ngo for this nice catch.
    #
    # FIXME: Please check pacman(8) to see if they are really 2nd operation
    #
    e|g|i|l|m|n|o|p|s)
      if [[ "$_SOPT" == '' ]]; then
        _SOPT="$_opt"
        continue
      fi

      # Understand it:
      # If there is already an option recorded, the incoming option
      # will come and compare itself with known one.
      # We have a table
      #
      #     known one vs. incoming ? | result
      #                <             | one-new
      #                =             | one-one
      #                >             | new-one
      #
      # Let's say, after this step, the 3rd option comes (named X),
      # and the current result is "a-b". We have a table
      #
      #    a(b) vs. X  | result
      #         <      | aX (b dropped)
      #         =      | aa (b dropped)
      #         >      | Xa (b dropped)
      #
      # In any case, the first one matters.
      #
      if [[ "${_SOPT:0:1}" < "$_opt" ]]; then
        _SOPT="${_SOPT:0:1}$_opt"
      elif [[ "${_SOPT:0:1}" == "$_opt" ]]; then
        _SOPT="$_opt$_opt"
      else
        _SOPT="$_opt${_SOPT:0:1}"
      fi

      ;;

    q)
      _TOPT="$_opt" ;; # Thanks to James Pearson

    u)
      if [[ "${_SOPT:0:1}" == "y" ]]; then
        _SOPT="uy"
      else
        _SOPT="u"
      fi
      ;;

    y)
      if [[ "${_SOPT:0:1}" == "u" ]]; then
        _SOPT="uy"
      else
        _SOPT="y"
      fi
      ;;

    c)
      if [[ "${_SOPT:0:2}" == "cc" ]]; then
        _SOPT="ccc"
      elif [[ "${_SOPT:0:1}" == "c" ]]; then
        _SOPT="cc"
      else
        _SOPT="$_opt"
      fi
      ;;

    w|v)
      _EOPT="$_EOPT:$_opt:"
      ;;

    *)
      # FIXME: If option is unknown, we will break the loop
      # FIXME: and this option will be used by the native program.
      # FIXME: break 2
      _die "pacapt: Unknown option '$_opt'."
      ;;
    esac
  done

  shift

  # If the primary option and the secondary are known
  # we would break the argument detection, but for sure we will look
  # forward to see there is anything interesting...
  if [[ -n "$_POPT" && -n "$_SOPT" ]]; then
    case "${1:-}" in
    "-w"|"--noconfirm") ;;
    *) break;;
    esac

  # Don't have anything from the **first** argument. Something wrong.
  # FIXME: This means that user must enter at least primary action
  # FIXME: or secondary action in the very first part...
  elif [[ -z "${_POPT}${_SOPT}${_TOPT}" ]]; then
    break
  fi
done

[[ -n "$_POPT" ]] \
|| _die "Usage: pacapt <options>   # -h for help, -P list supported functions"

_validate_operation "${_PACMAN}_${_POPT}${_SOPT}" \
|| {
  _not_implemented
  exit 1
}

_translate_all || exit

if [[ -n "$*" ]]; then
  case "${_POPT}${_SOPT}" in
  "Su"|"Sy"|"Suy")
    echo 1>&2 "WARNING ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
    echo 1>&2 "  The -Sy/u options refresh and/or upgrade all packages."
    echo 1>&2 "  To install packages as well, use separate commands:"
    echo 1>&2
    echo 1>&2 "    $0 -S$_SOPT; $0 -S ${*}"
    echo 1>&2 "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  esac
fi

if [[ -n "$PACAPT_DEBUG" ]]; then
  echo "pacapt: $_PACMAN, p=$_POPT, s=$_SOPT, t=$_TOPT, e=$_EOPT"
  echo "pacapt: execute '${_PACMAN}_${_POPT}${_SOPT} $_EOPT ${*}'"
  declare -f "${_PACMAN}_${_POPT}${_SOPT}"
else
  "_${_PACMAN}_init" || exit
  "${_PACMAN}_${_POPT}${_SOPT}" $_EOPT "$@"
fi