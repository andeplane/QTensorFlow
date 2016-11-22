# Tensorflow C++ API example

The repository provides a basic image classification example using Tensorflow shared library (.so).
This script automatically set up and build an environment for Tensorflow C++ API.
Tested on Ubuntu 14.04 and 16.04.

## Setup

clone this repo recursively.

```
git clone --recursive https://github.com/andeplane/QTensorFlow.git
```

then install dependent packages via apt-get.

```bash
./dependencies.sh
```

Now ready to run the script to build bazel (cmake-like tool from Google) and tensorflow.

```bash
./setup.sh
```

The build sometimes fails due to a download issue while fetching tensorflow internal dependencies.
Running the script again will simply solve this problem.

After build, generated header files are copied to include directories in a certain structure required by tensorflow.
Since the file copy is done quick and dirty without full understanding of the header structure,
this part is subject to break upon any update in tensorflow.

## Example

The image recognition demo is taken from
[tensorflow repo](https://github.com/tensorflow/tensorflow/tree/master/tensorflow/examples/label_image)
and used for an example.
Include `libtensorflow.so` in your library path and compile/run the app.

```bash
make
LD_LIBRARY_PATH=$LD_LIBRARY_PATH:./lib64 && ./app
```
