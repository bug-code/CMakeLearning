# 配置时和构建时操作
## 执行自定义命令
有些项目构建时，可能需要与平台的文件系统进行交互。也就是检查文件是否存在、创建新文件来存储临时信息、创建或提取打包文件等等操作。

在cmake-cookbook的5.1节中，给出的示例无法在linux的cmake 3.22.1中正常执行。
cmake-cookbook给出的代码示例。
```cmake
add_custom_target(unpack-eigen
  ALL
  COMMAND
      ${CMAKE_COMMAND} -E tar xzf ${CMAKE_CURRENT_SOURCE_DIR}/eigen-eigen-5a0156e40feb.tar.gz
  COMMAND
      ${CMAKE_COMMAND} -E rename eigen-eigen-5a0156e40feb eigen-3.3.4
  WORKING_DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}
  COMMENT
      "Unpacking Eigen3 in ${CMAKE_CURRENT_BINARY_DIR}/eigen-3.3.4"
  )
```

在使用`add_custom_target`时，无法执行多条命令。猜测是因为cmake使用多线程分别执行其中的命令。导致在download后，无法正常解压给定的文件。由于无法解压获得给定的文件，所以在多线程执行重命名时也失败。

经修改后可正常执行
```cmake
#download eigen
if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/thirdPart/eigen)
    message(NOTICE "-- unpack eigen")
    execute_process(COMMAND wget https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz
                    WORKING_DIRECTORY  ${CMAKE_CURRENT_SOURCE_DIR}/thirdPart/
    ) 
    execute_process(                    
        COMMAND tar xzf  eigen-3.4.0.tar.gz
        WORKING_DIRECTORY  ${CMAKE_CURRENT_SOURCE_DIR}/thirdPart/
    )
    execute_process(
        COMMAND mv eigen-3.4.0 eigen
        WORKING_DIRECTORY  ${CMAKE_CURRENT_SOURCE_DIR}/thirdPart/
    )
endif()
#add target fold
add_custom_target(eigen
    ALL
    COMMAND echo "build eigen target"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/thirdPart/eigen/
)
```
### add_custom_target命令解析
```cmake
add_custom_target(unpack-eigen
  ALL
  COMMAND
      ${CMAKE_COMMAND} -E tar xzf ${CMAKE_CURRENT_SOURCE_DIR}/eigen-eigen-5a0156e40feb.tar.gz
  COMMAND
      ${CMAKE_COMMAND} -E rename eigen-eigen-5a0156e40feb eigen-3.3.4
  WORKING_DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}
  COMMENT
      "Unpacking Eigen3 in ${CMAKE_CURRENT_BINARY_DIR}/eigen-3.3.4"
  )
```
- 引入一个名为unpack-eigen的target
- ALL表明目标将始终被执行
- COMMAND参数指定要执行哪些命令
- -E参数表示调用cmake命令本身来执行实际的工作，与操作系统无关的方式，运行公共操作。对许多常见操作，cmake实现了一个对所有操作系统都通用的接口，使得构建系统独立与特定操作系统。
- WORKING_DIRECTORY指定在哪个目录执行操作
- COMMENT为代码注释

1. 使用`cmake -E`可以查看特定操作系统的cmake能执行哪些操作。

