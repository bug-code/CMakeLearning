@[TOC]
# 从源码构建和链接静态和动态库

## 构建和链接静态库

目录结构
```bash
.
├── build
├── CMakeLists.txt
├── readme.md
├── src
│   └── Helloworld.cpp
└── thirdparty
    ├── Message.cpp
    └── Message.hpp
```

CMakeLists.txt

```bash
cmake_minimum_required(VERSION 3.25.1 FATAL_ERROR)
project(CMakeLib LANGUAGES CXX)
#将Message源文件编译成静态库
#CMAKE_CURRENT_SOURCE_DIR当前cmakelists.txt文件所在目录
add_library(Message
STATIC
    ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message.cpp
)
#Helloworld编译成可执行文件
add_executable(Helloworld ${CMAKE_CURRENT_SOURCE_DIR}/src/Helloworld.cpp)
#Message静态库链接到将helloworld文件
target_link_libraries(Helloworld Message)
```

`CMAKE_CURRENT_SOURCE_DIR`为当前CMakeLists.txt文件所在的目录。

`add_library()` 为创建静态或动态库，库名称自定(如Message), 静态库或动态库由两个关键字指定（`STATIC`、`SHARED`)。再添加生成库的源文件路径

`target_link_libraries()`将动态或静态库链接到项目文件中

执行以下命令
```bash
cd  build
cmake ..
cmake --build .
```

## 对象库
如果需一次性创建静态库和动态库，则使用OBJECT关键词，创建对象库。
```bash
cmake_minimum_required(VERSION 3.25.1 FATAL_ERROR)
project(CMakeLib LANGUAGES CXX)

add_library(Message
OBJECT
    ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message.cpp
)

set_target_properties(Message 
##下两命令暂时不能缺
    PROPERTIES
        POSITION_INDEPENDENT_CODE 1
)

add_library(Message_shared
    SHARED
        $<TARGET_OBJECTS:Message>    
)
add_library(Message_static
    STATIC
        $<TARGET_OBJECTS:Message>
)
#Helloworld编译成可执行文件
add_executable(Helloworld ${CMAKE_CURRENT_SOURCE_DIR}/src/Helloworld.cpp)
#Message静态库链接到将helloworld文件
target_link_libraries(Helloworld Message_shared)
```

## 生成同名的静态和动态库
```bash
cmake_minimum_required(VERSION 3.25.1 FATAL_ERROR)
project(CMakeLib LANGUAGES CXX)

add_library(Message
OBJECT
    ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message.cpp
)

set_target_properties(Message 
##下两命令暂时不能缺
    PROPERTIES
        POSITION_INDEPENDENT_CODE 1
)

add_library(Message_shared
    SHARED
        $<TARGET_OBJECTS:Message>    
)
#设置Message_shared库的属性
set_target_properties(Message_shared
    PROPERTIES
        OUTPUT_NAME "Message"
)

add_library(Message_static
    STATIC
        $<TARGET_OBJECTS:Message>
)
#设置Message_static库的属性
set_target_properties(Message_static
    PROPERTIES
        OUTPUT_NAME "Message"
)

#Helloworld编译成可执行文件
add_executable(Helloworld ${CMAKE_CURRENT_SOURCE_DIR}/src/Helloworld.cpp)
#Message静态库链接到将helloworld文件
target_link_libraries(Helloworld Message_shared)
```

关键点：
- add_library中targetName需要有区分，不然在target_link_libraries中无法区分链接哪个库


## 链接已生成的第三方库
假设系统中已经有了第三方库`libMessage_shared.so`文件
则CMakeLists.txt如下
```bash
cmake_minimum_required(VERSION 3.25.1 FATAL_ERROR)
project(CMakeLib LANGUAGES CXX)
#添加要链接库.so文件的路径
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/thirdparty)
#Helloworld编译成可执行文件
add_executable(Helloworld ${CMAKE_CURRENT_SOURCE_DIR}/src/Helloworld.cpp)
#Message静态库链接到将helloworld文件
target_link_libraries(Helloworld libMessage_shared.so)
```

