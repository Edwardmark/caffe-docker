FROM nvidia/cuda:8.0-cudnn5-devel-ubuntu14.04
MAINTAINER dongbin1@corp.netease.com

ENV DEBIAN_FRONTEND noninteractive 
RUN apt-get update && apt-get install -y --no-install-recommends \
	libprotobuf-dev \
	libleveldb-dev \
	libsnappy-dev \
	libopencv-dev \
	libhdf5-serial-dev \
	protobuf-compiler \
	libboost-all-dev \
	libopenblas-dev \
	python-dev \
	libgflags-dev \
	libgoogle-glog-dev \
	liblmdb-dev \
	vim \
	python-pip \
	python-dev \
	build-essential \
	git \
	libatlas-base-dev \
	wget \
	nvidia-modprobe \
	zip \
	libmysqlclient-dev \
	unzip && \
	rm -rf /var/lib/apt/lists/* 
RUN git config --global http.postBuffer 1048576000 
ENV CAFFE_ROOT=/root/
WORKDIR $CAFFE_ROOT

RUN pip install --upgrade pip
RUN ln /dev/null /dev/raw1394
RUN pip install pyOpenSSL ndg-httpsclient pyasn1
RUN  wget https://github.com/BVLC/caffe/archive/master.zip && unzip master.zip && mv caffe-master caffe && rm master.zip && cd caffe && \
	cp Makefile.config.example Makefile.config && \
	pip install --upgrade pip && \
	pip install six --upgrade --ignore-installed six && \
	sed -i 's/CUDA_DIR := \/usr\/local\/cuda/CUDA_DIR := \/usr\/local\/cuda-8.0/g' Makefile.config && \
	sed -i 's/-gencode arch=compute_20,code=sm_20/ /g' Makefile.config && \
	sed -i 's/-gencode arch=compute_20,code=sm_21/ /g' Makefile.config && \
	sed -i 's/INCLUDE_DIRS := $(PYTHON_INCLUDE) \/usr\/local\/include/INCLUDE_DIRS := $(PYTHON_INCLUDE) \/usr\/local\/include \/usr\/include\/hdf5\/serial\/ \/usr\/local\/cuda-8.0\/targets\/x86_64-linux\/include/g' Makefile.config && \
	sed -i 's/LIBRARY_DIRS := $(PYTHON_LIB) \/usr\/local\/lib \/usr\/lib/LIBRARY_DIRS := $(PYTHON_LIB) \/usr\/local\/lib \/usr\/lib \/usr\/lib\/x86_64-linux-gnu\/hdf5\/serial\/ \/usr\/local\/cuda-8.0\/targets\/x86_64-linux\/lib/g' Makefile.config && \
	export CPLUS_INCLUDE_PATH=$CPLUS_INCLUDE_PATH:/usr/local/cuda-8.0/targets/x86_64-linux/include/ && \
	apt-get update && apt-get install python-numpy && \
	pip install --upgrade --ignore-installed numpy && \
	make all -j8 && \
	make test -j8 && \
	cd python && \
	for req in $(cat requirements.txt); do pip install ---upgrade --ignore-installed -i https://pypi.tuna.tsinghua.edu.cn/simple $req ; done && \
	cd .. && \
	make pycaffe && \
	export PYTHONPATH=/root/caffe/python:$PYTHONPATH && \
	rm -rf /var/lib/apt/lists/* && \
	rm -rf /etc/apt/sources.list.d/* 