## 配置时运行自定义命令
### `execute_process`
```cmake
execute_process(
    COMMAND <cmd1> [<arguments>] 
    [COMMAND <cmd2> [<arguments>]]... 
    [WORKING_DIRECTORY <directory>] 
    [TIMEOUT <seconds>] 
    [RESULT_VARIABLE <variable>] 
    [RESULTS_VARIABLE <variable>] 
    [OUTPUT_VARIABLE <variable>] 
    [ERROR_VARIABLE <variable>] 
    [INPUT_FILE <file>] 
    [OUTPUT_FILE <file>]
    [ERROR_FILE <file>] 
    [OUTPUT_QUIET] 
    [ERROR_QUIET] 
    [COMMAND_ECHO <where>] [OUTPUT_STRIP_TRAILING_WHITESPACE] [ERROR_STRIP_TRAILING_WHITESPACE] 
    [ENCODING <name>] 
    [ECHO_OUTPUT_VARIABLE] 
    [ECHO_ERROR_VARIABLE] 
    [COMMAND_ERROR_IS_FATAL <ANY|LAST>])
```
- COMMAND表示执行什么命令
- WORKING_DIRECTORY表示在哪个目录中执行命令
- TIMEOUT 表示设定执行时间，超时就报错
- RESULT_VARIABLE 表示执行结果，整数表示执行成功，否则为一个带有错误条件的字符串
- OUTPUT_VARIABLE和ERROR_VARIABLE将包含执行命令的标准输出和标准错误。由于命令的输出是通过管道传输的，因此只有最后一个命令的输出标准才会保存到OUT_VARIABLE中
- INPUT_FILE指定标准输入重定向的文件名，即标准输入会保存到该文件中
- OUTPUT_FILE指标准输出重定向的文件名
- ERROR_FILE指标准错误输出重定向的文件名
- 设置OUTPUT_QUIET和ERROR_QUIET后，CMake将静默地忽略标准输出和标准错误
- 设置OUTPUT_STRIP_TRAILING_WHITESPACE，可以删除运行命令的标准输出中的任何尾随空格
- 设置ERROR_STRIP_TRAILING_WHITESPACE，可以删除运行命令的错误输出中的任何尾随空格

## add_custom_command
有些操作需要在构建前进行操作。
cmake提供多种方式执行自定义命令。
- 使用`add_custom_command`编译目标，生成输出文件
- `add_custom_target`的执行没有输出
- 构建目标前后，`add_custom_command`的执行可以没有输出

三种不能相互替换。

### add_custom_command的使用
```cmake
add_custom_command(
    OUTPUT output1 [output2 ...] 
    COMMAND command1 [ARGS] [args1...] 
    [COMMAND command2 [ARGS] [args2...] ...] [MAIN_DEPENDENCY depend] 
    [DEPENDS [depends...]] 
    [BYPRODUCTS [files...]] 
    [IMPLICIT_DEPENDS 
        <lang1> depend1 
        [<lang2> depend2] ...] 
    [WORKING_DIRECTORY dir] 
    [COMMENT comment] 
    [DEPFILE depfile] 
    [JOB_POOL job_pool] 
    [VERBATIM] 
    [APPEND] 
    [USES_TERMINAL]
    [COMMAND_EXPAND_LISTS]
)
```
- OUTPUT 为输出到目标路径下的文件中，在执行add_custom_command前output1要存在。具体见示例。
- COMMAND为要执行的命令，使用-E选项为使用cmake提供的平台无关的通用接口命令。
- WORKING_DIRECTORY为命令执行的位置
- DEPENDS参数列出了自定义命令的依赖项
- COMMENT在构建时显示状态消息
- VERBATIM为高速cmake为生成器和平台生成正确的命令，从而确保完全独立。

### add_custom_command的限制
- add_custom_command的依赖目标须存在，否则会导致失败,依赖项须在同一目录
- 当有多个add_custom_command命令时，生成的output有重合时可能会导致失败。
- 第二个限制可以使用add_dependencies来避免。最好是使用add_custom_target命令。

## add_custom_target
`add_custom_target`命令将依次执行给定的目标，且不返回输出。可以将`add_custom_command`和`add_custom_target`结合使用。

在子目录中可以单独编写一个CMakeLists.txt文件。在主CMakeLists.txt中，通过`add_subdirectory`命令将子目录添加进主CMakeLists.txt文件中使用。

