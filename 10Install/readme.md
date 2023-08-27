# 编写安装程序

## 安装项目
编写库的安装和依赖该库的可执行文件的安装。
项目结构如下所示：

``````bash
.
├── CMakeLists.txt
├── src
│   └── Helloworld.cpp
└── thirdparty
    ├── CMakeLists.txt
    └── Message
        ├── CMakeLists.txt
        ├── include
        │   └── Message.hpp
        └── src
            └── Message.cpp

5 directories, 6 files
``````

### 主CMakeLists.txt设置GNU标准安装位置

``````cmake

# 设置GNU标准安装路径
include(GNUInstallDirs)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY
    ${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY
    ${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY
    ${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})

# 配置新的非cmake系统变量设置安装位置
set(INSTALL_LIBDIR
    ${CMAKE_INSTALL_LIBDIR}
    CACHE PATH "Installation directory for libraries")
set(INSTALL_BINDIR
    ${CMAKE_INSTALL_BINDIR}
    CACHE PATH "Installation directory for executables")
set(INSTALL_INCLUDEDIR
    ${CMAKE_INSTALL_INCLUDEDIR}
    CACHE PATH "Installation directory for header files")

set(DEF_INSTALL_CMAKEDIR share/cmake/${PROJECT_NAME})

set(INSTALL_CMAKEDIR
    ${DEF_INSTALL_CMAKEDIR}
    CACHE PATH "Installation directory for CMake files")

# 报告组件安装位置 Report to user
foreach(p LIB BIN INCLUDE CMAKE)
  file(TO_NATIVE_PATH ${CMAKE_INSTALL_PREFIX}/${INSTALL_${p}DIR} _path)
  message(STATUS "Installing ${p} components to ${_path}")
  unset(_path)
endforeach()
``````
以上代码可通用，其中用户可通过"-DCMAKE_INSTALL_PREFIX="设置自定义的安装位置。
以上将项目设置为GNU的标准安装位置。

### Message下的CMakeLists
先介绍Message库的CMakeLists。

``````cmake
set(Message_src ${CMAKE_CURRENT_LIST_DIR}/src/Message.cpp)
add_library(Message SHARED ${Message_src})
set(Message_include ${CMAKE_CURRENT_LIST_DIR}/include/)
target_include_directories(Message PUBLIC ${Message_include})

set_target_properties(
  Message
  PROPERTIES 
    #设置生成位置无关代码
    POSITION_INDEPENDENT_CODE 1
    #告诉cmake库的名字为Message
    OUTPUT_NAME "Message"
    #设置当以debug模式构建时，添加后缀_d
    DEBUG_POSTFIX "_d"
    #设置头文件列表，声明提供的API函数
    PUBLIC_HEADER ${Message_include}/Message.hpp
)
install(
    TARGETS
      Message
    #设置静态库安装位置，及其所属的components
    ARCHIVE
      DESTINATION ${INSTALL_LIBDIR}
      COMPONENT lib
    #设置可执行的文件安装位置
    RUNTIME
      DESTINATION ${INSTALL_BINDIR}
      COMPONENT bin
    #设置动态库的安装位置
    LIBRARY
      DESTINATION ${INSTALL_LIBDIR}
      COMPONENT lib
    #设置头文件安装位置
    PUBLIC_HEADER
      DESTINATION ${INSTALL_INCLUDEDIR}/message
      COMPONENT dev
)
``````
其中最重要的两条语句为`set_target_properties`和`install`。
在`install`命令中，`COMPONENT`用于设置其所属部件。
当只需安装部分是，可以自定义设置，如下所示：


``````bash
cmake -D COMPONENT=lib -P cmake_install.cmake
``````
以上的安装位置会被cmake解释为相对于`CMAKE_INSTALL_PREFIX`的相对位置
### 设置RPATH（(runtime path 运行时路径）
在主CMakeLists中设置RPATH,


``````cmake
#设置可执行文件的 RPATH
file(RELATIVE_PATH _rel ${CMAKE_INSTALL_PREFIX}/${INSTALL_BINDIR}
     ${CMAKE_INSTALL_PREFIX})

set(_rpath "\$ORIGIN/${_rel}")
#上两句可通用
add_subdirectory(thirdparty)
# 设置message的rpath变量，message_RPATH
file(TO_NATIVE_PATH "${_rpath}/${INSTALL_LIBDIR}" message_RPATH)
``````
在将Message库添加进主CMakeLists后，还需设置该库的Message的rpath。
同样，当有多个库时，也需要设置相应的rpath。

- 为什么要设置rpath？
因为当可执行程序运行时，需要查找其依赖库，当在构建树中（即build文件夹下），可执行文件设置的查找路径为build目录下的lib文件中的动态库。
但当执行install后，安装位置所在的可执行文件要加载动态库，不可能再从build目录下加载，因为build目录可能会被删除。从而无法加载动态库，导致可执行程序无法运行。

可以通过ldd，查看可执行程序依赖库的加载路径，如下所示：

构建树下的Message库加载路径

``````bash
$ ldd ./bin/Helloworld
	linux-vdso.so.1 (0x00007ffee3c64000)
	libMessage.so => /home/code/CMakeLearning/10Install/00InstallProject/build/lib/libMessage.so (0x00007f58b75ea000)
	libstdc++.so.6 => /lib/x86_64-linux-gnu/libstdc++.so.6 (0x00007f58b73b7000)
	libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007f58b7397000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f58b716f000)
	libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f58b7088000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f58b75f6000)
