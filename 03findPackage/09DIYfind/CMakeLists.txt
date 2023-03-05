cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(09DIYfind LANGUAGES C CXX)
#将当前目录添加到cmake的查找模块路径列表中，
#以便cmake使用过自己编写的FindZMQ.cmake模块
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR})
#使用自己的findzeroMQ文件
find_package(ZeroMQ REQUIRED)
add_executable(hwserver hwserver.cpp)
target_compile_options(hwserver PRIVATE "-Wno-unused-result")
target_include_directories(hwserver
    PRIVATE
        ${ZeroMQ_INCLUDE_DIRS}
)
target_link_libraries(hwserver
    PRIVATE
        ${ZeroMQ_LIBRARIES}
)
add_executable(hwclient hwclient.cpp)
target_compile_options(hwclient PRIVATE "-Wno-unused-result")
target_include_directories(hwclient
    PRIVATE
        ${ZeroMQ_INCLUDE_DIRS}
)
target_link_libraries(hwclient
    PRIVATE
        ${ZeroMQ_LIBRARIES}
)
set_target_properties(hwserver hwclient
    PROPERTIES
        CXX_STANDARD 11
        CXX_EXTENSIONS OFF
        CXX_STANDARD_REQUIRED ON
    )