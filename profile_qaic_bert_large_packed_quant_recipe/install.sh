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

# remove the old installation if it exists.

rm -rf *

echo "Profiling ..."

mkdir -p packed

# wget the third party packing algorithm

wget https://raw.githubusercontent.com/graphcore/tutorials/master/blogs_code/packedBERT/spfhp.py -P ${INSTALL_DIR}/

# pack the dataset

PYTHONPATH=$PYTHONPATH:${CK_ENV_MLPERF_INFERENCE}/language/bert/:${INSTALL_DIR}/ \
${CK_ENV_COMPILER_PYTHON_FILE} ${ORIGINAL_PACKAGE_DIR}/pack.py ${CK_ENV_DATASET_SQUAD_TOKENIZED} ${INSTALL_DIR}/packed \
                               ${_PACKED_SEQ_LEN}

# create a list of the input files

cd packed
for dir in */; do
    echo "./$dir/input_ids.raw,./$dir/input_mask.raw,./$dir/segment_ids.raw,./$dir/input_position_ids.raw" >> inputfiles.txt
done

# quantize the model

${QAIC_TOOLCHAIN_PATH}/exec/qaic-exec -m=${CK_ENV_ONNX_MODEL_ROOT}/model.onnx \
-onnx-define-symbol=batch_size,1 -onnx-define-symbol=seg_length,${_PACKED_SEQ_LEN} \
-input-list-file=${INSTALL_DIR}/packed/inputfiles.txt -num-histogram-bins=512 -dump-profile=${INSTALL_DIR}/profile.yaml -profiling-threads=4