# 语言混合项目

## 使用C/C++库构建Fortran项目

使用C系统库和自定义C代码封装Fortran项目，提升Fortran项目在不同操作系统的通用性。

``````bash
Fortran可执行文件
    |
Fortran项目库
    |
C系统库
    |
操作系统

``````



示例项目结构如下所示：


``````cmake
.
├── CMakeLists.txt
└── src
    ├── CMakeLists.txt
    ├── bt-randomgen-example.f90
    ├── interfaces
    │   ├── CMakeLists.txt
    │   ├── interface_backtrace.f90
    │   ├── interface_randomgen.f90
    │   └── randomgen.c
    └── utils
        ├── CMakeLists.txt
        └── util_strings.f90

3 directories, 9 files
``````
### interfaces模块
interfaces文件夹使用C系统库和自定义C代码封装Fortran项目，生成一个动态库。
该目录下的CMakeLists文件如下所示：


``````cmake
#添加FortranCInterface.cmake模块
include(FortranCInterface)
#验证C和Fortran编译器可以正确的交互
FortranCInterface_VERIFY()
#查找Backtrace系统库
find_package(Backtrace REQUIRED)
#创建共享库，包含该目录下的源码文件
add_library(bt-randomgen-warp SHARED "")
target_sources(bt-randomgen-warp PRIVATE interface_backtrace.f90
                                         interface_randomgen.f90 randomgen.c)
#bt-randomgen-warp库链接到Backtrace系统库
target_link_libraries(bt-randomgen-warp PUBLIC ${Backtrace_LIBRARIES})
``````
### utils

将该目录下的源文件生成一个动态库。
``````cmake
add_library(utils SHARED util_strings.f90)
``````
### src模块


``````cmake
#添加子目录，生成动态库
add_subdirectory(interfaces)
add_subdirectory(utils)
#生成可执行文件
add_executable(bt-randomgen-example bt-randomgen-example.f90)
#可执行文件链接到两个动态库
target_link_libraries(bt-randomgen-example
    PRIVATE
      bt-randomgen-warp
      utils
)  
``````
### 主cmake文件

``````cmake
cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(00CXXBUILDFORTRAN LANGUAGES Fortran C)
#设置生成的动态库和静态库保存在build目录下的lib目录下
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
# 设置生成的可执行文件保存在bin目录下
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
# Fortran编译模块保存在modules目录下
set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/modules)
#添加src的子目录
add_subdirectory(src)
``````
### 总结

cmake可以使用不同语言的源文件创建库。
- cmake能通过列出的源文件中获取目标文件，并识别要使用哪个编译器
- cmake能选择适当的链接器，以便构建库或可执行文件

cmake通过`project`命令时使用参数`LANGUAGES`指定，cmake会检测系统上给定的语言编译器。当使用
源文件列表添加目标时，cmake将根据文件扩展名选择适当的编译器。

如果cmake无法识别扩展名，可以在源文件属性中告诉cmake在特定的源文件上使用哪种编译器。如下所示：


``````cmake
et_source_files_properties(my_source_file.axx
  PROPERTIES
        LANGUAGE CXX
) 
``````
cmake确定目标的链接语言方式。
对于不混合的编程语言的目标：
- 通过生成目标文件的编译命令调用链接器即可

对于混合了多个语言的目标：
- 则根据在语言混合中，优先级最高的语言来选择链接器语言
- C++ > Fortran > C

可以通过目标相应的LINK_LANGUAGE属性，强制cmake为目标使用特定的链接器语言。如下所示

``````cmake
et_target_properties(my_target
  PROPERTIES
        LINKER_LANGUAGE Fortran
)
``````


## 使用Fortran库构建C/C++项目
项目结构如下所示


``````bash
.
├── CMakeLists.txt
├── external
│   └── upstream
│       ├── CMakeLists.txt
│       └── LAPACK
│           └── CMakeLists.txt
└── src
    ├── CMakeLists.txt
    ├── linear-algebra.cpp
    └── math
        ├── CMakeLists.txt
        ├── CxxBLAS.cpp
        ├── CxxBLAS.hpp
        ├── CxxLAPACK.cpp
        └── CxxLAPACK.hpp

5 directories, 10 files
``````

### 超级构建外部库LAPACK

LAPACK 库包含BLAS库，所有只要超级构建lapack库即可。

LAPACK目录下的cmake代码如下：


