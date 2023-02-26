@[TOC]
# find_package的使用
`find_package`正常使用的前提是cmake安装路径中的Module文件夹中有相应的find\<name\>.cmake模块。

cmake中findpackage的查找顺序
1. CMAKE_PREFIX_PATH 安装路径
2. \<package\>_DIR 配置文件路径
3. 如果库安装在非标准位置可以使用-D选项显示指定安装位置
   1. `$ cmake -D CMAKE_PREFIX_PATH=/path/to/lib ..`
   2. `$ cmake -D Eigen3_DIR=<installation-prefix>/share/eigen3/cmake ..`

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
# cmake混合编译（检测BLAS和LAPACK）
BLAS和LAPACK是高效解决矩阵和向量运算的库，这两个库由Fortran语言实现，并在外层使用c语言封装了接口，称为CBLAS和LAPACKE库。

## ubuntu安装BLAS和LAPACK
```bash
apt-get install libblas-dev
apt-get install liblapack-dev
```
## ubuntu安装fortran编译器
```bash
apt-get install gfortran
```
## find
安装完BLAS和LAPACK后，会将FindBLAS.cmake和FindLAPACK.cmake安装在标准位置，以便cmake查找。
- cmake的查找在cmake内部，通过编译调用相关函数的内置小程序，并尝试链接到候选库，如果链接失败，则库不在相应的系统上。

## 编译器处理符号混淆
生成机器码时，编译器会处理符号混淆。但处理符号混淆与编译器有关，不通用。为了检测不同语言是否能混合编译，可以使用cmake内置模块。
例如：验证Fortran和c/c++的混合编译
```cmake
include(FortranCInterface)
FortranCInterface_VERIFY(CXX)
FortranCInterface_HEADER(
  fc_mangle.h
  MACRO_NAMESPACE "FC_"
  SYMBOLS DSCAL DGESV
)
```
该cmake代码将生成fc_mangle.h文件，并包含在c++源文件的头文件中。为了支持c++和Fortran的混合编译，需在LANGUAGE列表中添加CXX 和Fortran。
```cmake
find_package(BLAS REQUIRED)
find_package(LAPACK REQUIRED)
```
- 不同cpu体系结构和并行环境，可能导致findBLAS.cmake无法定位到相关的库。可以从命令行使用-D选项显式的指定库路径。

