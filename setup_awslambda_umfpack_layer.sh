#!/bin/bash

install_software() {
    yum install -y \
        atlas-3.8.4 \
        blas-3.5.0 \
        suitesparse-3.6.1 \
        wget \
        zip

    # scikit-umfpack looks for this symbolic link
    ln -s $LIB64/libumfpack.so.5 $LIB64/libumfpack.so
}


get_suitesparse_header_files_from_source() {
    # scikit-umfpack needs these header files from SuiteSparse, but they are not copied
    # during the SuiteSparse installation; we need to get them from source
    pushd /tmp
        wget https://github.com/DrTimothyAldenDavis/SuiteSparse/archive/v5.6.0.tar.gz
        tar -xf v5.6.0.tar.gz
        cp -r SuiteSparse-5.6.0/UMFPACK/Include/. /usr/include/.
        cp SuiteSparse-5.6.0/SuiteSparse_config/SuiteSparse_config.h /usr/include/.
        cp SuiteSparse-5.6.0/AMD/Include/amd.h /usr/include/.
    popd
}


setup_virtual_environment() {
    python -m venv $VENV --copies
    source $VENV/bin/activate
    pip install pip --upgrade
    pip install numpy==1.18.1 scipy==1.4.1 scikit-umfpack==0.3.2
}


create_layer() {
    # Copy the packages into the python directory of the layer
    mkdir $LAYER_PYTHON -p
    cp -r $VENV/lib/python$PY_VERSION/site-packages/numpy* $LAYER_PYTHON
    cp -r $VENV/lib/python$PY_VERSION/site-packages/scipy* $LAYER_PYTHON
    cp -r $VENV/lib/python$PY_VERSION/site-packages/scikit* $LAYER_PYTHON

    # Decrease the layer size by erasing tests
    find $LAYER_PYTHON -name "tests*" | xargs rm -rf

    # Copy necessary shared libraries into the lib directory of the layer
    mkdir $LAYER_LIB -p
    cp $ATLAS/libatlas.so.3 $LAYER_LIB
    cp $ATLAS/libcblas.so.3 $LAYER_LIB
    cp $ATLAS/libf77blas.so.3 $LAYER_LIB
    cp $ATLAS/liblapack.so.3 $LAYER_LIB
    cp $LIB64/libamd.so.2 $LAYER_LIB
    cp $LIB64/libblas.so.3 $LAYER_LIB
    cp $LIB64/libcamd.so.2 $LAYER_LIB
    cp $LIB64/libccolamd.so.2 $LAYER_LIB
    cp $LIB64/libcholmod.so.1 $LAYER_LIB
    cp $LIB64/libcolamd.so.2 $LAYER_LIB
    cp $LIB64/libgfortran.so.3 $LAYER_LIB
    cp $LIB64/libquadmath.so.0 $LAYER_LIB
    cp $LIB64/libumfpack.so.5 $LAYER_LIB

    # Zip together the layer files
    pushd $LAYER
        zip -r9 /app/numpy_scipy_umfpack_python$PY_VERSION.zip python lib
    popd

}


main () {
    export LIB64=/usr/lib64
    export VENV=/lambda
    export LAYER=/tmp/layer
    export LAYER_PYTHON=$LAYER/python
    export LAYER_LIB=$LAYER/lib
    export ATLAS=$LIB64/atlas
    export PY_VERSION=$1

    install_software

    get_suitesparse_header_files_from_source

    setup_virtual_environment

    create_layer

}

main $1