### `add_custom_target`和`add_custom_target`结合使用
示例：
```cmake
#设置add_custom_target的依赖选项MATH_SRCS
set(MATH_SRCS
  ${CMAKE_CURRENT_BINARY_DIR}/wrap_BLAS_LAPACK/CxxBLAS.cpp
  ${CMAKE_CURRENT_BINARY_DIR}/wrap_BLAS_LAPACK/CxxLAPACK.cpp
  ${CMAKE_CURRENT_BINARY_DIR}/wrap_BLAS_LAPACK/CxxBLAS.hpp
  ${CMAKE_CURRENT_BINARY_DIR}/wrap_BLAS_LAPACK/CxxLAPACK.hpp
  )
#添加一个taget,该target依赖${CMAKE_CURRENT_BINARY_DIR}目录下的MATH_SRC 目标。${CMAKE_CURRENT_BINARY_DIR}表示build目录
add_custom_target(BLAS_LAPACK_wrappers
  WORKING_DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS
      ${MATH_SRCS}
  COMMENT
      "Intermediate BLAS_LAPACK_wrappers target"
  VERBATIM
  )
#在build目录下执行指定命令，并输出一个taget名为MATH_SRCS
add_custom_command(
  OUTPUT
      ${MATH_SRCS}
  COMMAND
      ${CMAKE_COMMAND} -E tar xzf ${CMAKE_CURRENT_SOURCE_DIR}/wrap_BLAS_LAPACK.tar.gz
  WORKING_DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS
      ${CMAKE_CURRENT_SOURCE_DIR}/wrap_BLAS_LAPACK.tar.gz
  COMMENT
      "Unpacking C++ wrappers for BLAS/LAPACK"
  ) 
```

以上三个命令的顺序不能乱，否则会报错。
`add_custom_target`添加的目标没有输出，因此总会执行，且可以在子目录中引入自定义目标，并在主CMakeLists.txt中使用。

在添加头文件构建一个库时，应当设置为private避免出错。

## add_custom_command执行没有输出的操作
由于自定义命令仅在必须构建目标本身时才执行，因此可以实现对其执行的目标级控制。

```cmake
add_custom_command(
    TARGET <target> 
    PRE_BUILD | PRE_LINK | POST_BUILD 
    COMMAND 
        command1 [ARGS] [args1...] 
    [COMMAND command2 [ARGS] [args2...] ...] 
    [BYPRODUCTS [files...]] 
    [WORKING_DIRECTORY dir] 
    [COMMENT comment] 
    [VERBATIM] 
    [USES_TERMINAL] 
    [COMMAND_EXPAND_LISTS]
)
```
当声明了库或可执行目标，就可以使用`add_custom_command`将其他命令锁定到目标上。这些命令即将在指定的时间执行，与他们所附加的目标的执行相关联。(即将COMMAND的内容绑定到target)。

- PRE_BUILD: 在执行与目标相关的任何其他规则之前执行
- PRE_LINK: 命令在编译目标后，调用连接器或归档器之前执行。
- POST_BUILD:在执行给定目标的所有规则之后运行。

## 编译和链接命令
查询依赖项是否能被正常编译。
- 使用`Check<LANG>SourceCompiles.cmake`中的标准模块`check_<lang>_source_compiles`函数，以评估给定编译器是否可以将预定义的代码编译成可执行文件。该命令拥有功能
  - 编译器支持所需的特性
  - 连接器工作正常，并理解特定的标志
  - 可以使用find_package找到包含的目录和库
- `try_compile`命令也拥有相同的功能

### 获得相应模块的文档
```bash
# cmake --help-module <module-name>
# cmake --help-command <command-name>
#例如：
cmake --help-command try_compile
cmake --help-module CheckCXXSourceCompiles
```
### try_compile示例
```
#设置临时目录，try_compile将在该目录下生成中间文件
set(_scratch_dir ${CMAKE_CURRENT_BINARY_DIR}/omp_try_compile)
#尝试编译源文件，结果保存在omp_taskloop_test_1变量中
try_compile(
  omp_taskloop_test_1
      ${_scratch_dir}
  SOURCES
      ${CMAKE_CURRENT_SOURCE_DIR}/taskloop.cpp
  LINK_LIBRARIES
      OpenMP::OpenMP_CXX #通过导入目标的方式链接到对应的库，目录和编译器标志
)
message(STATUS "Result of try_compile: ${omp_taskloop_test_1}")
```

