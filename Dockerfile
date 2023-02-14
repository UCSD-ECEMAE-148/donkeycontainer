FROM nvcr.io/nvidia/l4t-base:r35.1.0
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
ARG DEBIAN_FRONTEND=noninteractive
RUN echo "alias python=python3" >> ~/.bashrc

# Setup environment variables
ENV CUDA_HOME="/usr/local/cuda"
ENV PATH="/usr/local/cuda/bin:${PATH}"
ENV LD_LIBRARY_PATH="/usr/local/cuda/lib64:${LD_LIBRARY_PATH}"

######## DONKEYCAR FRAMEWORK ############
RUN apt update && apt -y install --no-install-recommends \
  ca-certificates \
  software-properties-common \
  build-essential \
  sudo \
  git \
  udev \
  python3-pip \
  python3-setuptools \
  vim \
  nano \
  net-tools \
  rsync \
  zip \
  htop \
  curl \
  wget \
  iputils-ping \
  ffmpeg \
  libsm6 \
  libxext6 \
  jstest-gtk \
  x11-apps \
  unzip \
  && apt clean \
  && rm -rf /var/lib/apt/lists/*

RUN python3 -m pip install --upgrade pip

RUN pip3 uninstall --no-cache tensorflow && \
    pip3 install -U --no-cache install seaborn

RUN pip3 install -U --no-cache install tensorflow && \
    pip3 install -U --no-cache install torch torchvision torchaudio --extra-index-url https://download.pytorch.org/whl/cu117

################ PYVESC ##################
RUN pip3 install --no-cache git+https://github.com/sisaha9/PyVESC.git@sid-devel

################ DEPTHAI ##################
WORKDIR /projects
RUN git clone https://github.com/luxonis/depthai.git && \
    git clone https://github.com/luxonis/depthai-python.git && \
    cd depthai && \
    curl -fL https://docs.luxonis.com/install_dependencies.sh | bash && \
    python3 install_requirements.py && \
    cd ../depthai-python/examples && \
    python3 install_requirements.py 
# RUN echo "export OPENBLAS_CORETYPE=ARMV8" >> ~/.bashrc
# RUN echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="03e7", MODE="0666"' | tee /etc/udev/rules.d/80-movidius.rules

################ DONKEYCAR ##################
RUN git clone https://github.com/UCSD-ECEMAE-148/donkeycar.git && \
    cd donkeycar && \
    pip3 install -U --no-cache install -e .[pc]

################ FINAL ##################
COPY ./mycar /projects/donkeycar/mycar 
WORKDIR /projects/donkeycar/mycar
CMD ["/bin/bash"]
