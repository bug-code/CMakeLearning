# 超级构建模式

## 超级构建模式的使用

超级构建模式的使用是用来管理和编译外部依赖。当项目需要依赖外部其他库时，可以使用超级构建模式将外部依赖添加进项目中。
并在build时外部依赖会以标准的格式创建目录树，并包含在源项目的build文件夹中。

``````bash

.
├── CMakeLists.txt
└── src
    ├── CMakeLists.txt
    └── hello_world.cpp
1 directory, 3 files
``````
### 子cmake文件

子项目作为一个独立的项目，可单独构建。

``````cmake
cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(SuperBuild LANGUAGES CXX)
add_executable(helloworld hello_world.cpp)

``````

### 主cmake文件


``````cmake

cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(SuperBuild LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 为当前目录和底层目录设置EP_BASE目录属性
set_property(DIRECTORY #为目录设置属性 
             PROPERTY 
                EP_BASE #设置EP_BASE属性ExternalProject_BASH
                ${CMAKE_BINARY_DIR}/subproject)#在build目录下设置子项目文件夹

include(ExternalProject)#导入ExternalProject.cmake模块
#将依赖项作为外部项添加到项目
ExternalProject_Add(HelloWorld #自定义外部项名称
                    SOURCE_DIR
                        ${CMAKE_CURRENT_LIST_DIR}/src #指定外部项的所在位置
                    CMAKE_ARGS # 传递合适的cmake选项到依赖项进行编译
                        -DCMAKE_CXX_COMPILE=${CMAKE_CXX_COMPILER}
                        -DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}
                        -DCMAKE_CXX_EXTENSIONS=${CMAKE_CXX_EXTENSIONS}
                        -DCMAKE_CXX_STANDARD_REQUIRED=${CMAKE_CXX_STANDARD_REQUIRED}
                    CMAKE_CACHE_ARGS #传递编译器标志
                        -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
                    BUILD_ALWAYS #总是重新构建依赖项
                        1
                    INSTALL_COMMAND #安装位置暂无
                        ""
)
``````

### 检索外部项目的属性

检索外部项目的cmake参数
``````cmake
ExternalProject_Get_Property(HelloWorld CMAKE_ARGS)
message(STATUS "CMAKE_ARGS of HelloWorld is: ${CMAKE_ARGS}")

``````

### 超级构建简介
`ExternalProject_Add`命令可以用来添加第三方库，可以将项目分为不同的CMake项目的集合管理。

`ExternalProject_Add`选项：
- Directory: 用于调优源码的结构，并为外部项目构建目录。通过设置EP_BASE目录属性，CMake将按照
以下布局为各个子项目设置所有目录。
    1.TMP_DIR = \<EP_BASE\>/tmp/\<name\>
    2.STAMP_DIR=\<EP_BASE\>/Stamp/<name>
    3.DOWNLOAD_DIR=\<EP_BASE\>Download/\<name\>
    4.SOURCE_DIR=\<EP_BASE\>Source/\<name\>
    5.BINARY_DIR = \<EP_BASE\>/Build/\<name\>
    6.INSTALL_DIR=\<EP_BASE\>/Install/\<name\>

- Download: 外部项目的代码可能需要从在线存储库或资源处下载。
- Update和Patch: 可用于定义如何更新外部项目的源代码或如何应用补丁
- Configure: （CMAKE_ARGS和CMAKE_CACHE_ARGS）默认情况下,cmake会假定外部项目是使用cmake配置的。
- Build:(BUILD_ALWAYS)可用于调整外部项目的实际编译。
- Install: 用于配置应该如何安装外部项目。
- Test:为基于源代码的软件运行测试。


`ExternalProject_Add_Step`: 将命令绑定到项目上。即编译项目时（前或后）执行命令。

`ExternalProject_Add_StepTargets`: 运行将外部项目中的步骤(例如构建或测试步骤)定义为单独的目标

`ExternalProject_Add_StepDependencies`: 外部项目的步骤又是可能依赖与外部目标，该命令用于处理外部依赖。


## 超级构建模式管理依赖库
有时候机器上可能没有所依赖的库，或没有指定版本的库，使用超级构建模式可以在这种情况下，保证cmake不终止配置。
即当cmake检测到系统上没有需要的版本时，通过超级构建方式，从下载链接下载，并配置和安装。

