FROM docker.io/library/buildcv2 AS cv2

############## INSTALL ALL THE DIFFERENT FRAMEWORKs USED IN THE COURSES ##############
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

FROM cv2 AS framework
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

# # ################ POINTONENAV #################
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