``````cmake
#先查找外部库是否存在
find_package(LAPACK)
if(LAPACK_FOUND)
  #如果存在则设置个假接口库
  add_library(LAPACK_external INTERFACE)
else()
  message(NOTICE "no suitable lapack, Downloading and build")
  #不存在，则进行超级构建
  include(ExternalProject)
  ExternalProject_Add(
  #设置让项目使用的外部库名称
    LAPACK_external
    #设置git类型下载链接
    GIT_REPOSITORY https://github.com/Reference-LAPACK/lapack.git
    GIT_TAG v3.11.0
    UPDATE_COMMAND ""
    DOWNLOAD_NO_PROGRESS 1
    #设置lapack库的安装位置 STAGED_INSTALL_PREFIX在主CMakeLists设置
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${STAGED_INSTALL_PREFIX}
    BUILD_ALWAYS 1)
  #设置GNU格式的标准安装位置
  include(GNUInstallDirs)
  #设置lapack的cmaek查找目录
  set(LAPACK_DIR
      ${STAGED_INSTALL_PREFIX}/lib/cmake
      CACHE PATH "path to internally built LAPACKCONFIG.cmake" FORCE)
  #设置lapack库的位置
  set(LAPACK_LIBRARIES
      ${STAGED_INSTALL_PREFIX}/lib/liblapack.a
      CACHE PATH "PATH to internally lib" FORCE)
  #设置blas库的位置
  set(BLAS_LIBRARIES
      ${STAGED_INSTALL_PREFIX}/lib/libblas.a
      CACHE PATH "path to internally built library" FORCE)
endif()

``````

### upstream的cmake
该CMakeLists只需将路径下的目录添加进来即可。


``````cmake
add_subdirectory(LAPACK)
``````

### 项目库构建
math库使用的是C++和Fortran的混合编译。CMakeLists如下：


``````cmake
#直接使用超级构建的外部库，如同安装在本地一样使用
find_package(LAPACK REQUIRED)
#弃用Fortran语言
enable_language(Fortran)
#包含Fortran接口模块
include(FortranCInterface)
#检查CXX编译器和Fortran编译器的兼容性
FortranCInterface_VERIFY(CXX)
#Fortran生成一个接口头文件
FortranCInterface_HEADER(fc_mangle.h MACRO_NAMESPACE "FC_" SYMBOLS DSCAL DGESV)
add_library(math "")
target_sources(math PRIVATE CxxBLAS.cpp CxxLAPACK.cpp)
target_include_directories(math PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}
                                       ${CMAKE_CURRENT_BINARY_DIR})
target_link_libraries(math PUBLIC ${LAPACK_LIBRARIES} ${BLAS_LIBRARIES}
                                  gfortran)
``````

### 生成可执行程序


``````cmake
add_subdirectory(math)
add_executable(linear-algebra "")
target_sources(linear-algebra PRIVATE linear-algebra.cpp)
target_link_libraries(linear-algebra PRIVATE math)
``````
### 主CMakeLists
``````cmake
cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(01FortranBuildCXX LANGUAGES CXX C Fortran)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
list(APPEND CMAKE_CXX_FLAGS "-Wno-dev")
#为目录设置超级构建属性
set_property(DIRECTORY PROPERTY EP_BASE ${CMAKE_BINARY_DIR}/subprojects)
#设置构建库的安装位置
set(STAGED_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/stage)
#设置GNU格式的标准安装路径
include(GNUInstallDirs)
#设置静态库和动态库的位置
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
#设置可执行文件生成位置
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})
#设置生成的模块保存位置
set(CMAKE_Fortran_MODULE_DIRECTORY ${PROJECT_BINARY_DIR}/modules)

add_subdirectory(external/upstream)
#使用超级构建构建整个项目
include(ExternalProject)
ExternalProject_Add(
  ${PROJECT_NAME}_core
  DEPENDS LAPACK_external 
  SOURCE_DIR ${CMAKE_CURRENT_LIST_DIR}/src
  CMAKE_ARGS -DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}
             -DCMAKE_CXX_EXTENSIONS=${CMAKE_CXX_EXTENSIONS}
             -DCMAKE_CXX_STANDARD_REQUIRED=${CMAKE_CXX_STANDARD_REQUIRED}
             -DLAPACK_DIR=${LAPACK_DIR}
             -DBLAS_LIBRARIES=${BLAS_LIBRARIES}
             -DLAPACK_LIBRARIES=${LAPACK_LIBRARIES}
  CMAKE_CACHE_ARGS -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
  BUILD_ALWAYS 1
  INSTALL_COMMAND "")
