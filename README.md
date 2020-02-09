# AWS Lambda layer for running Scipy with UMFPACK

UMFPACK, a part of [SuiteSparse](http://faculty.cse.tamu.edu/davis/suitesparse.html), is a fast direct solver for sparse linear equation systems. The Python package [scikit-umfpack](https://pypi.org/project/scikit-umfpack/) wraps the solver and makes it available for Scipy to use. Although getting the setup to work locally is relatively straightforward, things become much more tricky on AWS Lambda. This repo builds the necessary AWS Lambda layer that overcomes the challenge.

## Requirements

Docker

## How to build the AWS Lambda layers?

Clone the repo, make sure you are in its directory, then run the build script with an optional command line argument that specifies the version of the Python runtime you want to use on AWS Lambda. For example:
...
./build.sh 3.7
...
If you omit the version number, the build script defaults to Python 3.8. The zipped AWS Lambda layer (e.g. "numpy_scipy_umfpack_python3.7.zip") will appear in the project directory once the build script is finished. The docker container will be removed after use, but not the docker image.

## Remarks

I've tested the script under Python 3.7 and 3.8. It also works under 3.6 (and quite possibly other Python 3 versions as well), but the zip file it creates is larger than 50 MB, thus not fit for AWS Lambda. If you need to use Python 3.6, modify the script to create two smaller zip files (e.g. one with numpy only and another one with scipy and scikit-umfpack). Under Python 3.7 and 3.8, this problem does not arise.

At the time of writing, AWS Lambda does provide a numpy+scipy layer, but I could not get it to work with a separately-built scikit-umfpack. It seems that including everything here is the only way to go.

## Acknowledgements

This setup script has been inspired by the prior work of [Ryan S. Brown](https://github.com/ryansb/sklearn-build-lambda) and [Vivant Shen](https://github.com/talkwei/lambda-pkg-build). Thanks a lot to Tim Davis for UMFPACK and to the scikit-umfpack project for making UMFPACK available under Python.
