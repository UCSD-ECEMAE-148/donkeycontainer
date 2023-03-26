FROM nvcr.io/nvidia/l4t-base:r35.2.1 as base
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG DEBIAN_FRONTEND=noninteractive

######### JETPACK FOR JETSON #########
# Install any utils needed for execution
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

# Setup environment variables
ENV CUDA_HOME="/usr/local/cuda"
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

#Update libraries
RUN ldconfig 

# FROM base AS buildCV2
# WORKDIR /projects
# # DOWNLOAD OPENCV
# RUN apt-get update
# RUN apt-get install -y --no-install-recommends git unzip
# RUN wget -O opencv.zip https://github.com/opencv/opencv/archive/4.7.0.zip && \
#     wget -O opencv_contrib.zip https://github.com/opencv/opencv_contrib/archive/4.7.0.zip && \
#     unzip opencv.zip && \
#     unzip opencv_contrib.zip && \
#     mv opencv-4.7.0 opencv && \
#     mv opencv_contrib-4.7.0 opencv_contrib && \
#     rm opencv.zip && \
#     rm opencv_contrib.zip

# # SETUP PREREQUISITE FOR BUILDING OPENCV
# RUN apt-get install -y build-essential cmake git unzip pkg-config zlib1g-dev
# RUN apt-get install -y libjpeg-dev libjpeg8-dev libjpeg-turbo8-dev libpng-dev libtiff-dev
# RUN apt-get install -y libavcodec-dev libavformat-dev libswscale-dev libglew-dev
# RUN apt-get install -y libgtk2.0-dev libgtk-3-dev libcanberra-gtk*
# RUN apt-get install -y python3-dev python3-numpy python3-pip
# RUN apt-get install -y libxvidcore-dev libx264-dev libgtk-3-dev
# RUN apt-get install -y libtbb2 libtbb-dev libdc1394-22-dev libxine2-dev
# RUN apt-get install -y gstreamer1.0-tools libv4l-dev v4l-utils qv4l2 
# RUN apt-get install -y libgstreamer-plugins-base1.0-dev libgstreamer-plugins-good1.0-dev
# RUN apt-get install -y libavresample-dev libvorbis-dev libxine2-dev libtesseract-dev
# RUN apt-get install -y libfaac-dev libmp3lame-dev libtheora-dev libpostproc-dev
# RUN apt-get install -y libopencore-amrnb-dev libopencore-amrwb-dev
# RUN apt-get install -y libopenblas-dev libatlas-base-dev libblas-dev
# RUN apt-get install -y liblapack-dev liblapacke-dev libeigen3-dev gfortran
# RUN apt-get install -y libhdf5-dev protobuf-compiler
# RUN apt-get install -y libprotobuf-dev libgoogle-glog-dev libgflags-dev

# WORKDIR /projects/opencv/build
# RUN cmake -D CMAKE_BUILD_TYPE=RELEASE \
#     -D CMAKE_INSTALL_PREFIX=/usr \
#     -D OPENCV_EXTRA_MODULES_PATH=~/opencv_contrib/modules \
#     -D EIGEN_INCLUDE_PATH=/usr/include/eigen3 \
#     -D WITH_OPENCL=OFF \
#     -D WITH_CUDA=ON \
#     -D CUDA_ARCH_BIN=5.3 \
#     -D CUDA_ARCH_PTX="" \
#     -D WITH_CUDNN=ON \
#     -D WITH_CUBLAS=ON \
#     -D ENABLE_FAST_MATH=ON \
#     -D CUDA_FAST_MATH=ON \
#     -D OPENCV_DNN_CUDA=ON \
#     -D ENABLE_NEON=ON \
#     -D WITH_QT=OFF \
#     -D WITH_OPENMP=ON \
#     -D BUILD_TIFF=ON \
#     -D WITH_FFMPEG=ON \
#     -D WITH_GSTREAMER=ON \
#     -D WITH_TBB=ON \
#     -D BUILD_TBB=ON \
#     -D BUILD_TESTS=OFF \
#     -D WITH_EIGEN=ON \
#     -D WITH_V4L=ON \
#     -D WITH_LIBV4L=ON \
#     -D OPENCV_ENABLE_NONFREE=ON \
#     -D INSTALL_C_EXAMPLES=OFF \
#     -D INSTALL_PYTHON_EXAMPLES=OFF \
#     -D PYTHON3_PACKAGES_PATH=/usr/lib/python3/dist-packages \
#     -D OPENCV_GENERATE_PKGCONFIG=ON \
#     -D BUILD_EXAMPLES=OFF ..

# RUN make -j 4
# RUN make install

FROM base AS jetpack

