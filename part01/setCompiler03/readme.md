@[TOC]
# 编译器设置与查询
查询能设置的编译器选项, 输出到information.txt文件中
```bash
cmake --system-information information.txt 
```
# c++和c的编译器设置与查询
只查询编译器设置情况，所以无源代码文件
如果要设置特定语言的编译器，则CMakeLists.txt中添加相关的语句即可。例如：
```bash
set(CMAKE_CXX_COMPILER "编译器绝对路径")
```

```bash
cmake_minimum_required(VERSION 3.25.1 FATAL_ERROR)
project(setCompiler03 LANGUAGES C CXX)

message(STATUS "Is the C++ compiler loaded? ${CMAKE_CXX_COMPILER_LOADED}")
if(CMAKE_CXX_COMPILER_LOADED)
    message(STATUS "The C++ compiler ID is: ${CMAKE_CXX_COMPILER_ID}")
    #查询该语言的编译器是否为GNC编译器集合中的一个
    message(STATUS "Is the C++ from GNU? ${CMAKE_COMPILER_IS_GNUCXX}")
    message(STATUS "The C++ compiler version is: ${CMAKE_CXX_COMPILER_VERSION}")
endif()

message(STATUS "Is the C compiler loaded? ${CMAKE_C_COMPILER_LOADED}")
if(CMAKE_C_COMPILER_LOADED)
    message(STATUS "The C compiler ID is: ${CMAKE_C_COMPILER_ID}")
    #查询该语言的编译器是否为GNC编译器集合中的一个
    message(STATUS "Is the C from GNU? ${CMAKE_COMPILER_IS_GNUCC}")
    message(STATUS "The C compiler version is: ${CMAKE_C_COMPILER_VERSION}")
endif()

message(STATUS "Is the CUDA compiler loaded? ${CMAKE_CUDA_COMPILER_LOADED}")
if(CMAKE_CUDA_COMPILER_LOADED)
    message(STATUS "The CUDA compiler ID is: ${CMAKE_CUDA_COMPILER_ID}")
    message(STATUS "The CUDA compiler version is: ${CMAKE_CUDA_COMPILER_VERSION}")
endif()
```

# 查询结果
```bash
[root setCompiler03]# mkdir -p build&&cd build
[root build]# cmake ..
-- The C compiler identification is GNU 7.3.1
-- The CXX compiler identification is GNU 7.3.1
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /opt/rh/devtoolset-7/root/usr/bin/cc - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /opt/rh/devtoolset-7/root/usr/bin/c++ - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- Is the C++ compiler loaded? 1
-- The C++ compiler ID is: GNU
-- Is the C++ from GNU? 1
-- The C++ compiler version is: 7.3.1
-- Is the C compiler loaded? 1
-- The C compiler ID is: GNU
-- Is the C from GNU? 1
-- The C compiler version is: 7.3.1
-- Is the CUDA compiler loaded?
-- Configuring done
-- Generating done
-- Build files have been written to: /home/work/CmakeLearning/part01/setCompiler03/build
```