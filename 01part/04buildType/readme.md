@[TOC]
# 指定代码编译构建类型
构建类型的区别：
- Debug：用于在没有优化的情况下，使用带有调试符号构建库或可执行文件。
- Release：用于构建的优化的库或可执行文件，不包含调试符号。
- RelWithDebInfo：用于构建较少的优化库或可执行文件，包含调试符号。
- MinSizeRel：用于不增加目标代码大小的优化方式，来构建库或可执行文件。
  
指定构建类型的变量`CMAKE_BUILD_TYPE`,例如：
```bash
set(CMAKE_BUILD_TYPE release)
#或
set(CMAKE_BUILD_TYPE release cache STRING "build type" FORCE)
```
1. cmake语言不区分大小写。
2. cache指的是将该设置选项写入cmakecache.txt文件中(build后可在buid文件夹下看到)。写入cache就是下次build的时候直接从cache文件中读取相关设置，从而加快构建速度。`所以如果相关设置有改变，建议删除build目录中生成的相关文件`，不然cmake会直接读取cmakecache文件，从而使得重新设置的选项不生效。
3. string "build type" 就是给该选项设置备注。 
4. FORCE应该是强制写入。

# CMakeLists.txt文件
```bash
cmake_minimum_required(VERSION 3.21.1 FATAL_ERROR)
# project不指定语言，默认c c++
project(buildType04)
set(CMAKE_BUILD_TYPE Debug)
message(STATUS "Build type: ${CMAKE_BUILD_TYPE}")
message(STATUS "C++ flags, Debug configuration: ${CMAKE_CXX_FLAGS_DEBUG}")
message(STATUS "C++ flags, Release configuration: ${CMAKE_CXX_FLAGS_RELEASE}")
message(STATUS "C++ flags, Release configuration with Debug info: ${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
message(STATUS "C++ flags, minimal Release configuration: ${CMAKE_CXX_FLAGS_MINSIZEREL}")
```
## build输出
```
[root part01]# cd buildType04/
[root buildType04]# mkdir -p build&&cd build
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
-- Build type: Debug
-- C++ flags, Debug configuration: -g
-- C++ flags, Release configuration: -O3 -DNDEBUG
-- C++ flags, Release configuration with Debug info: -O2 -g -DNDEBUG
-- C++ flags, minimal Release configuration: -Os -DNDEBUG
-- Configuring done
-- Generating done
-- Build files have been written to: /home/work/CmakeLearning/part01/buildType04/build
```
~~`也可以在cmake构建时的命令行中使用`-D CMAKE_BUILD_TYPE=Release`进行修改设置的值。例如~~

没法从命令行修改
```bash
mkdir -p build&&cd build
cmake -D CMAKE_BUILD_TYPE=Release ..
```
# CMAKE_CONFIGURATION_TYPES 
使用`CMAKE_CONFIGURATION_TYPES`变量对可用配置类型进行调整。
```bash
$ mkdir -p build
$ cd build
$ cmake .. -G "Ninja" -D CMAKE_CONFIGURATION_TYPES="Release;Debug"
$ cmake --build . --config Release
```
结果
```bash
[root build]# cmake .. -G "Ninja" -D CMAKE_CONFIGURATION_TYPES="Release;Debug"
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
-- Build type: Debug
-- C++ flags, Debug configuration: -g
-- C++ flags, Release configuration: -O3 -DNDEBUG
-- C++ flags, Release configuration with Debug info: -O2 -g -DNDEBUG
-- C++ flags, minimal Release configuration: -Os -DNDEBUG
-- Configuring done
-- Generating done
CMake Warning:
  Manually-specified variables were not used by the project:

    CMAKE_CONFIGURATION_TYPES


-- Build files have been written to: /home/work/CmakeLearning/part01/buildType04/build
[root build]# cmake --build . --config Release
ninja: no work to do.
```
ninja: no work to do是因为没有源码文件。