nvidia-docker run \
    --name donkey\
    -it\
    --rm \
    --privileged \
    --net=host \
    -e DISPLAY=$DISPLAY \
    -v /dev/bus/usb:/dev/bus/usb \
    --device-cgroup-rule='c 189:* rmw' \
    --device /dev/video0 \
    --volume='/dev/input:/dev/input' \
    --volume='/home/jetson/.Xauthority:/root/.Xauthority:rw' \
    --volume='/tmp/.X11-unix/:/tmp/.X11-unix' \
    --volume='/home/jetson/projects/mycar:/home/projects/mycar' \
    --volume='/home/jetson/projects/ucsd_robocar:/home/projects/ros2_ws/src' \
    ghcr.io/ucsd-ecemae-148/donkeycontainer:devel