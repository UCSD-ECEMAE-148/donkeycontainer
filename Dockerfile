FROM ghcr.io/ucsd-ecemae-148/donkeycontainer:ros AS ros

WORKDIR /home/projects/

####### CREATE VIRTUAL ENVIRONMENTS #######
RUN echo "alias python=python3" >> ~/.bashrc
ENV VIRTUAL_ENV=/opt/venv
RUN python3 -m venv "${VIRTUAL_ENV}/donkey" --system-site-packages

######## DONKEYCAR FRAMEWORK ############ 
RUN git clone https://github.com/UCSD-ECEMAE-148/donkeycar.git -b main && \
    cd donkeycar && \
    source ${VIRTUAL_ENV}/donkey/bin/activate && \
    pip3 install -U --no-cache install -e .[nano]

########### ADD CUSTOM FUNCTIONS ###########
RUN echo "source_donkey(){ source ${VIRTUAL_ENV}/donkey/bin/activate; }" >> ~/.bashrc

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

# # ################ POINTONENAV #################
# RUN mkdir -p ~/.ssh && \
#     ssh-keyscan github.com >> ~/.ssh/known_hosts

RUN git clone https://github.com/UCSD-ECEMAE-148/p2_runner.git p1_runner
RUN cd p1_runner && source ${VIRTUAL_ENV}/donkey/bin/activate && pip3 install -e .

################ ADDITIONAL UTILITIES ##################
RUN apt-get -y update && apt-get install -y --no-install-recommends \
    vim \
    nano \
    jstest-gtk \
    x11-apps &&\
    rm -rf /var/lib/apt/lists/* && apt-get clean

################ DATA SCIENCE TOOLS ################
RUN source ${VIRTUAL_ENV}/donkey/bin/activate && pip3 install -U --no-cache install seaborn pandas tqdm
RUN git clone https://github.com/mmwong920/bounding_box_depthai.git

################ FINAL ##################
WORKDIR /home/projects//mycar

# CMD ["python", "--device-id", "yZ952ezI --polaris 3gGOrFMX --device-port /dev/ttyUSB0"]