``````
安装位置下的Message库加载路径

``````bash
$ ldd /aaa/bin/Helloworld
	linux-vdso.so.1 (0x00007ffe16728000)
	libMessage.so => /aaa/bin/../lib/libMessage.so (0x00007f3abbeae000)
	libstdc++.so.6 => /lib/x86_64-linux-gnu/libstdc++.so.6 (0x00007f3abbc7b000)
	libgcc_s.so.1 => /lib/x86_64-linux-gnu/libgcc_s.so.1 (0x00007f3abbc5b000)
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f3abba33000)
	libm.so.6 => /lib/x86_64-linux-gnu/libm.so.6 (0x00007f3abb94c000)
	/lib64/ld-linux-x86-64.so.2 (0x00007f3abbeba000)
``````
可以看出两处位置的库加载路径完全不同。如果安装位置中从build目录下加载库，当build目录被删除时，将导致可执行文件不可使用。

当然还是可以通过设置环境变量`LD_LIBRARY_PATH`,来通知链接器，从哪里去搜索该库。但会污染系统中所有应用程序的连接器路径。

因此最好的方式是将rpath编译进可执行程序中。

### 安装可执行文件
最后安装Helloworld。


``````cmake
#设置可执行文件的RPATH
set_target_properties(Helloworld
    PROPERTIES
      #让cmake生成并设置适当的rpath
      SKIP_BUILD_RPATH OFF
      #将已安装的可执行文件设置为先前设置的路径
      INSTALL_RPATH "${message_RPATH}"
      #告诉cmake将链接器搜索路径附加到可执行文件的rpath中
      INSTALL_RPATH_USE_LINK_PATH ON
)

install(
    TARGETS
      Helloworld
    ARCHIVE
      DESTINATION ${INSTALL_LIBDIR}
      COMPONENT lib
    RUNTIME
      DESTINATION ${INSTALL_BINDIR}
      COMPONENT bin
    LIBRARY
      DESTINATION ${INSTALL_LIBDIR}
      COMPONENT lib
)
``````
### cmake安装命令的其他参数
- FILES和PROGRAMS
    分别用于安装文件和程序，安装后，并设置安装文件适当的权限。
- DIRECTORY
    用于安装目录。当只给出一个目录名时，通常被理解为相对于当前源目录，可以对目录的安装
    粒度进行控制
- SCRIPT
    可以使用它再cmake脚本中定义自定义安装规则
- EXPORT

## 生成输出头文件

生成输出文件的目的是：只公开最小符号，从而限制代码中定义的对象和函数的对外可见性，同时
清楚的划分库和外部代码的接口。

项目结构如下所示：
``````bash
.
├── CMakeLists.txt
├── src
│   └── Helloworld.cpp
└── thirdparty
    ├── CMakeLists.txt
    └── Message
        ├── CMakeLists.txt
        ├── include
        │   └── Message.hpp
        └── src
            └── Message.cpp
