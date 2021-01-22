#!/bin/bash

if [ -z "${DL4PropertyPredHome}" ]; then
        echo "ERROR: please set environmental variable DL4PropertyPredHome to the install folder of DL4PropertyPrediction"
        exit 1
fi

DeepModelFile=$DL4PropertyPredHome/params/ModelFile4PropertyPred.txt
ModelName=PhiPsiSet10820Models
GPU=-1
ResultDir=`pwd`

function Usage {
	echo $0 "[ -f DeepModelFile | -m ModelName | -d ResultDir | -g gpu ] inputFeature_PKL"
	echo "	This script predicts structure properties from a feature file in PKL format using a local GPU"
	echo "	inputFeature: the input feature file in PKL format generated by CollectPropertyFeatures.sh or GenPropertyFeaturesFromMultiHHMs.py"
	echo "	-f: a file containing some deep learning model files, default $DeepModelFile"
        echo "	-m: a model name defined in DeepModelFile representing a set of deep learning models, default $ModelName"
	echo "	-d: the folder for result saving, default current work directory"
	echo "	-g: -1 (default), 0-3. If -1, automatically select a GPU"
}


while getopts ":f:m:d:g:" opt; do
        case ${opt} in
                f )
                  DeepModelFile=$OPTARG
                  ;;
                m )
                  ModelName=$OPTARG
                  ;;
                d )
                  ResultDir=$OPTARG
                  ;;
                g )
                  GPU=$OPTARG
                  ;;
                \? )
                  echo "Invalid Option: -$OPTARG" 1>&2
                  exit 1
                  ;;
                : )
                  echo "Invalid Option: -$OPTARG requires an argument" 1>&2
                  exit 1
                  ;;
        esac
done
shift $((OPTIND -1))

if [ $# -ne 1 ]; then
        Usage
        exit 1
fi

if [ ! -f $DeepModelFile ]; then
        echo "ERROR: invalid deep learning model file: $DeepModelFile"
        exit 1
fi

inputFeature=$1
if [ ! -f $inputFeature ]; then
        echo "ERROR: invalid input feature file for property prediction: $inputFeature "
        exit 1
fi

program=$DL4PropertyPredHome/RunPropertyPredictor.py
if [ ! -f $program ]; then
        echo "ERROR: the main program does not exist: $program"
        exit 1
fi

. $DeepModelFile

ModelFiles=`eval echo '$'${ModelName}`
#echo ModelFiles=$ModelFiles
if [ $ModelFiles == "" ]; then
        echo "ERROR: ModelFiles for $ModelName is empty!"
        exit 1
fi

if [ ! -d $ResultDir ]; then
	mkdir -p $ResultDir
fi

if [ -z "${CUDA_ROOT}" ]; then
        echo "ERROR: please set environmental variable CUDA_ROOT"
        exit 1
fi
if [ $GPU == "-1" ]; then
	## here we assume 1G is sufficient for property prediction
	neededRAM=1073741824
	GPU=`$ModelingHome/Utils/FindOneGPUByMemory.sh $neededRAM 10`
fi

if [ $GPU == "-1" ]; then
        echo "WARNING: cannot find an appropriate GPU to run property prediction from $inputFeature !"
        GPU=cpu
else
        GPU=cuda$GPU
fi

THEANO_FLAGS=blas.ldflags=,device=$GPU,floatX=float32,dnn.include_path=${CUDA_ROOT}/include,dnn.library_path=${CUDA_ROOT}/lib64 python $program -p $inputFeature -m $ModelFiles -d $ResultDir 
if [ $? -ne 0 ]; then
	echo "ERROR: Failed to predict property for $inputFeature!"
	exit 1
fi