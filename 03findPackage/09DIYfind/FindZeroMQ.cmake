#查找是否存在zeroMQ安装目录的环境变量
if(NOT ZeroMQ_ROOT)
    #如果没有设置，则设置环境变量且为空
    set(ZeroMQ_ROOT "$ENV{ZeroMQ_ROOT}")
endif()

#搜索头文件位置，_ZeroMQ_ROOT为环境变量的临时变量，
#为防止对原系统变量的修改
if(NOT ZeroMQ_ROOT)
    #没有设置库安装目录的环境变量则，使用find_path搜索
    find_path(_ZeroMQ_ROOT NAMES include/zmq.h)
else()
    #设置了环境变量，则赋值给临时变量
    set(_ZeroMQ_ROOT "${ZeroMQ_ROOT}")
endif()
find_path(ZeroMQ_INCLUDE_DIRS NAMES zmq.h HINTS ${_ZeroMQ_ROOT}/include)
#以上查找到库头文件位置

#设置头文件目录变量
set(_ZeroMQ_H ${ZeroMQ_INCLUDE_DIRS}/zmq.h)
#查找相应版本的ZeroMQ库
function(_zmqver_EXTRACT _ZeroMQ_VER_COMPONENT _ZeroMQ_VER_OUTPUT)
set(CMAKE_MATCH_1 "0")
set(_ZeroMQ_expr "^[ \\t]*#define[ \\t]+${_ZeroMQ_VER_COMPONENT}[ \\t]+([0-9]+)$")
file(STRINGS "${_ZeroMQ_H}" _ZeroMQ_ver REGEX "${_ZeroMQ_expr}")
string(REGEX MATCH "${_ZeroMQ_expr}" ZeroMQ_ver "${_ZeroMQ_ver}")
set(${_ZeroMQ_VER_OUTPUT} "${CMAKE_MATCH_1}" PARENT_SCOPE)
endfunction()
_zmqver_EXTRACT("ZMQ_VERSION_MAJOR" ZeroMQ_VERSION_MAJOR)
_zmqver_EXTRACT("ZMQ_VERSION_MINOR" ZeroMQ_VERSION_MINOR)
_zmqver_EXTRACT("ZMQ_VERSION_PATCH" ZeroMQ_VERSION_PATCH)

#find_package_handle_standard_args准备ZeroMQ_VERSION变量
if(ZeroMQ_FIND_VERSION_COUNT GREATER 2)
    set(ZeroMQ_VERSION "${ZeroMQ_VERSION_MAJOR}.${ZeroMQ_VERSION_MINOR}.${ZeroMQ_VERSION_PATCH}")
else()
    set(ZeroMQ_VERSION "${ZeroMQ_VERSION_MAJOR}.${ZeroMQ_VERSION_MINOR}")
endif()

#使用find_library命令搜索zerorMQ库，不同环境的库名不同
if(NOT ${CMAKE_C_PLATFORM_ID} STREQUAL "Windows")
  find_library(ZeroMQ_LIBRARIES
    NAMES
        zmq
    HINTS
      ${_ZeroMQ_ROOT}/lib
      ${_ZeroMQ_ROOT}/lib/x86_64-linux-gnu
    )
else()
  find_library(ZeroMQ_LIBRARIES
    NAMES
        libzmq
      "libzmq-mt-${ZeroMQ_VERSION_MAJOR}_${ZeroMQ_VERSION_MINOR}_${ZeroMQ_VERSION_PATCH}"
      "libzmq-${CMAKE_VS_PLATFORM_TOOLSET}-mt-${ZeroMQ_VERSION_MAJOR}_${ZeroMQ_VERSION_MINOR}_${ZeroMQ_VERSION_PATCH}"
      libzmq_d
      "libzmq-mt-gd-${ZeroMQ_VERSION_MAJOR}_${ZeroMQ_VERSION_MINOR}_${ZeroMQ_VERSION_PATCH}"
      "libzmq-${CMAKE_VS_PLATFORM_TOOLSET}-mt-gd-${ZeroMQ_VERSION_MAJOR}_${ZeroMQ_VERSION_MINOR}_${ZeroMQ_VERSION_PATCH}"
    HINTS
        ${_ZeroMQ_ROOT}/lib
    )
endif()

#找到所有需要的变量，并且版本匹配，则将Zero_FOUND设置为TRUE
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(ZeroMQ
  FOUND_VAR
      ZeroMQ_FOUND
  REQUIRED_VARS
  ZeroMQ_INCLUDE_DIRS
  ZeroMQ_LIBRARIES
  VERSION_VAR
  ZeroMQ_VERSION
)