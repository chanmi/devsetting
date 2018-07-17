#!/usr/bin/env bash
#
#    Cleanup script for docker image
#
#    Copyright (C) 2018 Gwangmin Lee
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

ROOT=$(cd $(dirname ${BASH_SOURCE[0]}) && pwd)
PWD=$(pwd)
. $ROOT/envset.sh

if [ $OS == 'ubuntu' ];then
  ${SUDO} apt clean
  ${SUDO} rm -rf /var/lib/apt/lists
elif [ $OS == 'centos' ];then
  ${SUDO} yum clean all
  ${SUDO} rm -rf /var/cache/yum
fi

LEVEL=$(( ${LEVEL}-1 ))
