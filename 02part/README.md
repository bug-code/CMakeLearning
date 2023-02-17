@[TOC]
# 检测操作系统
cmake中通过CMAKE_SYSTEM_NAME变量来识别系统类型。
主流操作系统：
- Linux 
- Windows 
- Darwin (即macos)
- AIX (IBM AIX)

例如：
```bash
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
    do something
endif()
```
# 处理平台相关源码
在cpp等源文件中通过宏控制操作系统平台相关源码

例如：
- target_compile_definitions(targetName PUBLIC/INTERFACE/PRIVATE "IS_LINUX")
  - 为特定目标设定宏定义等， 精细度控制

- add_definitions(-DIS_LINUX)
    - 整个CMakeLists.txt项目中都设置宏，精细度小

在源文件中定义
```bash
source.cpp
......
#ifdef IS_WINDOWS
    source code for windows
#elif IS_LINUX
    source code for linux
#elif IS_Darwin
    source code for macos
#endif
......
```
在CMakeLists.txt中定义如下
```bash
....
if(CMAKE_SYSTEM_NAME STREQUAL "Linux")
  target_compile_definitions(helloworld PUBLIC "IS_LINUX")
endif()
if(CMAKE_SYSTEM_NAME STREQUAL "Darwin")
  target_compile_definitions(helloworld PUBLIC "IS_MACOS")
endif()
if(CMAKE_SYSTEM_NAME STREQUAL "Windows")
  target_compile_definitions(helloworld PUBLIC "IS_WINDOWS")
endif()
.....
```
target_compile_definitions()为特定目标进行定义和编译。
例如
```bash
#为源文件helloworld.cpp生成的target hellworld可执行文件定义一个宏IS_LINUX
target_compile_definitions(helloworld PUBLIC "IS_LINUX")
```

# 处理编译器相关源码编译
与编译系统相关的源码一样，为源文件设置宏定义。
- 通过CMAKE_\<LANG\>_COMPILER_ID获取编译器名称, \<LANG>为：
  - CXX
  - C
  - PYTHON
  - 等
- 获取编译器名称后为源文件定义宏
例如：
```bash
# 定义源项目中使用的宏定义 IS_XXX_CXX_COMPILER
target_compile_definitions(HelloWorld PUBLIC "IS_${CMAKE_CXX_COMPILER_ID}_CXX_COMPILER")
```
# 编译处理器相关源码
## 检查cpu是32位还是64位的
  通过cmake系统变量CMAKE_SIZEOF_VOID_P的大小进行判断.
  - CMAKE_SIZEOF_VOID_P==8 为64位cpu
  - 否则为32位cpu
例如:
```bash
CMakeLists.txt
if(CMAKE_SIZEOF_VOID_P EQUAL 8)
  #64位cpu相关cmake设置
else()
  #32位cpu相关cmake设置
endif()
```
## 检测cpu架构
通过cmake的CMAKE_HOST_SYSTEM_PROCESSOR系统变量来识别cpu架构

常见cpu架构有:
  - i386
  - i686
  - x86_64
  - AMD64

例如:
```bash
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
```

`CMAKE_SYSTEM_PROCESSOR`与`CMAKE_HOST_SYSTEM_PROCESSOR`有细微差别.

# 处理 CPU指令相关源码
`cmake_host_system_information` 该cmake指令用于查询系统中的信息.
例如:
```cmake
cmake_host_system_information(RESULT _NUMBER_OF_LOGICAL_CORES  QUERY NUMBER_OF_LOGICAL_CORES)
```
cpu逻辑核心数结果存放在_NUMBER_OF_LOGICAL_CORES中,类似于系统检测, 系统相关, 编译器相关, CPU相关. 获取cpu指令集相关信息后就能在项目中针对不同指令集,包含不同的源文件从而生成适合平台的可执行文件(或库).

tips:
  - 在add_executable()中,可以先不指定源文件
  - 通过检测不同平台的相关信息, 通过cmake if else语句添加对应的源文件.

例如:
```cmake
# add_executable中源文件为空是为了依据检测到的操作系统类型,编译器类型,cpu架构等来添加相应的源文件
add_executable(targetName "")
if( condition )
# 添加源文件
target_sources(targetName PRIVATE relate_source_file)
endif()
# add file folder for target
target_include_directories(ISC_info
  PRIVATE
       ${PROJECT_BINARY_DIR} #当前cmakelists中对应的build文件夹
)
......
#修改并复制一份源文件到另一个位置,比如target_include_directories中指定的build文件夹
configure_file(config.h.in config.h @ONLY)
```
# 案例展示 Eigen3向量化加速项目
处理器的向量功能可以加速程序的执行,例如向量运算. eigen是线性代数C++模板库.

## 设置编译器开启向量化优化

```cmake
#checkCXXCompilerFlag.cmake标准模块文件:
include(CheckCXXCompilerFlag)
#GNU编译器的向量化加速编译选项
check_cxx_compiler_flag("-march=native" _march_native_works)
# intel编译器的向量化加速编译选项
check_cxx_compiler_flag("-xHost" _xhost_works)
#根据获得的值(例如_march_native_works设定编译选项)
list(APPEND flags "-march=native")
# or 
list(APPEND flags "-xHost")

```
- 指示编译器检查处理器，并为当前体系结构生成本机编译优化选项.
- 使用CheckCXXCompilerFlag.cmake模块提供的check_cxx_compiler_flag函数进行编译器标志的检查