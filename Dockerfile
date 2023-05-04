FROM ghcr.io/ucsd-ecemae-148/donkeycontainer:ros AS ros

WORKDIR /home/projects/

####### CREATE VIRTUAL ENVIRONMENTS #######
RUN echo "alias python=python3" >> ~/.bashrc
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv "${VIRTUAL_ENV}/donkey" --system-site-packages

######## DONKEYCAR FRAMEWORK ############ 
RUN git clone https://github.com/sisaha9/donkeycar.git -b sid_devel && \
    cd donkeycar && \
    source ${VIRTUAL_ENV}/donkey/bin/activate && \
    pip3 install -U --no-cache install -e .[nano]

################ PYVESC ##################
RUN source ${VIRTUAL_ENV}/donkey/bin/activate && \
    pip3 install --no-cache git+https://github.com/UCSD-ECEMAE-148/PyVESC.git@master

################ DEPTHAI ##################
WORKDIR /home/projects/
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

################ POINTONENAV #################
RUN git clone https://github.com/PointOneNav/fusion-engine-client.git
RUN cd fusion-engine-client/python && source ${VIRTUAL_ENV}/donkey/bin/activate && pip3 install -e .

################ ADDITIONAL UTILITIES ##################
RUN echo "wireshark-common wireshark-common/install-setuid boolean true" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive apt-get -y update && apt-get install -y \
    vim \
    nano \
    jstest-gtk \
    x11-apps \
    wireshark \
    python3-argcomplete && \
    rm -rf /var/lib/apt/lists/* && apt-get clean

################ DATA SCIENCE TOOLS ################
RUN source ${VIRTUAL_ENV}/ros/bin/activate && pip3 install -U --no-cache install inputs
RUN source ${VIRTUAL_ENV}/donkey/bin/activate && pip3 install -U --no-cache install seaborn pandas tqdm
RUN git clone https://github.com/mmwong920/bounding_box_depthai.git

################ FINAL ##################
RUN mkdir -p /home/projects/mycar
RUN mkdir -p /root/.config

########### ADD CUSTOM FUNCTIONS ###########
WORKDIR /home/scripts/
COPY scripts/donkey_commands.sh ./donkey.sh
RUN ["/bin/bash", "-c", "echo '. /home/scripts/donkey.sh' >> /root/.bashrc"]

########### ADD CUSTOM FUNCTIONS ###########
COPY scripts/ros2_commands.sh ./ros.sh
RUN ["/bin/bash", "-c", "echo '. /home/scripts/ros.sh' >> /root/.bashrc"]

WORKDIR /home/projects/

# CMD ["python", "--device-id", "yZ952ezI --polaris 3gGOrFMX --device-port /dev/ttyUSB0"]