### check_cxx_source_compiles函数示例
```cmake
#添加所需要的模块
include(CheckCXXSourceCompiles)
#通过file命令读取源码到给定的变量中
file(READ ${CMAKE_CURRENT_SOURCE_DIR}/taskloop.cpp _snippet)
#设置需要链接的库，通过导入目标的方式链接到对应的库，目录和编译器标志
set(CMAKE_REQUIRED_LIBRARIES OpenMP::OpenMP_CXX)
#使用源码作为参数，将检查结果保存到omp_taskloop_test_2
check_cxx_source_compiles("${_snippet}" omp_taskloop_test_2)
#取消CMAKE_REQUIRED_LIBRARIES变量的设置，以防对后续的内容产生影响。
unset(CMAKE_REQUIRED_LIBRARIES)
message(STATUS "Result of check_cxx_source_compiles: ${omp_taskloop_test_2}")
```
### 其他
check_cxx_source_compiles微调编译和链接，必须通过设置以下CMake变量进行:
- CMAKE_REQUIRED_FLAGS：设置编译器标志。
- CMAKE_REQUIRED_DEFINITIONS：设置预编译宏。
- CMAKE_REQUIRED_INCLUDES：设置包含目录列表。
- CMAKE_REQUIRED_LIBRARIES：设置可执行目标能够连接的库列表
- 以导入目标的方式，可以不设置这些参数。导入的目标会设置

命令try_compile提供了更完整的接口和两种不同的操作模式:

- 以一个完整的CMake项目作为输入，并基于它的CMakeLists.txt配置、构建和链接。这种操作模式提供了更好的灵活性，因为要编译项目的复杂度是可以选择的。
- 提供了源文件，和用于包含目录、链接库和编译器标志的配置选项

try_compile执行后会删除其生成的中间文件。
- 使用`--debug-trycompile`能保留其生成的中间文件
- 如果代码中有多个try_compile调用，一次只能调试一个
- 清除变量的内容，`cmake -U <variable-name>` 
- 只有清楚缓存检查，try_compile才会重新运行。
  
总结：
- 小代码使用`check_<lang>_source_compile`
- 其他使用`try_compile`

## 编译器标志
### Sanitizers简介
Sanitizers已经成为静态和动态代码分析的非常有用的工具。通过使用适当的标志重新编译代码并链接到必要的库，可以检查内存错误(地址清理器)、未初始化的读取(内存清理器)、线程安全(线程清理器)和未定义的行为(未定义的行为清理器)相关的问题。与同类型分析工具相比，Sanitizers带来的性能损失通常要小得多，而且往往提供关于检测到的问题的更详细的信息。

### 检查编译器flags模块
示例：检查编译器是否支持Sanitizers，即能否添加Sanitizers的编译选项。
```cmake
#添加检查flags的cmake模块
include(CheckCXXCompilerFlag)
#设置AddressSanitizer的编译选项
set(ASAN_FLAGS "-fsanitize=address -fno-omit-frame-pointer")
#将AddressSanitizer的编译选项添加到cmake的CMAKE_REQUIRED_FLAGS变量中
set(CMAKE_REQUIRED_FLAGS ${ASAN_FLAGS})
#调用检查flags的cmake函数检查是否支持该编译选项，结果保存在asan_works变量中
check_cxx_compiler_flag(${ASAN_FLAGS} asan_works)
#取消CMAKE_REQUIRED_FLAGS设置，防止对后续内容产生影响
unset(CMAKE_REQUIRED_FLAGS)
if(asan_works)
    #将变量转换为列表，用分号替换空格
    string(REPLACE " " ";" _asan_flags ${ASAN_FLAGS})
    add_executable(asan-example asan-example.cpp)
    target_compile_options(asan-example
            PUBLIC
                ${CXX_BASIC_FLAGS}
                ${_asan_flags}
    )
    target_link_libraries(asan-example PUBLIC ${_asan_flags})
endif()  
```
### 其他
1. 调用`check_<lang>_compiler_flags`前，需调用之前设置的`CMAKE_REQUIRED_FLAGS`变量。
2. 使用字符串变量和列表来设置编译器标志。
   -  使用`target_compile_options`和`target_link_libraries`函数的字符串变量，将导致编译器和连接器报错。


