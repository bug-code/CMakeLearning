cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(compilerPlatformSource LANGUAGES CXX)
#生成可执行文件
add_executable(helloWorld helloworld.cpp)
#为编译目标，设置宏定义以便处理平台相关源代码
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    #如果系统为linux，则为源代码生成一个IS_LINUX宏
  target_compile_definitions(helloWorld PUBLIC "IS_LINUX")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  target_compile_definitions(helloWorld PUBLIC "IS_MACOS")
elseif(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  target_compile_definitions(helloWorld PUBLIC "IS_WINDOWS")
endif()
