if [ -z $1 ]
then
    export PY_VERSION=3.8
else
    export PY_VERSION=$1
fi

docker run -it --rm -v $PWD:/app lambci/lambda:build-python$PY_VERSION \
    /bin/bash /app/setup_awslambda_umfpack_layer.sh $PY_VERSION