``````

## Cython库构建

项目结构如下：
``````bash
.
├── CMakeLists.txt
├── account.cpp
├── account.hpp
├── account.pyx
├── cmake-cython
│   ├── FindCython.cmake
│   └── UseCython.cmake
└── test.py

1 directory, 7 files
``````
### cmake构建

``````cmake
cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(recipe-03 LANGUAGES CXX)
#设置  C++ 标准
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
#设置构建模式
if(NOT CMAKE_BUILD_TYPE)
      set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

find_package(PythonInterp REQUIRED)

# cmake 追加cython查找模块
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake-cython)
# 添加UseCython模块
include(UseCython)
# 设置源文件属性，CYTHON_IS_CXX源文件属性设置为TRUE，以便cython_add_module函数知道如何将pyx作为C++文件进行编译
set_source_files_properties(account.pyx PROPERTIES CYTHON_IS_CXX TRUE)
# 创建Cython模块
cython_add_module(account account.pyx account.cpp)
# 添加头文件
target_include_directories(account
    PRIVATE
          ${CMAKE_CURRENT_SOURCE_DIR}
)

# 启用测试
enable_testing()
# define test
add_test(
    NAME
      python_test
    COMMAND
      ${CMAKE_COMMAND} -E env ACCOUNT_MODULE_PATH=$<TARGET_FILE_DIR:account>
      #指定测试文件路径
      ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/test.py
)
``````
## 使用boost库连接python与C++
boost库提供python的接口，可以使用boost来代替Cython,连接python和c++库。
项目结构如下

``````cmake
.
├── CMakeLists.txt
├── account.cpp
├── account.hpp
└── test.py

0 directories, 4 files
``````
### 查找boost库版本
因为通过系统的boost库去连接python和c++库，Boost.python组件依赖boost和python版本，所以先查找这两个库的版本。

``````cmake

# 查找python解释器
find_package(PythonInterp REQUIRED)
# 查找python对应的库版本
find_package(PythonLibs ${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR} EXACT REQUIRED)
# 设置查找可能的python版本变量
list(
  APPEND _components
        python${PYTHON_VERSION_MAJOR}${PYTHON_VERSION_MINOR}
        python${PYTHON_VERSION_MAJOR}
        python
)
# 设置 boost.python库版本是否找到
set(_boost_component_found "")
foreach(_component IN ITEMS ${_components})
    find_package(Boost COMPONENTS ${_component})
    if(Boost_FOUND)
        set(_boost_component_found ${_component})
        break()
    endif()
endforeach()

if(_boost_component_found STREQUAL "")
    message(FATAL_ERROR "No matching Boost.Python component found")
``````

### 定义Python模块及其依赖项


``````cmake

# 创建python模块
add_library(account
    MODULE
      account.cpp
)
# 链接到boost.python和python库
target_link_libraries(account
    PUBLIC
      Boost::${_boost_component_found}
      ${PYTHON_LIBRARIES}
)
# 添加python头文件
target_include_directories(account
                          PRIVATE
                                ${PYTHON_INCLUDE_DIRS}
)

# 让cmake生成的库不包含lib前缀
set_target_properties(account
                      PROPERTIES
                      PREFIX ""
)

if(WIN32)
# python will not import dll but expects pyd
  set_target_properties(account
                        PROPERTIES
                        SUFFIX ".pyd"
  )
``````

### python和c++ 使用boost库链接的方式


``````c++
#pragma once
#define BOOST_PYTHON_STATIC_LIB
#include <boost/python.hpp>
class Account {
public:
  Account();
  ~Account();
  void deposit(const double amount);
  void withdraw(const double amount);
  double get_balance() const;

private:
  double balance;
};
namespace py = boost::python;
BOOST_PYTHON_MODULE(account) {
  py::class_<Account>("Account")
      .def("deposit", &Account::deposit)
      .def("withdraw", &Account::withdraw)
      .def("get_balance", &Account::get_balance);
}
``````
### 总结
boost.python，提供了另一种方式实现链接python和c++语言,代替了cython连接

## 使用pybind11连接python和cxx语言
pybind11的功能和使用与Boost.Python非常类似。pybind11是一个更轻量级的依赖——不过需要编译器支持C++11。

通过cmake的FetchContent接口，将pybind11构建到项目中。

项目结构如下所示：


