#将当前目录添加到本`CMakelists.txt`中定义的所有目标的
#`interface_include_directory`属性中
set(CMAKE_INCLUDE_CURRENT_DIR_IN_INTERFACE ON)
add_library(sum_integers sum_integers.cpp)
add_executable(sum_up main.cpp)
target_link_libraries(sum_up sum_integers)