# 编译使用openMP的项目
openMP是多核处理器上并行标准之一。在多核处理器上，使用openMP实现编程模型的并发，从而使得程序性能提升。
- 使用openMP通常不需要修改或重写现有程序。
- 一旦确定了代码中的性能关键部分，可以使用分析工具，就可以通过预处理指令，指示编译器为这些区域生成可并行的代码
## findOpenMP
```
find_package(OpenMP REQUIRED)
add_executable(targetName sourcefile)
target_link_libraries(targetName
  PUBLIC
      OpenMP::OpenMP_CXX
  )
```
在cmake中链接到openMP库无需指定编译器标志，目录和链接库。因为在OpenMP::OpenMP_CXX均设定好了。
## 打印openMP的编译标志
```cmake
include(CMakePrintHelpers)
cmake_print_properties(
    TARGETS
        OpenMP::OpenMP_CXX
    PROPERTIES
        INTERFACE_COMPILE_OPTIONS
        INTERFACE_INCLUDE_DIRECTORIES
        INTERFACE_LINK_LIBRARIES
)
```
## OpenMP使用不同数量的线程
本例中使用不同数量的线程，以展示openMP带来的加速效果
```bash
env OMP_NUM_THREADS=1 ./example 1000000000
```
![Alt text](https://file%2B.vscode-resource.vscode-cdn.net/c%3A/Users/Yang/AppData/Local/Packages/CanonicalGroupLimited.Ubuntu_79rhkp1fndgsc/LocalState/rootfs/home/CMakeLearning/03findPackage/04findOpenMP/image.jpg?version%3D1677397799785)

# 检测MPI的并行环境
消息传递接口(Message Passing Interface, MPI)
- OpenMP是以共享内存的方式进行并行
- MPI也是分布式系统上并行程序的实际标准
- 通常在计算节点上OpenMP和MPI结合使用

MPI标准的实施包括：
- runtime库
- 头文件和Fortran 90 模块
- 编译器的包装器，用来调用编译器，使用额外的参数来构建MPI库，以处理目录和库
  - 包装器mpic++/mpicc/mpicxx用于c++
  - mpicc用于c
  - mpifort用于Fortran
- 启动MPI:启动程序，以编译代码的并行执行
  - 启动命令：mpirun、mpiexec和orterun
## mpi安装
```bash
sudo apt-get update
sudo apt-get install mpi-default-dev mpi-default-bin build-essential
#确认是否安装成功
mpiexec --version
#编译MPI程序
mpicc -o program program.c
#运行MPI程序
mpiexec -n <num_processes> ./program
```
## findMPI
查找MPI实现：库，头文件、编译器包装器和启动器
```cmake
find_package(MPI REQUIRED)
```
链接到MPI,获取链接标志、头文件和库
```cmake
add_executable(hello-mpi hello-mpi.cpp)
target_link_libraries(hello-mpi
  PUBLIC
       MPI::MPI_CXX
)
```
## MPI库编译器的封装
编译包装器是对MPI库编译器的封装。底层实现中，将调用相同的编译器，并使用额外的参数(头文件，库，路径)来扩充
- 查看包装器编译和链接源文件使用的标志
  ```bash
  mpicxx --showme:compile
  ```
- 查看链接器标志
  ```bash
  mpicxx --showme:link
  ```

# find Eigen
**示例：使用OpenMP并行化，将部分计算交由BLAS库**
Eigen为纯头文件C++库，使用模板编程提供接口。
矩阵和向量的计算：
- 在编译时进行数据类型检查，以确保兼容所有维度的矩阵
- 密集和稀疏矩阵预算可使用模板进行高效实现
- Eigen 3.3版本后可以链接到BLAS和LAPACK库中，将某些计算卸载BLAS和LAPACK进行计算
  
## findEigen
**查找Eigen库**
```cmake
find_package(Eigen3 REQUIRED CONFIG)
```
**如果找到打印状态信息，使用Eigen3::Eigen这个import target**
```cmake
if(TARGET Eigen3::Eigen)
  message(STATUS "Eigen3 v${EIGEN3_VERSION_STRING} found in ${EIGEN3_INCLUDE_DIR}")
endif()
``` 
**如果找到BLAS，将计算卸载到BLAS库**
```cmake
if(BLAS_FOUND)
  target_compile_definitions(linear-algebra
    PRIVATE
        EIGEN_USE_BLAS
    )
  target_link_libraries(linear-algebra
    PUBLIC
        ${BLAS_LIBRARIES}
    )
endif()
```
**和OpenMP一样，链接到Eigen3::Eigen以设置必要的compiler symbol和link flag**
```cmake
target_link_libraries(linear-algebra
  PUBLIC
    Eigen3::Eigen
    OpenMP::OpenMP_CXX
)
```
# find Boost
Boost是一组C++通用库。在现代C++项目中，Boost库有些功能不可或缺。Boost库可以跨平台使用。

- Boost由很多不同的库组成，这些库能独立使用
- 在cmake中Boost被视为这些独立库的集合，这些独立库称为Boost库的组件

**安装Boost**
```bash
apt-get install libboost-all-dev
```

**查找Boost库组件** 
```cmake
find_package(Boost 1.54 REQUIRED COMPONENTS filesystem)
```
**链接Boost组件**
```cmake
target_link_libraries(path-info
  PUBLIC
      Boost::filesystem
)
```
## cmake查找Boost
- 通过cmake查找的库，cmake将自动设置包含目录并调整编译和链接标志。
- 如果Boost库安装在非标准位置，可以通过设置`BOOST_ROOT`变量传递Boost安装的根目录，以便cmake搜索
  - `$ cmake -D BOOST_ROOT=/custom/boost`
- 或者同时传递包含头文件的`BOOST_INCLUDEDIR`变量和库目录的`BOOST_LIBRARYDIR`
  - `$ cmake -D BOOST_INCLUDEDIR=/custom/boost/include -DBOOST_LIBRARYDIR=/custom/boost/lib`


# 自定义检测外部库
检测外部库的便捷方法：
- 使用CMake自带的find-module
- 使用\<package\>Config.cmake, \<package\>ConfigVersion.cmake和\<package\>Targets.cmake。这些文件由软件商提供，并与软件包一起安装在标准位置的cmake文件夹下。
  
当某个库既没有find-module的查找模块，也软件商也不提供打包的cmake文件。
- 使用pkg-config程序，来找系统上的包。这些依赖与软件供应商提供.pc配置文件，其中有关于发行包的元数据
- 自己写find-package模块
## 使用pkg-config查找库
```cmake
find_package(PkgConfig REQUIRED QUIET)#QUIET找不到库才报错
```
### 搜索.pc配置文件
通过使用PkgConfig库的`pkg_search_module`函数搜索附带 包配置.pc文件的库或程序。以ZeroMQ为例
```cmake
pkg_search_module(
  ZeroMQ
  REQUIRED
      libzeromq libzmq lib0mq
  IMPORTED_TARGET
  )
```
其中libzeromq libzmq lib0mq是ZeroMQ库在不同操作系统和包管理器中的不同名称。如此设置可以根据操作系统和包管理器的统统，为同一个包选择同一个名称。
### cmake函数
当找到pkg-config时, CMake需要提供两个函数，来封装这个程序提供的功能:
- pkg_check_modules，查找传递列表中的所有模块(库和/或程序)
- pkg_search_module，要在传递的列表中找到第一个工作模块

### 链接到库
```cmake
target_link_libraries(targetName PkgConfig::ZeroMQ)
```


