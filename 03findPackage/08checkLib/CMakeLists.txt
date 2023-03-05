cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(pkg_config LANGUAGES C CXX)
#未提供findzmq.cmake模块
# find_package(zmq REQUIRED)
#使用pkg-config的config模式
find_package(PkgConfig REQUIRED )
pkg_search_module(
    ZeroMQ
    REQUIRE
        libzeromq libzmq lib0mq
    IMPORTED_TARGET
)
#找到则打印信息
if(TARGET pkgconfig::ZeroMQ)
    message(STATUS "FOUND ZEROMQ")
endif()
add_executable(hwserver hwserver.cpp)
target_compile_options(hwserver PRIVATE "-Wno-unused-result")
target_link_libraries(hwserver PkgConfig::ZeroMQ)
add_executable(hwclient hwclient.cpp)
target_compile_options(hwclient PRIVATE "-Wno-unused-result")
target_link_libraries(hwclient PkgConfig::ZeroMQ)
set_target_properties(hwserver hwclient
    PROPERTIES
        C_EXTENSIONS OFF
        C_STANDARD 11
        C_STANDARD_REQUIRED ON
)