实验目录结构如下：

``````bash
.
├── CMakeLists.txt
├── external
│   └── upstream
│       ├── CMakeLists.txt
│       └── boost
│           └── CMakeLists.txt
└── src
    ├── CMakeLists.txt
    └── path-info.cpp

4 directories, 5 files
``````
其中最终要的是boost文件夹下的CMakeLists.txt 文件。
关键是ExternalProject的使用。

### 超级构建的使用

``````cmake

   include(ExternalProject)
   ExternalProject_Add(boost_external
                       URL #设置下载链接
                           https://sourceforge.net/projects/boost/files/boost/1.61.0/boost_1_61_0.zip
                       # URL_HASH #设置校验
                       #     SHA256=02d420e6908016d4ac74dfc712eec7d9616a7fc0da78b0a1b5b937536b2e01e8
                       DOWNLOAD_NO_PROGRESS
                           1
                       UPDATE_COMMAND
                          ""
                       CONFIGURE_COMMAND #配置命令
                          <SOURCE_DIR>/bootstrap.sh
                          --with-toolset=${_toolset}
                          --prefix=${STAGED_INSTALL_PREFIX}/boost
                          ${_bootstrap_select_libraries}
                       BUILD_COMMAND #构建命令 
                           <SOURCE_DIR>/b2 -q
                           link=shared
                           threading=multi
                           variant=release 
                           toolset=${_toolset}
                           ${_b2_select_libraries}
                       LOG_BUILD
                         1
                       BUILD_IN_SOURCE #说明这是一个内置的构建
                         1

                       INSTALL_COMMAND #安装命令
                         <SOURCE_DIR>/b2 -q install
                         link=shared
                         threading=multi
                         variant=release
                         toolset=${_toolset}
                         ${_b2_select_libraries}
                       LOG_INSTALL #可选
                         1
                       BUILD_BYPRODUCTS
                         "${_build_byproducts}"
                      )
``````
 
在UPDATE_COMMAND中
- \<SOURCE_DIR\>表示下载的依赖库所在位置
- _toolset 为cxx的编译器类型
- STAGED_INSTALL_PREFIX 为主cmake中设置的位置
- _b2_select_libraries 为cmake中设置的依赖组件，如 --with-filesystem

在INSTALL_COMMAND中

- link=shared 表示构建动态依赖库
- threading = multi 表示使用多线程
- variant = release 表示构建release 版本
- _build_byproducts 表示构建库的绝对路径

### 超级构建的其他设置

``````cmake

  # 设置变量以便cmake能查找到
   set(
       BOOST_ROOT ${STAGED_INSTALL_PREFIX}/boost
       CACHE PATH "Path to internally built Boost installation root"
       FORCE
       )
   set(
       BOOST_INCLUDEDIR ${BOOST_ROOT}/include
       CACHE PATH "Path to internally built Boost include directories"
       FORCE
     )
   set(
       BOOST_LIBRARYDIR ${BOOST_ROOT}/lib
       CACHE PATH "Path to internally built Boost library directories"
       FORCE
       )
   #取消本文件中的变量设置 
   unset(_toolset)
   unset(_b2_needed_components)
   unset(_build_byproducts)
   unset(_b2_select_libraries)
   unset(_boostrap_select_libraries)
``````
在通过超级构建系统创建好依赖库之后，还需设置库相关的变量设置，以便find_package能找到库所在位置。
如：库的根目录，库的头文件目录，库的.so所在目录。

然后在主CMakeLists文件中，使用add_subdirectory将该CMakeLists文件包含进来。
例如：


``````cmake
add_subdirectory(external/upstream)
``````

主cmake构建源项目文件时，将依赖项通过超级构建方式添加进来。例如本例中的boost库


``````cmake

include(ExternalProject)
ExternalProject_Add(${PROJECT_NAME}_core
    DEPENDS  
      boost_external #添加项目依赖的boost库,名字为boost库通过cmake构建时自定义的
    SOURCE_DIR  
      ${CMAKE_CURRENT_LIST_DIR}/src #项目源文件目录
    CMAKE_ARGS #添加编译选项
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}
      -DCMAKE_CXX_EXTENSIONS=${CMAKE_CXX_EXTENSIONS}
      -DCMAKE_CXX_STANDARD_REQUIRED=${CMAKE_CXX_STANDARD_REQUIRED}
    CMAKE_CACHE_ARGS
      -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
      #传递cmake查找boost的路径 
      -DCMAKE_INCLUDE_PATH:PATH=${BOOST_INCLUDEDIR} 
      -DCMAKE_LIBRARY_PATH:PATH=${BOOST_LIBRARYDIR}
    BUILD_ALWAYS
      1
    INSTALL_COMMAND
      ""
)
``````