5 directories, 6 files
``````
### 修改源码
为了公开最小符号，首先要修改库中的源码。在Message.hpp的头文件中


``````cpp
#pragma once
#include <iosfwd>
#include <string>
#include "MessageExport.h"
class Message_EXPORT Message {
public:
  Message(const std::string &m) : message_(m) {}
  friend std::ostream &operator<<(std::ostream &os, Message &obj) {
    return obj.printObject(os);
  }
private:
  std::string message_;
  std::ostream &printObject(std::ostream &os);
};
``````
文件中最重要的部分是添加了编译器生成的`messageExport.h`头文件。
和在该类中添加了`message_EXPORT`的预处理指令。

#### Message库下的CMakeLists
``````cmake
set(Message_src ${CMAKE_CURRENT_LIST_DIR}/src/Message.cpp)
add_library(Message SHARED ${Message_src})
set(Message_include ${CMAKE_CURRENT_LIST_DIR}/include/)
target_include_directories(Message 
  PUBLIC 
    ${Message_include}
    #添加导出的头文件所在路径
    ${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}/
)
set_target_properties(
  Message
  PROPERTIES
    #生成位置的代码
    POSITION_INDEPENDENT_CODE 1
    #隐藏所有符号，除非显示地标记了其他符号。
    CXX_VISIBILITY_PRESET hidden
    #隐藏内联函数的符号
    VISIBILITY_INLINES_HIDDEN 1
    OUTPUT_NAME "Message"
    #debug模式构建时，添加_d后缀
    DEBUG_POSTFIX "_d"
    #添加库的头文件
    PUBLIC_HEADER
    "${Message_include}/Message.hpp;${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}/MessageExport.h"
)

include(GenerateExportHeader)
generate_export_header(
  Message
  #设置生成的头文件和宏的名称
  BASE_NAME
  "Message"
  #设置导出宏的名称
  EXPORT_MACRO_NAME
  "Message_EXPORT"
  #设置导出头文件的名称
  EXPORT_FILE_NAME
  "${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}/MessageExport.h"
  #设置弃用宏的名称
  DEPRECATED_MACRO_NAME
  "Message_DEPRECATED"
  #设置不导出宏的名字
  NO_EXPORT_MACRO_NAME
  "Message_NO_EXPORT"
  #用于定义宏的名称，以便使用相同源编译静态库时的使用
  STATIC_DEFINE
  "Message_STATIC_DEFINE"
  #设置宏的名称，在编译时将未来弃用的代码排除在外
  NO_DEPRECATED_MACRO_NAME
  "Message_NO_DEPRECATED"
  #指示CMAKE生成预处理器代码，以从编译中排除未来弃用的代码
  DEFINE_NO_DEPRECATED)

# 生成静态库
add_library(Message_static STATIC "")
target_sources(Message_static PRIVATE ${CMAKE_CURRENT_LIST_DIR}/src/Message.cpp)

target_compile_definitions(Message_static PUBLIC message_STATIC_DEFINE)
target_include_directories(Message_static
  PUBLIC
    ${Message_include}
    ${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}/)

set_target_properties(
  Message_static
  PROPERTIES
    POSITION_INDEPENDENT_CODE 1
    #设置静态库的名称
    ARCHIVE_OUTPUT_NAME "Message"
    DEBUG_POSTFIX "_sd"
    RELEASE_POSTFIX "_s"
    PUBLIC_HEADER
    "${Message_include}/Message.hpp;${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}/MessageExport.h")

install(
  TARGETS Message Message_static
  ARCHIVE DESTINATION ${INSTALL_LIBDIR} COMPONENT lib
  RUNTIME DESTINATION ${INSTALL_BINDIR} COMPONENT bin
  LIBRARY DESTINATION ${INSTALL_LIBDIR} COMPONENT lib
  PUBLIC_HEADER DESTINATION ${INSTALL_INCLUDEDIR}/message COMPONENT dev)
