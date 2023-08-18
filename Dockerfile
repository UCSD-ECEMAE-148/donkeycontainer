FROM ghcr.io/ucsd-ecemae-148/donkeycontainer:ros AS ros

WORKDIR /home/projects/

####### CREATE VIRTUAL ENVIRONMENTS #######
RUN python3 -m venv "/opt/venv/donkey" --system-site-packages

######## DONKEYCAR FRAMEWORK ############ 
RUN git clone https://github.com/UCSD-ECEMAE-148/donkeycar.git -b main && \
    cd donkeycar && \
    source /opt/venv/donkey/bin/activate && \
    pip3 install -U --no-cache install -e .[nano]

RUN pip3 install crcmod pyserial

RUN apt update
RUN apt install -y ros-foxy-rosbag2-storage-mcap 
RUN pip3 install mcap-ros2-support

################ FINAL ##################
RUN mkdir -p /home/projects/mycar && \
    mkdir -p /root/.config

RUN cd /home/projects/sensor2_ws/src/lidars/livox/src/Livox-SDK2  && \
    cd build && \
    cmake .. && make -j"$(nproc)" && \
    make install

########### ADD CUSTOM FUNCTIONS ###########
WORKDIR /home/scripts/
COPY scripts/donkey_commands.sh ./donkey.sh
RUN ["/bin/bash", "-c", "echo '. /home/scripts/donkey.sh' >> /root/.bashrc"]

########### ADD CUSTOM FUNCTIONS ###########
COPY scripts/ros2_commands.sh ./ros.sh
RUN ["/bin/bash", "-c", "echo '. /home/scripts/ros.sh' >> /root/.bashrc"]

WORKDIR /home/projects/

CMD [ "/bin/bash" ]

################ POINTONENAV #################
RUN python3 -m venv "/opt/venv/p1_runner" --system-site-packages && \
    source /opt/venv/p1_runner/bin/activate && \
    git clone https://github.com/PointOneNav/p1-host-tools.git && \
    cd p1-host-tools && \
    pip install -r requirements.txt

RUN git clone https://github.com/tawnkramer/gym-donkeycar && \
    cd gym-donkeycar && \
    source /opt/venv/donkey/bin/activate && \
    pip install -e .[gym-donkeycar]

# CMD ["python", "--device-id", "yZ952ezI --polaris 3gGOrFMX --device-port /dev/ttyUSB0"]
# python3 runner.py --device-id yZ952ezI --polaris 3gGOrFMX --device-port /dev/ttyUSB0
