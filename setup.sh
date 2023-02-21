donkey_setup(){
   docker run \
      --name donkey_framework\
      -it \
      -d \
      --privileged \
      --net=host \
      -e DISPLAY=$DISPLAY \
      -v /dev/bus/usb:/dev/bus/usb \
      --device-cgroup-rule='c 189:* rmw' \
      --device /dev/video0 \
      --volume="$HOME/.Xauthority:/ root/.Xauthority:rw" \
      --volume="/tmp/.X11-unix/:/tmp/.X11-unix"
      --volume="$HOME/projects/mycar:/donkeycar/mycar" \
      mdlopezme/ucsdrobocar:jetson
}
donkey_start(){
   if [ ! "$(docker ps -q -f name=donkey_framework)" ]; then
      docker run -d donkey_framework
   fi

   docker exec --it donkey_framework bash
}
donkey_stop(){
   docker stop donkey_framework
}