``````
该CMakeLists与上一节类似。重要的在于以下几点：
1. `target_include_directories`中将导出的头文件也需要添加进来，因为在`Message.hpp`中使用到
了编译器导出的头文件。
2. `set_target_properties`中添加了`CXX_VISIBILITY_PRESET`和`VISIBILITY_INLINES_HIDDEN`两个选项
用以控制符号的可见性。同时将导出的头文件也添加进PUBLIC_HEADER中。
3. 注意在`generate_export_header`中设置的`EXPORT_MACRO_NAME`预处理器宏在`Message.hpp`中使用到了。
即如果某个类或函数需要导出在该函数或类前加该导出宏即可。其他同理。
4. 生成静态库与动态库的差别在于，静态库多了一条 `target_compile_definitions`。

**注意：**
- CMAKE_BINARY_DIR:表示构建树的build目录
- INSTALL_INCLUDEDIR:在主CMakeLists中被设置为`${CMAKE_INSTALL_INCLUDEDIR}`,即
的include目录。

### 主CMakeLists
主CMakeLists与上一节的类似。
1. 设置GNU的标准安装路径
2. 设置依赖库的rpath
3. 生成可执行文件
4. 将依赖库的rpath写入到可执行文件中
5. 安装

其中重要的在于：

``````cmake
#设置可执行文件的RPATH
set_target_properties(Helloworld
    PROPERTIES
      SKIP_BUILD_RPATH OFF
      #写入依赖库的rpath
      INSTALL_RPATH "${message_RPATH}"
      INSTALL_RPATH_USE_LINK_PATH ON
)

install(
    TARGETS
      Helloworld
      Helloworld_static
    ARCHIVE
      DESTINATION ${INSTALL_LIBDIR}
      COMPONENT lib
    RUNTIME
      DESTINATION ${INSTALL_BINDIR}
      COMPONENT bin
    LIBRARY
      DESTINATION ${INSTALL_LIBDIR}
      COMPONENT lib
)
``````
安装
`````` bash
sudo cmake -DCMAKE_INSTALL_PREFIX=/aaa ..
sudo make -j6
sudo make install
``````
安装效果如下所示:
``````bash
/aaa/
├── bin
│   ├── Helloworld
│   └── Helloworld_static
├── include
│   └── message
│       ├── Message.hpp
│       └── MessageExport.h
└── lib
    ├── libMessage.a
    └── libMessage.so

4 directories, 6 files
``````

## 输出目标
为了让其他使用cmake的项目更容易找到库，可以导出目标。
项目目录结构与上一个项目类似。

``````cmake
.
├── CMakeLists.txt
├── src
│   └── Helloworld.cpp
└── thirdPart
    ├── CMakeLists.txt
    └── Message
        ├── CMakeLists.txt
        ├── cmake
        │   └── MessageConfig.cmake.in
        ├── include
        │   └── Message.hpp
        └── src
            └── Message.cpp

6 directories, 7 files
``````
`Message`文件夹为需要导出的第三方库，与前一个项目不同点在于有一个`MessageConfig.cmake.in`文件，`src`下的文件为我们的测试文件。
重点在于`Message`库的cmake配置。

### 导出Message库

#### 配置文件模板
`MessageConfig.cmake.in`源码如下：

``````cmake
@PACKAGE_INIT@
include("${CMAKE_CURRENT_LIST_DIR}/messageTargets.cmake")
check_required_components("Message" )
``````

1. `@PACKAGE_INIT@`: 占位符，通常在CMake项目中表示项目的初始化部分，它可能包含项目名称、版本号等信息。在实际使用中，这将被替换为实际的项目初始化代码。

2. `include("${CMAKE_CURRENT_LIST_DIR}/messageTargets.cmake")`: 这一行包含了一个名为 `messageTargets.cmake` 的CMake脚本文件。
    通常，这样的脚本文件会定义一些关于项目构建和安装的规则，以及导出一些用于其他项目或模块的CMake目标。

3. `check_required_components(...)`: 这个函数调用检查是否满足了一组指定的必要组件。

   `check_required_components` 函数会确保这些目标或组件在构建时可用，如果缺少其中任何一个组件，它可能会产生错误或警告。