############## INSTALL ALL THE DIFFERENT FRAMEWORK USED IN THE COURSES ##############
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    python3-venv \
    python3-dev \
    git \
    curl && \
    rm -rf /var/lib/apt/lists/* && apt-get clean

####### CREATE VIRTUAL ENVIRONMENTS #######
RUN echo "alias python=python3" >> ~/.bashrc
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv "${VIRTUAL_ENV}/donkey" && \
    python3 -m venv "${VIRTUAL_ENV}/pytorch" && \
    python3 -m venv "${VIRTUAL_ENV}/tensorflow"

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
RUN source ${VIRTUAL_ENV}/pytorch/bin/activate && \
    python3 -m pip install --upgrade pip && python3 -m pip install aiohttp numpy=='1.19.4' \
    scipy=='1.5.3'&& export "LD_LIBRARY_PATH=/usr/lib/llvm-8/lib:$LD_LIBRARY_PATH" &&\
    python3 -m pip install --upgrade protobuf && python3 -m pip install --no-cache $TORCH_INSTALL

######### Tensorflow for Jetpack #########
ARG TENSORFLOW_INSTALL=https://developer.download.nvidia.com/compute/redist/jp/v51
RUN apt update && apt install -y  \
    python3-pip libhdf5-serial-dev hdf5-tools libhdf5-dev zlib1g-dev \
    zip libjpeg8-dev liblapack-dev libblas-dev gfortran && \
    apt clean && rm -rf /var/lib/apt/lists/*
RUN source ${VIRTUAL_ENV}/tensorflow/bin/activate && \
    python3 -m pip install --upgrade pip && \
    pip3 install --no-cache -U testresources setuptools==65.5.0 && \
    pip3 install --no-cache -U numpy==1.22 future==0.18.2 mock==3.0.5 keras_preprocessing==1.1.2 keras_applications==1.0.8 gast==0.4.0 protobuf pybind11 cython pkgconfig packaging h5py==3.6.0 && \
    pip3 install -U --no-cache --extra-index-url ${TENSORFLOW_INSTALL} tensorflow==2.11.0+nv23.01

######## DONKEYCAR FRAMEWORK ############ 
RUN git clone https://github.com/UCSD-ECEMAE-148/donkeycar.git -b main && \
    cd donkeycar && \
    source ${VIRTUAL_ENV}/donkey/bin/activate && \
    pip3 install -U --no-cache install -e .[nano]

########### ADD CUSTOM FUNCTIONS ###########
RUN echo "activate_donkey(){ source ${VIRTUAL_ENV}/donkey/bin/activate; }" >> ~/.bashrc && \
    echo "activate_pytorch(){ source ${VIRTUAL_ENV}/pytorch/bin/activate; }" >> ~/.bashrc && \
    echo "activate_tensorflow(){ source ${VIRTUAL_ENV}/tensorflow/bin/activate; }" >> ~/.bashrc

FROM jetpack AS framework
################ PYVESC ##################
RUN source ${VIRTUAL_ENV}/donkey/bin/activate && \
    pip3 install --no-cache git+https://github.com/UCSD-ECEMAE-148/PyVESC.git@master

################ DEPTHAI ##################
WORKDIR /projects
RUN git clone https://github.com/luxonis/depthai.git && \
    git clone https://github.com/luxonis/depthai-python.git && \
    cd depthai && \
    source ${VIRTUAL_ENV}/donkey/bin/activate && \
    curl -fL https://docs.luxonis.com/install_dependencies.sh | bash && \
    python3 install_requirements.py && \
    cd ../depthai-python/examples && \
    python3 install_requirements.py 
RUN echo "export OPENBLAS_CORETYPE=ARMV8" >> ~/.bashrc
RUN echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="03e7", MODE="0666"' | tee /etc/udev/rules.d/80-movidius.rules

# ################ POINTONENAV #################
# RUN mkdir -p ~/.ssh && \
#     ssh-keyscan github.com >> ~/.ssh/known_hosts

# RUN --mount=type=ssh \
#     git clone git@github.com:UCSD-ECEMAE-148/p1_runner.git
# RUN cd p1_runner && source ${VIRTUAL_ENV}/donkey/bin/activate && pip3 install -e .

FROM framework AS final
################ ADDITIONAL UTILITIES ##################
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    vim \
    nano \
    jstest-gtk \
    x11-apps &&\
    rm -rf /var/lib/apt/lists/* && apt-get clean

################ DATA SCIENCE TOOLS ################
RUN pip3 install -U --no-cache install seaborn

################ FINAL ##################
WORKDIR /projects/mycar

# # # CMD ["python", "--device-id", "yZ952ezI --polaris 3gGOrFMX --device-port /dev/ttyUSB0"]