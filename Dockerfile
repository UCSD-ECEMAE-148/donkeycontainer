FROM ghcr.io/ucsd-ecemae-148/donkeycontainer:utils AS utils

WORKDIR /home/projects/

####### CREATE VIRTUAL ENVIRONMENTS #######
RUN python3 -m venv "/opt/venv/donkey" --system-site-packages

######## DONKEYCAR FRAMEWORK ############ 
RUN source /opt/venv/donkey/bin/activate && \
    pip install donkeycar && \
    pip3 install crcmod pyserial

################ FINAL ##################
RUN mkdir -p /home/projects/mycar && \
    mkdir -p /root/.config

########### ADD CUSTOM FUNCTIONS ###########
WORKDIR /home/scripts/
COPY scripts/bashrc.sh ./bashrc.sh
RUN ["/bin/bash", "-c", "echo '. /home/scripts/bashrc.sh' >> /root/.bashrc"]

########### ADD CUSTOM FUNCTIONS ###########
COPY scripts/donkey_commands.sh ./donkey_commands.sh
RUN ["/bin/bash", "-c", "echo '. /home/scripts/donkey_commands.sh' >> /root/.bashrc"]

WORKDIR /home/projects/

CMD [ "/bin/bash" ]



# RUN git clone https://github.com/tawnkramer/gym-donkeycar && \
#     cd gym-donkeycar && \
#     source /opt/venv/donkey/bin/activate && \
#     pip install -e .[gym-donkeycar]

# # CMD ["python", "--device-id", "yZ952ezI --polaris 3gGOrFMX --device-port /dev/ttyUSB0"]
# # python3 runner.py --device-id yZ952ezI --polaris 3gGOrFMX --device-port /dev/ttyUSB0
