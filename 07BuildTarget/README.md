# 构建项目

## 使用函数和宏重用代码
使用宏和函数能有效复用代码。当构建项目时，需要将不同功能的源文件分别放置在不同的目录下。为了编译不同目录下的源文件，对应目录下均要有对应的`CMakeLists.txt`文件。在主`CMakeLists.txt`中，通过`add_subdirectory`命令添加子目录。

例如：目录结构如下
```bash
.
├── CMakeLists.txt
├── src
│     ├── CMakeLists.txt
│     ├── main.cpp
│     ├── sum_integers.cpp
│     └── sum_integers.hpp
└── tests
      ├── catch.hpp
      ├── CMakeLists.txt
      └── test.cpp
```
根据GNU标准定义`binary`和`library`路径。在主`CMakeLists.txt`中添加如下语句
```cmake
include(GNUInstallDirs)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY
    ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY
    ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY
    ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})
```

主`CMakeLists.txt`添加其他目录
```cmake
add_subdirectory(src)
enable_testing()
add_subdirectory(tests)
```
### cmake宏
示例：
```cmake
#定义宏
macro(add_catch_test _name _cost)
  #算术表达式:num_macro_calls为全局变量，表示宏调用次数
  math(EXPR num_macro_calls "${num_macro_calls} + 1")
  #ARGC ARGV为cmake系统变量，表示参数数量，和参数列表
  message(STATUS "add_catch_test called with ${ARGC} arguments: ${ARGV}")
  #${ARGN}，保存给定参数数量之后的参数列表
  set(_argn "${ARGN}")
  if(_argn)
      message(STATUS "oops - macro received argument(s) we did not expect: ${ARGN}")
  endif()
  add_test(
    NAME
      ${_name}
    COMMAND
        #生成器表达式：$<TARGET_FILE:cpp_test> 如果是cpp_test则执行后面的命令。输出执行结果信息到build目录下的log文件中
      $<TARGET_FILE:cpp_test> [${_name}] --success --out ${PROJECT_BINARY_DIR}/tests/${_name}.log --durations yes
    WORKING_DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}
    )
    #添加测试目标属性的参数,COST 属性能让测试时间长的测试在测试时间短#的测试之前使用
  set_tests_properties(
    ${_name}
    PROPERTIES
        COST ${_cost}
    )
endmacro()

##使用cmake宏
set(num_macro_calls 0)
add_catch_test(short 1.5)
add_catch_test(long 2.5 extra_argument)
```

- cmake宏中的参数只能在宏内部使用。
- `ARGN`变量不能直接查询
- 宏和函数的区别在于：函数不能修改函数外的变量，除非使用`PARENT_SCOPE`显示表示。

```cmake
set(variable_visible_outside "some value" PARENT_SCOPE)
```
注意在函数内部修改外部变量时应使用以下流程。
```cmake
  #算术表达式:num_macro_calls为全局变量，表示函数调用次数
  set(num_macro_calls ${num_macro_calls} PARENT_SCOPE)
  math(EXPR num_macro_calls "${num_macro_calls} + 1")
  set(num_macro_calls ${num_macro_calls} PARENT_SCOPE)
```
先将外部变量传入函数内部，修改后再传出函数。

```cmake
set(CMAKE_INCLUDE_CURRENT_DIR_IN_INTERFACE ON)
```
将当前目录添加到`CMakeLists.txt`中定义的所有目标的`interface_include_directory`属性中。即无需使用`target_include_directory`来添加所需头文件的位置。

## cmake分块
cmake分块的好处：
- 主`CMakeLists.txt`易于阅读
- CMake模块可以在其他项目中重用
- 与函数结合，模块可以帮助我们限制变量的作用范围

### 增加CMake模块搜索路径
```cmake
list(APPEND CMAKE_MODULE_PATH "/path/to/SelfCmakeModule")
```
在编写完cmake模块后，增加cmake搜索路径，让cmake能找到编写的cmake模块文件。

