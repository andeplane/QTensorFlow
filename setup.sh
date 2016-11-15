#!/usr/bin/env bash

wget_and_check() {
  local file_name=$1
  local file_url=$2
  local file_md5=$3

  if [ ! -f $file_name ]; then
    mkdir -p $(dirname $file_name)
    wget -O $file_name $file_url --no-check-certificate
  fi

  if [ "$(md5sum $file_name | awk '{print $1}')" != "$file_md5" ]; then
    rm -f $file_name
    echo "==> File corrupted. Attempt to download it again.."
    wget_and_check $file_name $file_url $file_md5;
  fi
}


# set paths for download
PATH_HOME="$(pwd)"
PATH_TF="$PATH_HOME/tensorflow"

git submodule update --init --recursive

# build tensorflow if not exist
if [ ! -f "$PATH_HOME/lib64/libtensorflow.so" ]; then

  # set env variables for tensorflow
  export PYTHON_BIN_PATH=$(which python)
  export TF_NEED_GCP="0"
  export TF_NEED_CUDA="0"
  export GCC_HOST_COMPILER_PATH=$(which gcc)
  
  if ! hash bazel 2>/dev/null; then
    echo "==> Could not find bazel, aborting. Please install it or make sure it is in your PATH."
    exit
  fi

  cd $PATH_TF
  # build tensorflow
  ./configure
  bazel build -c opt //tensorflow:libtensorflow_cc.so
  if [ $? -ne 0 ]; then
    cd $PATH_HOME
    echo "==> Failed to build Tensorflow. You may try again"
    exit
  fi

  # copy library and headers. better solution is needed
  # (sync does not work well with symlinked structure)
  mkdir -p $PATH_HOME/lib64 $PATH_HOME/include
  cp bazel-bin/tensorflow/libtensorflow_cc.so $PATH_HOME/lib64/libtensorflow.so

  # copy headers for tensorflow
  rsync -am --include='*.h' -f 'hide,! */' bazel-tensorflow/tensorflow/ $PATH_HOME/include/tensorflow
  rsync -am --include='*.h' -f 'hide,! */' bazel-genfiles/tensorflow/ $PATH_HOME/include/tensorflow

  # copy headers for protobuf
  rsync -am --include='*.h' -f 'hide,! */' bazel-tensorflow/external/protobuf/src/ $PATH_HOME/include

  # copy headers for eigen3 (this library header stucture is weird)
  mkdir -p $PATH_HOME/include/third_party/eigen3/unsupported/Eigen
  cp -rf bazel-tensorflow/external/eigen_archive/unsupported/Eigen/* $PATH_HOME/include/third_party/eigen3/unsupported/Eigen
  mkdir -p $PATH_HOME/include/third_party/eigen3/Eigen
  cp -rf bazel-tensorflow/external/eigen_archive/Eigen/* $PATH_HOME/include/third_party/eigen3/Eigen
  cp -rn bazel-tensorflow/third_party/eigen3/unsupported/Eigen/* $PATH_HOME/include/third_party/eigen3/unsupported/Eigen
  ln -sf $PATH_HOME/include/third_party/eigen3/Eigen $PATH_HOME/include/Eigen
  cd $PATH_HOME
fi
