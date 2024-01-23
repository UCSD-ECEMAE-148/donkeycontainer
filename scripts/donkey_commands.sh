function source_donkey(){ 
    source /opt/venv/donkey/bin/activate
    cd /home/projects/mycars
    if [ -z "$(ls -A .)" ]; then
    donkey createcar --path=./myfirstcar
    echo "This is your first time here... Default vehicle was generated. 'ls' to see list of vehicles"
    else
    echo 'Welcome back :)'
    fi

}

function source_p1_tools(){
    source /opt/venv/p1_runner/bin/activate
    cd /home/projects/p1-host-tools/bin
}

function get_line_follower(){
    git clone https://github.com/UCSD-ECEMAE-148/simple-line-follower.git
}


function helpme(){
    echo "
Recommended docker command

    nvidia-docker run \\
        --name donkey \\
        -it \\
        --rm \\
        --privileged \\
        --net=host \\
        -e DISPLAY=\$DISPLAY \\
        -v /dev/bus/usb:/dev/bus/usb \\
        --device-cgroup-rule='c 189:* rmw' \\
        --device /dev/video0 \\
        --volume='/dev/input:/dev/input' \\
        --volume='/home/jetson/.Xauthority:/root/.Xauthority:rw' \\
        --volume='/tmp/.X11-unix/:/tmp/.X11-unix' \\
        --volume='/home/jetson/projects/mycar:/home/projects/mycar' \\
        --volume='/home/jetson/projects/ucsd_robocar2:/home/projects/ros2_ws/src' \\
        --volume='/home/jetson/projects/ucsd_robocar1:/home/projects/ros1_ws/src' \\
        ghcr.io/ucsd-ecemae-148/donkeycontainer:devel

This command runs a Docker container with the image 'ghcr.io/ucsd-ecemae-148/donkeycontainer:devel' using the Nvidia Docker runtime. The purpose of the container is to run a project related to a self-driving car.

Here's a breakdown of the different options used in the 'nvidia-docker run' command:

    - '--name donkey': sets the name of the container to 'donkey'.
    - '-it': starts an interactive terminal within the container.
    - '--rm': removes the container automatically when it exits.
    - '--privileged': gives the container full access to the host system's devices.
    - '--net=host': shares the host system's network stack with the container.
    - '-e DISPLAY=\$DISPLAY': sets the 'DISPLAY' environment variable to allow the container to display graphical applications on the host system.
    - '-v /dev/bus/usb:/dev/bus/usb': shares the host system's USB bus with the container.
    - '--device-cgroup-rule='\''c 189:* rmw'\''': sets the device cgroup rule for '/dev/nvhost-ctrl' to allow read, write, and mknod permissions for the container.
    - '--device /dev/video0': shares the host system's first video device with the container.
    - '--volume=''/dev/input:/dev/input'': shares the host system's input devices with the container.
    - '--volume=''/home/jetson/.Xauthority:/root/.Xauthority:rw'': shares the host system's X authentication file with the container.
    - '--volume=''/tmp/.X11-unix/:/tmp/.X11-unix'': shares the host system's X11 socket with the container.
    - '--volume=''/home/jetson/projects/mycar:/home/projects/mycar'': shares the host system's 'mycar' project directory with the container.
    - '--volume=''/home/jetson/projects/ucsd_robocar2:/home/projects/ros2_ws/src'': shares the host system's 'ucsd_robocar2' directory with the container.
    - '--volume=''/home/jetson/projects/ucsd_robocar1:/home/projects/ros1_ws/src'': shares the host system's 'ucsd_robocar1' directory with the container.

Finally, the 'ghcr.io/ucsd-ecemae-148/donkeycontainer:devel' specifies the image to use for the container, which is pulled from the Github Container Registry (ghcr.io) and tagged with 'devel'.
"
}
export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libgomp.so.1 # HACK to cannot load static memory

clear
echo "Virtual Environments available:
    1) Donkeycar:   source_donkey
    2) p1_tools:    source_p1_tools
    3) Help:        helpme
    4) Exit:        exit
"