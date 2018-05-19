#!/usr/bin/env bash

repo=caffe-ubuntu14.04-cuda8.0-cudnn5.0
tag=$(date +'%Y%m%d')
full=$repo:$tag

echo "building $full"
nvidia-docker build -t $full .
echo "build $full completed"

echo "done."