``````bash
.
├── CMakeLists.txt
└── account
    ├── CMakeLists.txt
    ├── account.cpp
    ├── account.hpp
    └── test.py

1 directory, 5 files
``````
### 使用pybind11构建项目

``````cmake
# 通过FetchContent获取pybind11组件
include(FetchContent)
FetchContent_Declare(
    pybind11_sources
    GIT_REPOSITORY https://github.com/pybind/pybind11.git
    GIT_TAG v2.2
)
#获取pybind11组件的属性
FetchContent_GetProperties(pybind11_sources)
# 判断pybind11组件是否可用
if(NOT pybind11_sources_POPULATED)
  FetchContent_Populate(pybind11_sources)
  
  add_subdirectory(
      ${pybind11_sources_SOURCE_DIR}
      ${pybind11_sources_BINARY_DIR}
  )
endif()
# 生成库文件
add_library(account
    MODULE
        account.cpp
)
#添加pybind11组件模块,
#导入PYBIND11_MODULE解释库，
target_link_libraries(account
    PUBLIC
      pybind11::module
)
# 设置生成的库文件前后缀  
set_target_properties(account
    PROPERTIES
    PREFIX "${PYTHON_MODULE_PREFIX}"
    SUFFIX "${PYTHON_MODULE_EXTENSION}"
）
``````
### 主cmake设置
主cmake中添加子目录


````````cmake
add_subdirectory(account)
````````
## 使用Python CFFI混合C ， C++ Fortran和Python
python和C能通过CFFI函数接口进行连接，由于C是通用语言，大多数编程语言都能够和C接口进行通信，所以python CFFI是
将python和大量语言结合在一起的工具。
python CFFI的特性：生成简单 且非侵入性的C接口。既不限制语言特性中的Python层，也不会对C层以下的代码有任何限制。

文件结构如下所示：

``````bash
.
├── CMakeLists.txt
└── account
    ├── CMakeLists.txt
    ├── __init__.py
    ├── account.h
    ├── implementation
    │   ├── c_cpp_interface.cpp
    │   ├── cpp_implementation.cpp
    │   └── cpp_implementation.hpp
    └── test.py

2 directories, 8 files

``````
调用结构：python-->C--->C++
cpp_implementation.cpp和cpp_implementation.hpp是用于生成c++库，
c_cpp_interface.cpp是用于连接c和c++库。
__init__.py是用于连接python和c。
至此，即可使用python来调用C++库，c作为两种语言的连接语言。

### account下的CMakeLists

``````cmake
add_library(account SHARED implementation/c_cpp_interface.cpp
                           implementation/cpp_implementation.cpp)
target_include_directories(account PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}
                                           ${CMAKE_CURRENT_BINARY_DIR})
##导出一个可移植的头文件
include(GenerateExportHeader)
generate_export_header(account BASE_NAME account)
``````
其中
``````cmake
include(GenerateExportHeader)
generate_export_header(account BASE_NAME account)
``````
用于导出一个c可用的头文件`account_export.h`，在`account.h`中使用。
`account_export.h`头文件定义了接口函数的可见性,其中包含了`ACCOUNT_API`的定义，并确保这是一种可移植的方式完成的。
至此完成c与c++语言的连接。python与c的连接由`__init__.py`文件完成。主要讲述CMake的使用，
并不涉及如何连接多种语言的连接，因此不在此展开。

### 主CMakeLists
``````cmake

# define minimum cmake version
cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
# project name and supported language
project(recipe-06 LANGUAGES CXX)
# require C++11
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
# 设生成库的安装位置，GNU标准
include(GNUInstallDirs)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY
${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
# interface and sources
add_subdirectory(account)
# turn on testing
enable_testing()
# require python
find_package(PythonInterp REQUIRED)
# define test
add_test(
       NAME
          python_test
       COMMAND
       # 设置python模块的位置
       ${CMAKE_COMMAND} -E env ACCOUNT_MODULE_PATH=${CMAKE_CURRENT_SOURCE_DIR}
       #设置库的头文件位置
       ACCOUNT_HEADER_FILE=${CMAKE_CURRENT_SOURCE_DIR}/account/account.h
       #设置库位置
       ACCOUNT_LIBRARY_FILE=$<TARGET_FILE:account>
       #执行测试程序。
       ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/account/test.py
)
``````
### 总结
多语言混合项目的关键在于如何编写多语言的连接程序，cmake部分倒没有很重要。
应当使用GNU的标准安装路径，使项目更规范。

