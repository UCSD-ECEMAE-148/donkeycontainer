FROM nvcr.io/nvidia/l4t-base:r35.1.0
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

######### JETPACK FOR JETSON #########
Install any utils needed for execution
RUN apt-get update && apt-get install -y --no-install-recommends \
    sudo \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install nvidia-cuda-dev for CUDA developer packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    nvidia-cuda-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install nvidia-cudnn8-dev for CuDNN developer packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    nvidia-cudnn8-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install nvidia-tensorrt-dev for TensorRT developer packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    nvidia-tensorrt-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install nvidia-vpi-dev for VPI developer packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    nvidia-vpi-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install nvidia-opencv-dev for OpenCV developer packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    nvidia-opencv-dev \
    && rm -rf /var/lib/apt/lists/* \
    && apt-get clean

# Install Multimedia API samples & libs
RUN apt-get update && apt-get download nvidia-l4t-jetson-multimedia-api \
    && dpkg-deb -R ./nvidia-l4t-jetson-multimedia-api_*_arm64.deb ./mm-api \
    && cp -r ./mm-api/usr/src/jetson_multimedia_api /usr/src/jetson_multimedia_api \
    && ./mm-api/DEBIAN/postinst \
    && rm -rf ./nvidia-l4t-jetson-multimedia-api_*_arm64.deb ./mm-api

#Update libraries
RUN ldconfig 

# Setup environment variables
ENV CUDA_HOME="/usr/local/cuda"
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

######### PyTorch for Jetpack #########
ARG TORCH_INSTALL=https://developer.download.nvidia.cn/compute/redist/jp/v51/pytorch/torch-1.14.0a0+44dac51c.nv23.01-cp38-cp38-linux_aarch64.whl
RUN apt-get -y update && \
    apt-get -y install autoconf bc build-essential g++-8 gcc-8 clang-8 lld-8 \
    gettext-base gfortran-8 iputils-ping libbz2-dev libc++-dev libcgal-dev \
    libffi-dev libfreetype6-dev libhdf5-dev libjpeg-dev liblzma-dev libncurses5-dev \
    libncursesw5-dev libpng-dev libreadline-dev libssl-dev libsqlite3-dev libxml2-dev \
    libxslt-dev locales moreutils openssl python-openssl rsync scons python3-pip \
    libopenblas-dev && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
RUN python3 -m pip install --upgrade pip; python3 -m pip install aiohttp numpy=='1.19.4' \
    scipy=='1.5.3' export "LD_LIBRARY_PATH=/usr/lib/llvm-8/lib:$LD_LIBRARY_PATH";\
    python3 -m pip install --upgrade protobuf; python3 -m pip install --no-cache $TORCH_INSTALL

######### Tensorflow for Jetpack #########
RUN apt update && apt install -y libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev zip libjpeg8-dev liblapack-dev libblas-dev gfortran python3-h5py && \
    apt clean && \
    rm -rf /var/lib/apt/lists/*
RUN pip3 install --no-cache install -U testresources setuptools==65.5.0
RUN pip3 install --no-cache install -U numpy==1.21.1 future==0.18.2 mock==3.0.5 keras_preprocessing==1.1.2 keras_applications==1.0.8 gast==0.4.0 protobuf pybind11 cython pkgconfig packaging h5py==3.6.0
RUN pip3 install -U --no-cache install --extra-index-url https://developer.download.nvidia.com/compute/redist/jp/v502 tensorflow==2.9.1+nv22.7

# ######## DONKEYCAR FRAMEWORK ############
# RUN echo "alias python=python3" >> ~/.bashrc
# RUN apt update && apt -y install --no-install-recommends \
#   ca-certificates \
#   software-properties-common \
#   build-essential \
#   sudo \
#   git \
#   udev \
#   python3-pip \
#   python3-setuptools \
#   vim \
#   nano \
#   net-tools \
#   rsync \
#   zip \
#   htop \
#   curl \
#   wget \
#   iputils-ping \
#   ffmpeg \
#   libsm6 \
#   libxext6 \
#   jstest-gtk \
#   x11-apps \
#   unzip \
#   && apt clean \
#   && rm -rf /var/lib/apt/lists/*

################ PYVESC ##################
RUN apt update && apt install -y git curl
RUN pip3 install --no-cache git+https://github.com/UCSD-ECEMAE-148/PyVESC.git@master


################ DEPTHAI ##################
WORKDIR /projects
RUN git clone https://github.com/luxonis/depthai.git && \
    git clone https://github.com/luxonis/depthai-python.git && \
    cd depthai && \
    curl -fL https://docs.luxonis.com/install_dependencies.sh | bash && \
    python3 install_requirements.py && \
    cd ../depthai-python/examples && \
    python3 install_requirements.py 
RUN echo "export OPENBLAS_CORETYPE=ARMV8" >> ~/.bashrc
RUN echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="03e7", MODE="0666"' | tee /etc/udev/rules.d/80-movidius.rules

################ DONKEYCAR ##################
RUN git clone https://github.com/UCSD-ECEMAE-148/donkeycar.git && \
    cd donkeycar && \
    pip3 install -U --no-cache install -e .[nano]


################ POINTONENAV #################
RUN mkdir -p ~/.ssh && \
    ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN --mount=type=ssh \
    git clone git@github.com:UCSD-ECEMAE-148/p1_runner.git
RUN cd p1_runner && pip3 install -e .

RUN pip3 install -U --no-cache install seaborn

################ FINAL ##################
#COPY ./mycar /projects/donkeycar/mycar 
#WORKDIR /projects/donkeycar/mycar
CMD ["/bin/bash"]
