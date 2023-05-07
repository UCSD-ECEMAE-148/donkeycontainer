FROM ghcr.io/ucsd-ecemae-148/donkeycontainer:ros AS ros

WORKDIR /home/projects/

####### CREATE VIRTUAL ENVIRONMENTS #######
RUN python3 -m venv "/opt/venv/donkey" --system-site-packages

######## DONKEYCAR FRAMEWORK ############ 
RUN git clone https://github.com/sisaha9/donkeycar.git -b sid_devel && \
    cd donkeycar && \
    source /opt/venv/donkey/bin/activate && \
    pip3 install -U --no-cache install -e .[nano]

################ FINAL ##################
RUN mkdir -p /home/projects/mycar && \
    mkdir -p /root/.config

########### ADD CUSTOM FUNCTIONS ###########
WORKDIR /home/scripts/
COPY scripts/donkey_commands.sh ./donkey.sh
RUN ["/bin/bash", "-c", "echo '. /home/scripts/donkey.sh' >> /root/.bashrc"]

########### ADD CUSTOM FUNCTIONS ###########
COPY scripts/ros2_commands.sh ./ros.sh
RUN ["/bin/bash", "-c", "echo '. /home/scripts/ros.sh' >> /root/.bashrc"]

WORKDIR /home/projects/

# CMD ["python", "--device-id", "yZ952ezI --polaris 3gGOrFMX --device-port /dev/ttyUSB0"]