#### `Message`中的CMakeLists
`Message`路径下的`CMakeLists.txt`的大部分配置与上一节的内容一样。只有一小部分的差别。

- 差别一 ： `target_include_directories`命令


``````cmake
target_include_directories(
  Message PUBLIC
    #只有在项目中使用了该库，下列生成器表达式才会扩展成
    #${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}
    #即在构建中才会展开
    $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include/>
    #只有在安装时才会展开下列生成器表达式
    #即该Message库作为另一个构建树中的依赖目标时才会展开
    $<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}>)
``````
- 差别二： 新增了`target_compile_definitions` 命令

该命令为`Message`库添加了一个宏定义，当被安装和被其他项目使用时，`USING_Message` 变量就会被设置为`ON`。

以便其他项目使用时，可以通过检测该变量来进行后续操作。

``````cmake
target_compile_definitions(Message
  INTERFACE
  $<INSTALL_INTERFACE:USING_Message>
  )
``````

- 差别三： `install`命令中新增了导出文件的命令


``````cmake
install(
  TARGETS Message
  #导出生成对象
  EXPORT MessageTargets
  ARCHIVE DESTINATION ${INSTALL_LIBDIR} COMPONENT lib
  RUNTIME DESTINATION ${INSTALL_BINDIR} COMPONENT bin
  LIBRARY DESTINATION ${INSTALL_LIBDIR} COMPONENT lib
  PUBLIC_HEADER DESTINATION ${INSTALL_INCLUDEDIR}/message COMPONENT dev)
# 安装生成的cmake文件
install(
  EXPORT MessageTargets
  ##设置生成文件的名字
  FILE MessageTargets.cmake
  #为库添加命名空间
  NAMESPACE Message::
  DESTINATION ${INSTALL_CMAKEDIR}
  COMPONENT dev)
``````
#### 生成和安装Config配置文件


``````cmake
# 生成正确的CMake配置文件
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  #设置生成文件的路径
  ${CMAKE_CURRENT_BINARY_DIR}/MessageConfigVersion.cmake
  #写入该库的版本号
  VERSION 0.0.1
  #设置该库的兼容性，即同Major的版本就能兼容
  COMPATIBILITY SameMajorVersion)

configure_package_config_file(
  #基于该模板生成实际的cmake配置文件
  ${CMAKE_CURRENT_LIST_DIR}/cmake/MessageConfig.cmake.in
  #生成的实际配置文件
  ${CMAKE_CURRENT_BINARY_DIR}/MessageConfig.cmake
  #设置配置文件的安装路径
  INSTALL_DESTINATION ${INSTALL_CMAKEDIR})

# 安装生成的额配置文件
install(FILES 
              #安装两个生成的配置文件
              ${CMAKE_CURRENT_BINARY_DIR}/MessageConfig.cmake
              ${CMAKE_CURRENT_BINARY_DIR}/MessageConfigVersion.cmake
        DESTINATION ${INSTALL_CMAKEDIR})
``````

### 生成的文件结构

安装效果：

``````bash
[ 50%] Built target Message
[100%] Built target hello_world
Install the project...
-- Install configuration: ""
-- Installing: /test/lib/libMessage.so
-- Installing: /test/include/message/Message.hpp
-- Installing: /test/include/message/MessageExport.h
-- Installing: /test/share/cmake/Message/MessageTargets.cmake
-- Installing: /test/share/cmake/Message/MessageTargets-noconfig.cmake
-- Installing: /test/share/cmake/Message/MessageConfig.cmake
-- Installing: /test/share/cmake/Message/MessageConfigVersion.cmake
-- Installing: /test/bin/hello_world
-- Set runtime path of "/test/bin/hello_world" to "$ORIGIN/../lib"
``````
安装的目录结构

``````bash
.
├── bin
│   └── hello_world
├── include
│   └── message
│       ├── Message.hpp
│       └── MessageExport.h
├── lib
│   └── libMessage.so
└── share
    └── cmake
        └── Message
            ├── MessageConfig.cmake
            ├── MessageConfigVersion.cmake
            ├── MessageTargets-noconfig.cmake
            └── MessageTargets.cmake

7 directories, 8 files
``````
