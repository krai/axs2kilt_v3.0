#! /bin/bash

#
# MIT License
#
# Copyright (c) 2021-2023 Krai Ltd
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.
#

function exit_if_error() {
  if [ "${?}" != "0" ]; then
    echo ""
    echo "ERROR: $1"
    exit 1
  fi
}

############################################################
echo ""
echo "Downloading Protobuf source to ${INSTALL_DIR}/src ..."

rm -rf ${INSTALL_DIR}/src
rm -rf ${INSTALL_DIR}/install

mkdir -p ${INSTALL_DIR}/src
git clone -b v3.11.4 https://github.com/protocolbuffers/protobuf.git ${INSTALL_DIR}/src

cd ${INSTALL_DIR}/src
git submodule update --init --recursive

############################################################
echo ""
echo "Configuring CMake ..."

mkdir -p ${INSTALL_DIR}/obj
cd ${INSTALL_DIR}/obj

mkdir -p ${INSTALL_DIR}/install
_CONFIGURE_FLAGS="-DCMAKE_CXX_STANDARD=14 -Dprotobuf_BUILD_TESTS=OFF -DCMAKE_INSTALL_PREFIX=${INSTALL_DIR}/install -DCMAKE_C_COMPILER=/usr/bin/gcc -DCMAKE_CXX_COMPILER=/usr/bin/g++ -DCMAKE_AR=/usr/bin/ar "
if [[ ! -z "${FOR_QAIC}" ]]; then
  _CONFIGURE_FLAGS="${_CONFIGURE_FLAGS}:-DBUILD_SHARED_LIBS=ON"
else
  _CONFIGURE_FLAGS="${_CONFIGURE_FLAGS}:-DBUILD_SHARED_LIBS=OFF"
fi
_CMAKE_CMD="cmake ${_CONFIGURE_FLAGS} -B . -S ../src/cmake"
echo "${_CMAKE_CMD}"

${_CMAKE_CMD}

exit_if_error "Failed to configure CMake!"

############################################################
_NUM_OF_PROCESSOR="$(nproc)" # TODO: add option to override
echo ""
echo "Building package with make using ${_NUM_OF_PROCESSOR} threads ..."
make -j ${_NUM_OF_PROCESSOR}

exit_if_error "Failed to build package!"

############################################################
echo ""
echo "Installing package ..."

rm -rf install
make install

exit_if_error "Failed to install package!"

############################################################
echo ""
echo "Cleaning obj directory ..."

cd ${INSTALL_DIR}
rm -rf obj