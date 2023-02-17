cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(RelateProcessor LANGUAGES CXX)
#生成可执行文件
add_executable(arch_dependent arch_dependent.cpp)
# 通过CMAKE_SIZEOF_VOID_P变量获得cpu类型为32位还是64位
if(CMAKE_SIZEOF_VOID_P EQUAL 8) #64位
    #为项目定义 宏定义，IS_64_BIT_ARCH
    target_compile_definitions(arch_dependent PUBLIC "IS_64_BIT_ARCH")
    message(STATUS "Target is 64 bits")
else()
    target_compile_definitions(arch_dependent PUBLIC "IS_32_BIT_ARCH")
    message(STATUS "Target is 32 bits")
endif()

if(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "i386")
        #i386相关设置
    elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "i686")
        #i686相关CMake设置
    elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "x86_64")
        #x86_64相关CMake设置
    elseif(CMAKE_HOST_SYSTEM_PROCESSOR MATCHES "AMD64")
        #AMD64相关CMake设置
    else()
endif()
message(STATUS "${CMAKE_HOST_SYSTEM_PROCESSOR} architecture detected")
message(STATUS "system processor: ${CMAKE_SYSTEM_PROCESSOR}")
message(STATUS "system processor: ${CMAKE_HOST_SYSTEM_PROCESSOR}")
# 为源文件中的ARCHITECTURE设定值
target_compile_definitions(arch_dependent
  PUBLIC "ARCHITECTURE=${CMAKE_HOST_SYSTEM_PROCESSOR}"
  )