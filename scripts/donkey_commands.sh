function source_donkey(){ 
    source /opt/venv/donkey/bin/activate
    cd /home/projects/mycar
}

export LD_PRELOAD=/usr/lib/aarch64-linux-gnu/libgomp.so.1 # HACK to cannot load static memory

clear
echo "Virtual Environments available:
    1) ROS:         source_ros1
    2) ROS2:        source_ros2
    3) Donkeycar:   source_donkey
"