模块可以：
- 定义函数
- 定义宏
- 查找程序
- 查找库
- 查找路径
模块不应该做其他事情，特别时定义或修改主cmake中的变量。以防出现意料之外的错误。

## 编写函数测试和设置编译器标志

### 函数模块
```cmake
include(CheckCCompilerFlag)
include(CheckCXXCompilerFlag)
include(CheckFortranCompilerFlag)
function(set_compiler_flag _result _lang)
  set(_valid_flags)
  #测试编译选项是否可用
  foreach(flag IN ITEMS ${ARGN})
      unset(_flag_works CACHE)
      if(_lang STREQUAL "C")
          check_c_compiler_flag("${flag}" _flag_works)
      elseif(_lang STREQUAL "CXX")
          check_cxx_compiler_flag("${flag}" _flag_works)
      elseif(_lang STREQUAL "Fortran")
          check_Fortran_compiler_flag("${flag}" _flag_works)
      else()
          message(FATAL_ERROR "Unknown language in set_compiler_flag: ${_lang}")
      endif()
    # flag可以使用则添加到局部变量 _valid_flags中
    if(_flag_works)
        list(APPEND _valid_flags "${flag}")
    endif()
  endforeach()
  #将最后结果传递给函数外部变量，函数中的_result为形参，需解引用到外部变量
  set(${_result} "${_valid_flags}" PARENT_SCOPE)
endfunction()
```
### 函数的使用
```cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(set_compiler_flag)
#测试C标志列表
set_compiler_flag(
  working_compile_flag C 
  "-foo" # this should fail
  "-wrong" # this should fail
  "-wrong" # this should fail
  "-Wall" # this should work with GNU
  "-warn all" # this should work with Intel
  "-Minform=inform" # this should work with PGI
  "-nope" # this should fail
  "-v"
  )
message(STATUS "working C compile flag: ${working_compile_flag}")
```

## 使用指定参数定义函数或宏
项目目录如下
```bash
.
├── CMakeLists.txt
├── cmake
│   └── testing.cmake
├── src
│   ├── CMakeLists.txt
│   ├── main.cpp
│   ├── sum_integers.cpp
│   └── sum_integers.hpp
└── tests
    ├── CMakeLists.txt
    └── test.cpp
```
### testing的cmake模块
使用命名参数定义函数
```cmake
function(add_catch_test)
  #编译选项参数
  set(options)
  #单值参数
  set(oneValueArgs NAME COST)
  #多值参数
  set(multiValueArgs LABELS DEPENDS REFERENCE_FILES)
  #解析选项和参数
  cmake_parse_arguments(add_catch_test
    "${options}"
    "${oneValueArgs}"
    "${multiValueArgs}"
    ${ARGN}
    )
...
endfunction()
```
`cmake_parse_arguments`命令解析选项和参数,并在函数中定义了如下变量。
- add_catch_test_NAME
- add_catch_test_COST
- add_catch_test_LABELS
- add_catch_test_DEPENDS
- add_catch_test_REFERENCE_FILES

单值参数是指：该参数只有一个值
多值参数是指: 该参数有多个值

### 其他
在主`CMakeLists.txt`中添加以下语句：
```cmake
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")#让cmake能找到自己写的cmake模块
```
在tests目录下的cmake中添加
```cmake
#添加testing模块
include(testing)
#添加测试
add_catch_test(
  NAME
    short
  LABELS
    short
    cpp_test
  COST
    1.5
)
```

## 重定义函数和宏
模块可能被包含多次，可以使用`include_guard`命令让模块只被包含一次。（cmake 3.10以上）

在模块顶部添加
```cmake
include(GLOBAL)
```
cmake不会对重定义的宏或函数进行警告

## 使用废弃函数、宏和变量
"废弃”是在不断发展的项目开发过程中一种重要机制，它向开发人员发出信号，表明将来某个函数、宏或变量将被删除或替换。在一段时间内，函数、宏或变量将继续可访问，但会发出警告，最终可能会上升为错误.

