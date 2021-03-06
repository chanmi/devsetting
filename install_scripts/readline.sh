#!/usr/bin/env bash
#
#    readline installer
#
#    Copyright (C) 2017 Gwangmin Lee
#    
#    Author: Gwangmin Lee <gwangmin0123@gmail.com>
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation, either version 3 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.

set -e

FILENAME=`basename ${BASH_SOURCE[0]}`
FILENAME=${FILENAME%%.*}
DONENAME="DONE$FILENAME"
if [ ! -z ${!DONENAME+x} ];then
  return 0
fi
let DONE$FILENAME=1

ROOT=$(cd $(dirname ${BASH_SOURCE[0]})/.. && pwd)
PWD=$(pwd)
. $ROOT/envset.sh

. $ROOT/install_scripts/ncurses.sh

PKG_NAME="readline"
REPO_URL="https://git.savannah.gnu.org/git/readline.git"
DOWN_URL="http://git.savannah.gnu.org/cgit/readline.git/snapshot"
TAG=$(git ls-remote -t $REPO_URL | grep -v -e '{}\|alpha\|beta\|rc' | cut -d/ -f3 | sort -V | tail -n1)
CUSTOMTAGNAME="${PKG_NAME}TAG"
TAG=${!CUSTOMTAGNAME:-$TAG}
VER=$(echo $TAG | sed 's/readline-//')
FOLDER="$PKG_NAME*"
VERFILE="${LOCAL_DIR}/include/readline/readline.h"
INSTALLED_VERSION=$(cat $VERFILE | grep 'define RL_READLINE_VERSION' | cut -d' ' -f4)

if ([ ! -z $REINSTALL ] && [ $LEVEL -le $REINSTALL ]) || [ -z $INSTALLED_VERSION ] || $(compare_version $INSTALLED_VERSION $VER); then
  iecho "$PKG_NAME $VER installation.. install location: $LOCAL_DIR"

  mkdir -p $TMP_DIR && cd $TMP_DIR
  curl -L $DOWN_URL/$TAG.tar.gz | tar xz
  cd $FOLDER
  ./configure --prefix=${LOCAL_DIR} \
    --enable-multibyte \
    --enable-shared \
    --enable-static \
    --with-curses
  # Fix undefined symbol UP issue
  # https://stackoverflow.com/questions/46881581/libreadline-so-7-undefined-symbol-up
  LIBTINFO=$(find / -name 'libtinfo.so*' 2>/dev/null | head -n1)
  if [ -z $LIBTINFO ];then
    eecho "Cannot find libtinfo!"
    exit 1
  fi
  for mfile in $(find "$PWD" -name 'Makefile'); do
    sed -i "s|SHLIB_LIBS =|SHLIB_LIBS = $LIBTINFO|g" "$mfile"
  done
  make -s -j${NPROC}
  make -s install 1>/dev/null

  cd $ROOT && rm -rf $TMP_DIR
else
  gecho "$PKG_NAME $VER is already installed"
fi

LEVEL=$(( ${LEVEL}-1 ))
cd $ROOT
