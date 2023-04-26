function build_ros2(){
  cd /home/projects//ros2_ws 
  rm -rf build/ install/ log/ 
  colcon build 
  source install/setup.bash
}

function source_ros2(){ 
  source /opt/ros/foxy/setup.bash
  cd /home/projects//ros2_ws
}