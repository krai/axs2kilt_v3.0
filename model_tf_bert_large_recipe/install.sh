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

echo "Downloading to ${INSTALL_DIR} ..."

wget https://zenodo.org/record/3733868/files/model.ckpt-5474.data-00000-of-00001 -P ${INSTALL_DIR}
wget https://zenodo.org/record/3733868/files/model.ckpt-5474.index -P ${INSTALL_DIR}
wget https://zenodo.org/record/3733868/files/model.ckpt-5474.meta -P ${INSTALL_DIR}
wget https://zenodo.org/record/3733868/files/vocab.txt -P ${INSTALL_DIR}
wget https://raw.githubusercontent.com/mlcommons/inference/master/language/bert/bert_config.json -P ${INSTALL_DIR}

echo "Download completed."