### 弃用函数和宏
重定义一个函数或宏就相当于弃用该函数或宏。
例如：
在之前有个已经定义了的宏`somemacro`。

重定义该宏，并添加deprecated信息，即可实现对宏或函数的弃用。
```cmake
macro(somemacro)
  #打印弃用信息
  message(DEPRECATION "somemacro is deprecated")
  #调用之前定义的宏传递参数
  _somemacro(${ARGV})
endmacro()
```

### 弃用变量
首先实现一个打印弃用信息的宏。
```cmake
function(deprecate_variable _variable _access)
  if(_access STREQUAL "READ_ACCESS")
      message(DEPRECATION "variable ${_variable} is deprecated")
  endif()
endfunction()
```

函数添加到将要被弃用的变量上。

```cmake
variable_watch(somevariable deprecate_variable)
```
如果变量`somevariable`被使用，则将调用`deprecate_variable`函数。当函数检查到要读取变量时即打印弃用信息。`READ_ACCESS`用于匹配是否是读取变量。


## add_subdirectory的限定范围
将源代码编译分成更小的、定义良好的库。这样做既是为了本地化和简化依赖项，也是为了简化代码维护。

定义尽可能接近代码目标的好处是，对于该库的修改，只需要变更该目录中的文件即可。库依赖项被封装意味着库能够在大型项目中被更好的复用。

通过`add_subdirectory`命令可以隔离变量的作用域范围。子目录中定义的变量在父范围内不能访问。

但`add_subdirectory`命令也有缺点：
- CMake不允许将target_link_libraries与定义在当前目录范围之外的目标一起使用。
即如果某个依赖库在目录范围之外则无法使用。

`OBJECT`库是组织大型项目的另一种可行方法。唯一修改是在库的`CMakeLists.txt`中。源文件将被编译成目标文件：既不存档到静态库中，也不链接到动态库中。
例如：
```cmake
add_library(io OBJECT "")
target_sources(io
  PRIVATE
      io.cpp
  PUBLIC
      ${CMAKE_CURRENT_LIST_DIR}/io.hpp
  )
target_include_directories(io
  PUBLIC
      ${CMAKE_CURRENT_LIST_DIR}
  )
```

### 生成项目结构图表
```bash
$ cd build
$ cmake --graphviz=example.dot ..
$ dot -T png example.dot -o example.png
```

## 使用target_source避免全局变量

项目结构如下
```bash
.
├── CMakeLists.txt
├── external
│   ├── CMakeLists.txt
│   ├── conversion.cpp
│   └── conversion.hpp
├── src
│   ├── CMakeLists.txt
│   ├── evolution
│   │   ├── CMakeLists.txt
│   │   ├── evolution.cpp
│   │   └── evolution.hpp
│   ├── initial
│   │   ├── CMakeLists.txt
│   │   ├── initial.cpp
│   │   └── initial.hpp
│   ├── io
│   │   ├── CMakeLists.txt
│   │   ├── io.cpp
│   │   └── io.hpp
│   ├── main.cpp
│   └── parser
│       ├── CMakeLists.txt
│       ├── parser.cpp
│       └── parser.hpp
└── tests
    ├── CMakeLists.txt
    └── test.cpp

```

### 主cmake设置

通过`include()`命令引用子目录下的`CMakeLists.txt`文件，这样在父范围内仍然能保持所有目标可用。

```cmake
include(src/CMakeLists.txt)
include(external/CMakeLists.txt)
```
### 子cmake设置
在子目录中，需要使用相对于父范围的路径(相对于主cmake的路径)。
```cmake
# src/CMakeLists.txt文件中
include(${CMAKE_CURRENT_LIST_DIR}/evolution/CMakeLists.txt)
include(${CMAKE_CURRENT_LIST_DIR}/initial/CMakeLists.txt)
include(${CMAKE_CURRENT_LIST_DIR}/io/CMakeLists.txt)
include(${CMAKE_CURRENT_LIST_DIR}/parser/CMakeLists.txt)
```

这样，通过`include()`语句就能定义并链接到文件树中的任何位置的目标。
