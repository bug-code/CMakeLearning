@[TOC]
# find_package的使用
`find_package`正常使用的前提是cmake安装路径中的Module文件夹中有相应的find\<name\>.cmake模块。

`find_package`用于查找和设置cmake模块的包。`Find<name>.cmake`cmake模块，例如`FindPython2.cmake`模块，就是cmake用于查找本机中系统标准位置的python2库。`find_package`命令查找到模块后会设置一些有用的系统变量，可以在`find_package`命令后中使用这些变量。
例如：查找python解释器
```bash
find_package(PythonInterp REQUIRED)
#执行python命令
execute_process(
  COMMAND
      ${PYTHON_EXECUTABLE} "-c" "print('Hello, world!')"
  RESULT_VARIABLE _status
  OUTPUT_VARIABLE _hello_world
  ERROR_QUIET
  OUTPUT_STRIP_TRAILING_WHITESPACE
  )
#打印Python命令返回值和输出
message(STATUS "RESULT_VARIABLE is: ${_status}")
message(STATUS "OUTPUT_VARIABLE is: ${_hello_world}")
```
查找到python解释器后，cmake会设置python解释器相关的系统变量的值：
- PYTHONINTERP_FOUND：是否找到解释器
- PYTHON_EXECUTABLE：Python解释器到可执行文件的路径
- PYTHON_VERSION_STRING：Python解释器的完整版本信息
- PYTHON_VERSION_MAJOR：Python解释器的主要版本号
- PYTHON_VERSION_MINOR ：Python解释器的次要版本号
- PYTHON_VERSION_PATCH：Python解释器的补丁版本号

## find_package其他
find_package可以指定查找版本等其他功能.
例如：
```bash
#查找python3.9版本，REQUIRED必须查找到该包，否则报错
find_package(PythonInterp 3.9 REQUIRED)
```
如果包未安装在系统标准位置，可以在命令行或CMakeLists.txt中指定。
```bash
$ cmake -D PYTHON_EXECUTABLE=/custom/location/python ..
或
CMakeLists.txt中
set(PYTHON_EXECUTABLE "/custom/location/python")
```
查找find\<name\>.cmake会设置哪些系统变量以供使用可以查看https://github.com/Kitware/CMake/tree/master/Modules 

中的cmake模块源码。

## 打印变量的helper模块
```bash
include(CMakePrintHelpers)
cmake_print_variables(_status _hello_world)
```
# 检测python库
将python和其他语言例如c c++一起使用有两种方法。
- 一种是通过swig，cpython等胶水语言，将python翻译成c，再链接到c库，生成二进制可执行文件。
- 一种是直接将python解释器嵌入到c或c++程序中。

两种方法须具备以下条件：
- Python解释器的工作版本
- Python头文件Python.h的可用性
- Python运行时库libpython

## 查找python解释器
```cmake
find_package(PythonInterp REQUIRED)
```  
## 查找python头文件和库模块
```cmake
find_package(PythonLibs ${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR} EXACT REQUIRED)
```
## 项目添加python头文件
```cmake
target_include_directories(targetName
  PRIVATE
      ${PYTHON_INCLUDE_DIRS}
    )
```
## 项目链接到python库
```cmake
target_link_libraries(hello-embedded-python
  PRIVATE
      ${PYTHON_LIBRARIES}
    )
```
## python部件版本须保持一致
须确保可执行文件、头文件和库版本须保持一致，否则运行时可能导致程序崩溃。
```cmake
find_package(PythonInterp REQUIRED)
#设定pythonLibs和python解释器版本一致。
#EXACT用以限制cmake检测特定的版本
find_package(PythonLibs ${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR} EXACT REQUIRED)
```
在`find_package(PythonInterp REQUIRED)`后，将查找`FindPythonInterp.cmake`模块，该模块将设置以下等cmake系统变量。
- PYTHON_INCLUDE_DIRS python头文件路径
- PYTHON_LIBRARIES python库路径
- PYTHON_VERSION_MAJOR python版本，例如python3.9 中该变量为3
- PYTHON_VERSION_MINOR python版本，例如python3.9 中该变量为9
如果python不是安装在标准位置，则须手动set以上变量。
**精确检测python版本**
```cmake
find_package(PythonInterp REQUIRED)
#设定pythonLibs和python解释器版本一致。
#EXACT用以限制cmake检测特定的版本
#例如python版本为3.9.1则，PYTHON_VERSION_STRING的值为3.9.1
find_package(PythonLibs ${PYTHON_VERSION_STRING} EXACT REQUIRED)
```
## 不等价
```cmake
find_package(Python COMPONENTS Development REQUIRED)
#和
find_package(PythonLibs REQUIRED) 不等价 

#也不能以下方式使用
find_package(Python COMPONENTS PythonLibs REQUIRED)
#或
find_package(Python COMPONENTS PythonInterp REQUIRED)
```
# 检测python模块和包
## 用python脚本的方式检测numpy
```cmake
execute_process(
  COMMAND
      ${PYTHON_EXECUTABLE} "-c" "import re, numpy; print(re.compile('/__init__.py.*').sub('',numpy.__file__))"
  #numpy是否可用，可用为0
  RESULT_VARIABLE _numpy_status
  #numpy安装位置
  OUTPUT_VARIABLE _numpy_location
  ERROR_QUIET
  OUTPUT_STRIP_TRAILING_WHITESPACE
  )
#用python脚本方式检测numpy版本
execute_process(
  COMMAND
      ${PYTHON_EXECUTABLE} "-c" "import numpy; print(numpy.__version__)"
  #numpy版本变量
  OUTPUT_VARIABLE _numpy_version
  ERROR_QUIET
  OUTPUT_STRIP_TRAILING_WHITESPACE
  )
```
## 通过cmake包FindPackageHandleStandardArgs设置NumPy_FOUND变量和输出信息
```cmake
## 更具设定的Numpy参数(REQUIRED_VARS)，查找NumPy，并将其版本传递给##VERSION_VAR
include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(NumPy
  FOUND_VAR NumPy_FOUND
  REQUIRED_VARS NumPy
  VERSION_VAR _numpy_version
  )
```
## 要使C++可执行程序能和python一起执行，须确保在build中有该源文件，并一起编译
```cmake
add_custom_command(
  OUTPUT
      ${CMAKE_CURRENT_BINARY_DIR}/use_numpy.py
  COMMAND
      ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_SOURCE_DIR}/use_numpy.py
      ${CMAKE_CURRENT_BINARY_DIR}/use_numpy.py
  DEPENDS
      ${CMAKE_CURRENT_SOURCE_DIR}/use_numpy.py
  )
# make sure building pure-embedding triggers the above custom command
target_sources(pure-embedding
  PRIVATE
      ${CMAKE_CURRENT_BINARY_DIR}/use_numpy.py
  )
```
## execute_process命令
作为子进程执行若干个命令，可以执行任何操作，并使用其结果检测系统配置
- RESULT_VARIABLE 子进程执行结果
- OUTPUT_VARIABLE 管道标准输出，比如print的内容
- ERROR_VARIABLE 标准错误的内容

## find_package_handle_standard_args包
提供了用于处理和查找相关程序和库的标准工具。
- REQUIRED 表示必须，否则报错
- EXACT 精确匹配

## 查看find_package设定了哪些变量
```cmake 
#必须紧跟在find_package命令后
get_cmake_property(_variableNames VARIABLES)
foreach (_variableName ${_variableNames})
    message(STATUS "${_variableName}=${${_variableName}}")
endforeach()
```