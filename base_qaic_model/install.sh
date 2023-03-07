#!/bin/bash

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
    if [ "${?}" != "0" ]; then exit 1; fi
}

aic_binary_dir=./elfs

mkdir -p ${INSTALL_DIR}/install
mkdir -p ${INSTALL_DIR}/elfs
echo "${INSTALL_DIR}/elfs"

if [ -e ${aic_binary_dir}/constants.bin ]; then
    # qaic-exec can't dump the constants binary if it already exists
    rm -f ${aic_binary_dir}/constants.bin
fi

rm -rf ${aic_binary_dir}

# Quantization profile.
profile=${CK_ENV_COMPILER_GLOW_PROFILE_YAML}
echo "Profile: '${profile}'"

# Model: assume either ONNX or TF.
model=${ONNX_MODEL_SOURCE}
# Source model.
echo "Model: '${model}'"

# _COMPILER_PARAMS_SCENARIO_BASE=_COMPILER_PARAMS_${_COMPILER_PARAMS_SCENARIO_NAME}_BASE
# _COMPILER_ARGS_SCENARIO=${_COMPILER_ARGS_NAME_PREFIX}"_COMPILER_ARGS_"${_COMPILER_PARAMS_SCENARIO_NAME}
_COMPILER_PARAMS_SCENARIO_BASE=${_COMPILER_PARAMS_BASE}" "${_COMPILER_PARAMS_SCENARIO_SPECIFIC}
_COMPILER_PARAMS=${_COMPILER_PARAMS_SCENARIO_BASE}" "${_COMPILER_ARGS_SCENARIO}" "${_COMPILER_PARAMS_SUT}" "${_COMPILER_PARAMS}

if [[ -n ${_EXTERNAL_QUANTIZATION} ]]; then
  echo ${CK_ENV_COMPILER_GLOW_PROFILE_DIR}
  _COMPILER_PARAMS=${_COMPILER_PARAMS/"[EXTERNAL_QUANTIZATION_FILE]"/$profile}
  LOAD_PROFILE=""
elif [[ -n ${_NO_QUANTIZATION} ]]; then
  LOAD_PROFILE=""
else
  LOAD_PROFILE="-load-profile=${profile}"
fi

if [[ -n ${_ENABLE_CHANNEL_WISE} ]]; then
  _COMPILER_PARAMS=${_COMPILER_PARAMS}" -enable-channelwise"
fi

if [[ -n ${CK_ENV_COMPILER_GLOW_PROFILE_DIR} ]]; then
  node_precision="${CK_ENV_COMPILER_GLOW_PROFILE_DIR}/node-precision.yaml"
  _COMPILER_PARAMS=${_COMPILER_PARAMS/"[NODE_PRECISION_FILE]"/$node_precision}
fi

if [[ -n ${_SEG} ]]; then
  _COMPILER_PARAMS=${_COMPILER_PARAMS/"[SEG]"/$_SEG}
fi

if [[ -n ${_BATCH_SIZE_EXPLICIT} ]]; then
  _BATCH_SIZE=${_BATCH_SIZE:-1}
  _COMPILER_PARAMS=${_COMPILER_PARAMS/"[BATCH_SIZE]"/${_BATCH_SIZE}}
else
  if [[ ${_BATCH_SIZE} > 0 ]]; then
    _COMPILER_PARAMS=${_COMPILER_PARAMS}" -batchsize=$_BATCH_SIZE"
  fi
fi

if [[ -n ${_PERCENTILE_CALIBRATION_VALUE} ]]; then
  _QUANTIZATION_PARAMS=${_QUANTIZATION_PARAMS/"[PERCENTILE_CALIBRATION_VALUE]"/$_PERCENTILE_CALIBRATION_VALUE}
fi

_COMPILER_PARAMS="${_COMPILER_PARAMS} ${_QUANTIZATION_PARAMS} ${_EXTRA_COMPILER_PARAMS}"

if [[ -n ${_COMPILER_PARAMS} ]]; then
  echo "Compiler Params: ${_COMPILER_PARAMS}"
  # Compile only.
  echo
  echo "Compile QAIC network binaries:"
  read -d '' CMD <<END_OF_CMD
  ${QAIC_TOOLCHAIN_PATH}/exec/qaic-exec -model=${model} \
  ${LOAD_PROFILE} -aic-binary-dir=${aic_binary_dir} \
  ${_COMPILER_PARAMS}
END_OF_CMD
  echo ${CMD}
  eval ${CMD}
  exit_if_error
  export COMPILER_PARAMS=${_COMPILER_PARAMS}
  echo "Done."
  exit
fi
exit -1