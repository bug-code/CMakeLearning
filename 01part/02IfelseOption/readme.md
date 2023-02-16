@[TOC]
# Cmake流程控制，及选项设置

文件结构如下
```bash
.
├── build
├── CMakeLists.txt
├── readme.md
├── src
│   └── Helloworld.cpp
└── thirdparty
    └── Message
        ├── include
        │   └── Message.hpp
        ├── lib
        │   ├── libMessage.a
        │   └── libMessage.so
        └── src
            └── Message.cpp

7 directories, 7 files
```

## CMakeLists.txt文件
```bash
cmake_minimum_required(VERSION 3.25.1 FATAL_ERROR)
project(IfelseOption LANGUAGES CXX)
option(use_Message_shared "use Message shared lib" 1)
#添加库 .h头文件路径
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message/include)
#添加链接第三方库.so或.a文件的路径
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message/lib)
#生成可执行文件
add_executable(Helloworld ${CMAKE_CURRENT_SOURCE_DIR}/src/Helloworld.cpp)
if(use_Message_shared)
    target_link_libraries(Helloworld libMessage.so) 
    message(STATUS "use Message shared lib")
else()
    target_link_libraries(Helloworld libMessage.a)
    message(STATUS "use Message STATIC lib")
endif()
```
option用于设置默认选项(0==off==OFF, 1==on==ON) ，其中if()else()endif()用于流程控制。


执行以下命令
```bash
[root build]# cmake -D use_Message_shared=0 ..
-- The CXX compiler identification is GNU 10.2.1
-- Detecting CXX compiler ABI info
-- Detecting CXX compiler ABI info - done
-- Check for working CXX compiler: /opt/rh/devtoolset-10/root/usr/bin/c++ - skipped
-- Detecting CXX compile features
-- Detecting CXX compile features - done
-- use Message STATIC lib
-- Configuring done
-- Generating done
-- Build files have been written to: /home/work/CmakeLearning/part01/IfelseOption02/build
[root build]# cmake --build .
[ 50%] Building CXX object CMakeFiles/Helloworld.dir/src/Helloworld.cpp.o
[100%] Linking CXX executable Helloworld
[100%] Built target Helloworld
[root build]# ll
total 52
-rw-r--r-- 1 root root 13009 Dec 29 09:06 CMakeCache.txt
drwxr-xr-x 6 root root  4096 Dec 29 09:06 CMakeFiles
-rw-r--r-- 1 root root  1694 Dec 29 09:06 cmake_install.cmake
-rwxr-xr-x 1 root root 18184 Dec 29 09:06 Helloworld
-rw-r--r-- 1 root root  5490 Dec 29 09:06 Makefile
[root build]# ./Helloworld
This is my very nice message:
Hello, CMake World!
This is my very nice message:
Goodbye, CMake World
```
在 `cmake -D use_Message_shared=0 ..` 命令后输出`-- use Message STATIC lib`说明设置`use_Message_shared=0`成功。

## 选项依赖
在实际工程中，一些编译选项依赖其他选项。则可以使用以下实现设置默认选项值和选项依赖。

```bash
include(CMakeDependentOption)
# second option depends on the value of the first
cmake_dependent_option(
    MAKE_STATIC_LIBRARY "Compile sources into a static library" OFF
    "USE_LIBRARY" ON
    )
# third option depends on the value of the first
cmake_dependent_option(
    MAKE_SHARED_LIBRARY "Compile sources into a shared library" ON
    "USE_LIBRARY" ON
    )
```