## 探究可执行命令
检查是否可以在当前系统上编译、链接和运行代码。
## UUID示例
```cmake
#UUID库需要使用PkgConfig组件进行查找
find_package(PkgConfig REQUIRED QUIET)
#查找UUID库的uuid组件，并返回一个CMake导入目标
pkg_search_module(UUID REQUIRED uuid IMPORTED_TARGET)
if(TARGET PkgConfig::UUID)
    message(STATUS "Found libuuid")
endif()
#检查代码是否能执行的模块，c++的为`CheckCXXSourceRuns.cmake`
include(CheckCSourceRuns)
#设置变量，其值为测试源码字符
set(_test_uuid
    "
    #include <uuid/uuid.h>
    int main(int argc, char * argv[]) {
    uuid_t uuid;
    uuid_generate(uuid);
    return 0;
    }
    "
)
# 设置CMAKE_REQUIRED_LIBRARIES变量为要使用的库，以便链接测试程序使用
set(CMAKE_REQUIRED_LIBRARIES PkgConfig::UUID)
#检测是否能执行该测试程序，执行结果存放在_runs变量中
check_c_source_runs("${_test_uuid}" _runs)
#取消对CMAKE_REQUIRED_LIBRARIES变量的设置，以防对后续内容产生影响
unset(CMAKE_REQUIRED_LIBRARIES)
```

### 其他
`check_<lang>_source_runs`的执行可以通过以下变量来进行:

- CMAKE_REQUIRED_FLAGS：设置编译器标志。
- CMAKE_REQUIRED_DEFINITIONS：设置预编译宏。
- CMAKE_REQUIRED_INCLUDES：设置包含目录列表。
- CMAKE_REQUIRED_LIBRARIES：设置可执行目标需要连接的库列表。

`check_<lang>_source_runs`是`try_run`的包装器。


## 使用生成器表达式微调配置和编译
生成器表达式为逻辑和信息表达式，提供了一个强大而紧凑的模式，这些表达式在生成构建系统时进行评估，并生成特定于每个构建配置的信息。换句话说，生成器表达式用于引用仅在生成时已知，但在配置时未知或难于知晓的信息；对于文件名、文件位置和库文件后缀尤其如此。

### MPI示例
生成器表达式可以在cmake 3.3.0以上版本使用。

```cmake
#查找要使用到的MPI库
find_package(MPI REQUIRED)
#生成可执行程序
add_executable(example example.cpp)
# 通过使用生成器表达式来选择是否链接到MPI库
target_link_libraries(example
  PUBLIC
      $<$<BOOL:${MPI_FOUND}>:MPI::MPI_CXX>
  )
#通过使用生成器表达式来选择是否为可执行程序添加编译选项
target_compile_definitions(example
  PRIVATE
      $<$<BOOL:${MPI_FOUND}>:HAVE_MPI>
  )
```
### 生成器表达式
`$< $<condition> : val  >`
即生成器表达式中`:`前后为两部分。
- 生成器表达式以`$< >`形式包裹
- 当`$<condition>`为真时，将设置val的值，否则为空字符串

例如：
```cmake
$<$<BOOL:${MPI_FOUND}>:MPI::MPI_CXX>
```
- `BOOL:${MPI_FOUND}`表明`MPI_FOUND`变量为一个bool值
- 当该值为真时，将设置MPI::MPI_CXX

### 其他

CMake提供了三种类型的生成器表达式:

- 逻辑表达式：
  - 基本模式为`$<condition:outcome>`。基本条件为0表示false, 1表示true，但是只要使用了正确的关键字，任何布尔值都可以作为条件变量。
- 信息表达式：
  - 基本模式为`$<information>`或`$<information:input>`。这些表达式对一些构建系统信息求值，例如：包含目录、目标属性等等。这些表达式的输入参数可能是目标的名称，比如表达式`$<TARGET_PROPERTY:tgt,prop>`，将获得的信息是tgt目标上的`prop`属性。
- 输出表达式：
  - 基本模式为`$<operation>`或`$<operation:input>`。这些表达式可能基于一些输入参数，生成一个输出。它们的输出可以直接在CMake命令中使用，也可以与其他生成器表达式组合使用。例如`- I$<JOIN:$<TARGET_PROPERTY:INCLUDE_DIRECTORIES>, -I>`将生成一个字符串，其中包含正在处理的目标的包含目录，每个目录的前缀由-I表示