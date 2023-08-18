# Description: Script to install ROS1 and ROS2 packages

# Macro to install a ROS1 package
function installRos1Package () {
    mkdir -p "$1"/src && \
    cd "$1"/src && \
    git clone "$2" && \
    cd "$1" && \
    source /opt/venv/ros1/bin/activate && \
    source /opt/ros/noetic/setup.bash && \
    rosdep update && rosdep install --from-path src --ignore-src -y && \
    catkin_make && \
    source devel/setup.bash && \
    deactivate
}

# Macro for installing ROS2 packages
function installRos2Package () {
    mkdir -p "$1"/src && \
    cd "$1"/src && \
    git clone $3 $4 "$2" && \
    cd "$1" && \
    source /opt/venv/ros2/bin/activate && \
    source /opt/ros/foxy/setup.bash && \
    colcon build && \
    source install/setup.bash && \
    deactivate
}

########### ROS2 Packages ###########
# ROS2|POINTONEGPS|SIDGOD
installRos2Package /home/projects/sensor2_ws/src/gps/point_one_gps_driver https://github.com/airacingtech/fusion_engine_ros_driver.git -b master 

# ROS2|LIDAR|RPLidar
installRos2Package /home/projects/sensor2_ws/src/lidars/rplidar https://github.com/CreedyNZ/rplidar_ros2.git --branch ros2

# ROS2|LIDAR|SickTim5xx
installRos2Package /home/projects/sensor2_ws/src/lidars/sicktim https://github.com/SICKAG/sick_scan2.git

# ROS2|LIDAR|LD06
installRos2Package /home/projects/sensor2_ws/src/lidars/ld06 https://github.com/linorobot/ldlidar.git

# ROS2|CAMERAS|OAK-D
installRos2Package /home/projects/sensor2_ws/src/cameras/oakd https://github.com/Triton-AI/multi_cam_oak_lite.git

# ROS2|IMU|Artemis
installRos2Package /home/projects/sensor2_ws/src/imu/artemis_openlog https://github.com/sisaha9/razor_imu_9dof.git

# ROS2|GPS|ublox
installRos2Package /home/projects/sensor2_ws/src/gps/ublox https://github.com/KumarRobotics/ublox.git -b foxy-devel

# ROS2|ROSBOARD|rosboard
installRos2Package /home/projects/rosboard_ws https://github.com/dheera/rosboard.git &&
source /opt/venv/ros2/bin/activate && pip install tornado

# ROS2|ACTUATORS|VESC
installRos2Package /home/projects/sensor2_ws/src/vesc https://github.com/f1tenth/vesc.git -b foxy &&
installRos2Package /home/projects/sensor2_ws/src/vesc https://github.com/f1tenth/ackermann_mux.git -b foxy-devel &&
installRos2Package /home/projects/sensor2_ws/src/vesc https://github.com/f1tenth/teleop_tools.git -b foxy-devel

# ROS2|SIMULATOR|f1tenth_gym NOTE: INSTALL MANUALLY
mkdir -p /home/projects/sim2_ws/src && \
cd /home/projects/sim2_ws/src && \
git clone https://github.com/f1tenth/f1tenth_gym.git && \
cd /home/projects/sim2_ws/src/f1tenth_gym && \
source /opt/venv/ros2/bin/activate && \
pip3 install -e . && \
installRos2Package /home/projects/sim2_ws https://github.com/f1tenth/f1tenth_gym_ros.git

# ROS2|LIDAR|livox NOTE: INSTALL MANUALLY
mkdir -p /home/projects/sensor2_ws/src/lidars/livox/src && \
cd /home/projects/sensor2_ws/src/lidars/livox/src && \
git clone https://github.com/Livox-SDK/Livox-SDK2.git && \
cd Livox-SDK2  && \
mkdir build && \
cd build && \
cmake .. && make -j"$(nproc)" && \
sudo make install

cd /home/projects/sensor2_ws/src/lidars/livox/src && \
git clone https://github.com/Livox-SDK/livox_ros_driver2.git && \
source /opt/venv/ros2/bin/activate && \
source /opt/ros/foxy/setup.bash && \
cd ./livox_ros_driver2 && \
./build.sh ROS2

########### ROS1 Packages ###########
# ROS1|LIDAR|RPLidar
installRos1Package /home/projects/sensor1_ws/src/lidars/rplidar https://github.com/Slamtec/rplidar_ros.git

# ROS1|LIDAR|LD06 
installRos1Package /home/projects/sensor1_ws/src/lidars/ld06 https://github.com/AlessioMorale/ld06_lidar.git