在cmakelist中设置`set(CMAKE_DISABLE_FIND_PACKAGE_Boost ON)` 可以跳过查找本地库，直接执行超级构建。
详见https://cmake.org/cmake/help/v3.5/variable/CMAKE_DISABLE_FIND_PACKAGE_PackageName.html



# 超级构建管理FFTW库

实验目录结构如下所示

``````bash
.
├── CMakeLists.txt
├── external
│   └── upstream
│       ├── CMakeLists.txt
│       └── fftw3
│           └── CMakeLists.txt
└── src
    ├── CMakeLists.txt
    └── fftw_example.c

4 directories, 5 files
``````
## FFTW的CMakeLists
该CMakeLists主要用于查找和管理依赖库。
以FFTW库为例:


``````cmake

find_package(FFTW3 CONFIG QUIET)
if(FFTW3_FOUND)
  add_library(fftw3_external INTERFACE)
else()
    .........
endif()
``````
首先使用find_package查找本地是否安装有对应的所需的依赖库。
如果找到对应的库，则创建一个假的接口库给主cmake的超级构建使用。


``````cmake
  add_library(fftw3_external INTERFACE)
``````
如果没有找到，则使用超级构建在本地安装对应的库。即对应else部分。

``````cmake
  include(ExternalProject)
  ExternalProject_Add(
    fftw3_external
    URL
      http://www.fftw.org/fftw-3.3.10.tar.gz
    # URL_HASH
    #   MD5=8aac833c943d8e90d51b697b27d4384d
    DOWNLOAD_NO_PROGRESS
      1
    UPDATE_COMMAND
      ""
    LOG_CONFIGURE
      1
    LOG_BUILD
      1
    LOG_INSTALL
      1
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=${STAGED_INSTALL_PREFIX}
      -DBUILD_TESTS=OFF
    CMAKE_CACHE_ARGS
      -DCMAKE_C_FLAGS:STRING=$<$<BOOL::WIN32>:-DWITH_OUR_MALLOC>
  )
  include(GNUInstallDirs)
  set(FFTW3_DIR ${STAGED_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/cmake/fftw3
      CACHE PATH "path to internally built FFTW3CONFIG.cmake"
      FORCE
  )
``````
在使用超级构建时, ExternalProject_Add中fftw3_external的名字可以自定义，只要和主CMakeLists
中超级构建使用的超级构建依赖项对应即可。

在超级构建中的重要几个参数：

- 依赖项的名称(例如：fftw3_external)需与主cmakelist超级构建的依赖项对应，名字可自定义。
- URL:下载链接
- UPDATE_COMMAND: 是否需要更新操作，某些库下载下来如果需要更新可以使用该命令，一般可以忽略。
- CMAKE_ARGS: 为安装依赖库所需的编译选项
- CMAKE_CACHE_ARGS: 安装依赖库所需的编译选项，不同的是在这的编译选项可以写入cache文件中保存。
- CONFIGURE_COMMAND: 如上一节所示，为编译前的配置选项。在这可以设置配置选项参数。
- BUILD_COMMAND: 编译命令所需的参数
- INSTALL_COMMAND: 安装命令所需的参数

完成超级构建，还需设置依赖库的安装目录位置,以方便其他cmakelist使用。

其他还能设置的有：依赖库的头文件库目录位置，依赖库的lib库所在目录，依赖库的cmake所在目录，按需设置。
``````cmake
  include(GNUInstallDirs) #添加GNU标准安装目录，用于设置标准的安装目录结构
  set(FFTW3_DIR ${STAGED_INSTALL_PREFIX}/${CMAKE_INSTALL_LIBDIR}/cmake/fftw3
      CACHE PATH "path to internally built FFTW3CONFIG.cmake"
      FORCE
  )
``````

## upstream下的cmakelist
在该cmakelist中只需将需要管理的依赖库目录添加进来即可，如下所示。

``````cmake
add_subdirectory(fftw3)
``````
如果使用超级构建管理了多个依赖库，则在该文件中添加多个该命令即可。
## src下的cmakelist
在该cmakelist中只需安装常规构建方式构建即可。


``````cmake

CMAKE_MINIMUM_REQUIRED(VERSION 3.22.1 FATAL_ERROR)
project(fftw3_example LANGUAGES C)
find_package(FFTW3 CONFIG REQUIRED)
add_executable(fftw3_example fftw_example.c)
``````
## 主cmakelist
在主cmakelist中，首先需要进行以下设置：
- 设置EP_BASE目录属性
- 设置依赖库安装目录,所有依赖库都安装在该目录下。

``````cmake
set_property(DIRECTORY PROPERTY EP_BASE ${CMAKE_BINARY_DIR}/subprojects)
set(STAGED_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/stage)
``````

然后将依赖库cmakelist文件所在目录添加进来。


``````cmake
add_subdirectory(external/upstream)
``````
使用超级构建模式设置依赖项。


``````cmake
include(ExternalProject)
ExternalProject_Add(${PROJECT_NAME}_core
  DEPENDS
    fftw3_external
  SOURCE_DIR
    ${CMAKE_CURRENT_LIST_DIR}/src
  CMAKE_ARGS
    -DFFTW3_DIR=${FFTW3_DIR}
    -DCMAKE_C_STANDARD=${CMAKE_C_STANDARD}
    -DCMAKE_C_EXTENSIONS=${CMAKE_C_EXTENSIONS}
    -DCMAKE_C_STANDARD_REQUIRED=${CMAKE_C_STANDARD_REQUIRED}
  CMAKE_CACHE_ARGS
    -DCMAKE_C_FLAGS:STRING=${CMAKE_C_FLAGS}
    -DCMAKE_PREFIX_PATH:PATH=${CMAKE_PREFIX_PATH}
  BUILD_ALWAYS
    1
  INSTALL_COMMAND
    ""
)
``````
在主cmakelist中的设置与上述fftw节中介绍的cmakelist相似。
区别在于：
- fftw中的超级构建是管理依赖库，在主cmakelist中是为了编译项目源文件
- 需要设置SOURCE_DIR的项目源文件所在目录。
- 需要设置所需依赖库所在的目录文件位置，例如（-DFFTW3_DIR=${FFTW3_DIR}）。其中的FFTW3_DIR需要和fftw的cmakelist
中设置的名字一致。

## 超级构建总结
超级构建步骤：
- 设置依赖库的超级构建,并设置依赖库的头文件目录，lib目录等
- src下的cmake设置按常规构建即可。
- 主cmakelist设置EP_BASE目录属性，设置依赖库安装目录
- 主cmakelist添加依赖库cmake文件所在目录
- 主cmakelist设置项目源文件使用的超级构建的依赖库。


## 使用超级构建模式构建GTest

项目结构如下所示。

``````bash
.
├── CMakeLists.txt
├── external
│   └── upstream
│       ├── CMakeLists.txt
│       └── googleTest
│           └── CMakeLists.txt
└── src
    ├── CMakeLists.txt
    ├── main.cpp
    ├── sum_integers.cpp
    ├── sum_integers.hpp
    └── test.cpp

4 directories, 8 files
``````
### 超级构建GTest

核心代码如下：
``````cmake
  include(ExternalProject)
  ExternalProject_Add(
    GTest_external  #名字可任取，但在后续使用要对应,例如主cmake中的超级构建中的DEPENDS选项
    URL #url只支持http类型链接，不支持git,且下载的类型只支持.tar.gz类型。
        #GIT_REPOSITORY能支持git类型下载链接
       https://github.com/google/googletest/archive/refs/tags/v1.13.0.tar.gz
    UPDATE_COMMAND
      ""
    DOWNLOAD_NO_PROGRESS
      0
    LOG_CONFIGURE
      1
    LOG_BUILD
      1
    LOG_INSTALL
      1
    BUILD_IN_SOURCE
      1
    CMAKE_ARGS 
    #需设置该库的安装路径，安装路径已在主cmake中设置
      -DCMAKE_INSTALL_PREFIX=${STAGED_INSTALL_PREFIX}
      -DGTEST_HAS_PTHREAD=1
      -DGTEST_LINKED_AS_SHARED_LIBRARY=1
      -DGTEST_CREATE_SHARED_LIBRARY=1
    BUILD_ALWAYS
      1
  )
  #设置GNU的标准安装目录
  include(GNUInstallDirs)
  #设置相应的变量，以便cmake能够查找到该库的安装位置
  set(GTest_DIR
        #如果cmake查找不到，build后看一下安装位置下的cmake文件路径，
        #且该变量需cache，不然出了这个文件就找不到该变量了
      ${STAGED_INSTALL_PREFIX}/lib/cmake/GTest/
      CACHE PATH "path to internally built GTESTCONFIG.cmake"
      FORCE
``````
### 主cmake的超级构建
主cmake的关键代码如下：


``````cmake
#设置超级构建属性的目录
set_property(DIRECTORY PROPERTY EP_BASE ${CMAKE_BINARY_DIR}/subprojects)
#设置依赖库的安装路径
set(STAGED_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/stage)
#将依赖库的cmake所在目录添加进来
add_subdirectory(external/upstream)
#导入超级构建包
include(ExternalProject)
#项目超级构建
ExternalProject_Add(
  ${PROJECT_NAME}_core #项目文件名字，任取
  DEPENDS #添加超级构建的依赖项，名字需和超级构建依赖库中的一致
    GTest_external
  SOURCE_DIR #本项目源码所在位置
    ${CMAKE_CURRENT_LIST_DIR}/src
  # LOG_BUILD
  #   1
  CMAKE_ARGS #构建本项目所需使用的编译选项
    -DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}
    -DCMAKE_CXX_EXTENSIONS=${CMAKE_CXX_EXTENSIONS}
    -DCMAKE_CXX_STANDARD_REQUIRED=${CMAKE_CXX_STANDARD_REQUIRED}
    #关键：需添加超级构建依赖库的cmake文件所在位置。
    #例如本例中GTESTCONFIG.cmake所在位置
    -DGTest_DIR=${GTest_DIR}
  CMAKE_CACHE_ARGS
    -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
  BUILD_ALWAYS
    1
  INSTALL_COMMAND
    ""
)
``````

## 使用超级构建支持的项目
项目结构如下：

``````cmake
.
├── CMakeLists.txt
├── external
│   └── upstream
│       ├── CMakeLists.txt
│       └── message
│           └── CMakeLists.txt
└── src
    ├── CMakeLists.txt
    └── use_message.cpp

4 directories, 5 files
`````

### 依赖库的超级构建


``````cmake
  #添加超级构建包
  include(ExternalProject)
  ExternalProject_Add(
    # 该依赖库的名称，名称任取
        message_external
    # git类型的下载链接
        GIT_REPOSITORY
            https://github.com/dev-cafe/message.git
    # git 的branch    
        GIT_TAG
            master
        UPDATE_COMMAND
            ""
        CMAKE_ARGS
    # 该依赖库的安装路径
          -DCMAKE_INSTALL_PREFIX=${STAGED_INSTALL_PREFIX}
          -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE}
          -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
          -DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}
          -DCMAKE_CXX_EXTENSIONS=${CMAKE_CXX_EXTENSIONS}
          -DCMAKE_CXX_STANDARD_REQUIRED=${CMAKE_CXX_STANDARD_REQUIRED}
        CMAKE_CACHE_ARGS
          -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
        TEST_AFTER_INSTALL
            1
        DOWNLOAD_NO_PROGRESS
            1
        LOG_CONFIGURE
            1
        LOG_BUILD
            1
        LOG_INSTALL
            1
  )
# 设置依赖库的cmake所在位置，以便cmake能查找到该库
  set(message_DIR ${DEF_message_DIR}
        CACHE PATH "Path to internally built messageConfig.cmake" FORCE)

``````

使用超级构建的库和使用其他库没有区别，和前几章说的超级构建FFTW和GTest的构建方式一样。
这里只是为了说明使用git类型的下载链接要使用`GIT_REPOSITORY`。

如果测试项都是用Ctest运行测试，则可以使用以下选项
- TEST_AFTER_INSTALL:在安装之后立即运行测试
- TEST_BEFORE_INSTALL: 在安装前运行测试

如果测试项不是使用Ctest进行测试，则可以使用
- TEST_COMMAND : 自定义测试命令进行测试

























