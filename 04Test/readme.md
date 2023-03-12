# CMake Test
cmake对任何编程语言进行测试
## 自定义CMake的Test
项目目录如下
```bash
.
├── CMakeLists.txt
├── main.cpp
├── sum_integers.cpp
├── sum_integers.hpp
├── test.cpp
├── test.py
└── test.sh
```
- sum_integers为项目源文件。
- main为从命令行获取测试数据并调用sum_integers的功能，并返回计算结果。
- test为在test文件中设定测试数据，并调用相应的程序将测试数据传输给main的可执行文件。由main可执行程序计算，并返回计算结果。test获取计算结果，根据test文件中的设定，判断测试成功与否。

### cmake中的test编写
- `enable_testing()` 启用test功能，测试该CMakeList.txt所在目录及其所有子文件夹。
- `add_test()` 定义一个新测试，并设置测试名称和运行命令

例如：
```camke
add_test(
    NAME cpp_test
    COMMAND $<TARGET_FILE:cpp_test>
)
``` 
- 创建了一个名为cpp_test的测试项
- COMMAN表示执行对应的命令
- $\<TARGET_FILE:cpp_test\> 为生成器表达式。构建时，cmake会将名cpp_test这个可执行文件的完整路径，替换为该生成器表达式。并执行。`以便可以不显示的指定可执行程序的位置和名称，而且不同系统的可执行文件名可能不同，不好移植`

再例如：
```cmake
add_test(
  NAME python_test_short
  COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/test.py --short --executable $<TARGET_FILE:sum_up>
  )
```
构建一个名为python_test_short的测试项。调用python解释器，指定test.py的选项参数为--short, --executable ， $\<TARGET_FILE:sum_up\>即为test文件所需要使用到的可执行程序（为main程序）。test.py产生调用main程序使用指定的测试数据进行测试，并获取测试结果，并返回测试成功与否。

编译完后，执行`ctest`命令即可进行测试。
- 添加`--return-failed`执行之前失败的测试
- --output-on-failure 将测试程序生成的内容打印到屏幕上
- -v 将启用测试的详细输出
- -vv 将启用更详细的输出
  
cmake还将为生成器创建目标。
- Unix Makefile生成器，通过`make test`测试
- Ninja生成器，通过`ninja test`测试

#### 指定测试的工作目录
例如：
```cmake
add_test(
  NAME python_test_long
  COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/test.py --executable $<TARGET_FILE:sum_up>
  )
```
可以改写为如下，指定工作目录。
```cmake
add_test(
  NAME python_test_long
  COMMAND ${PYTHON_EXECUTABLE} test.py --executable $<TARGET_FILE:sum_up>
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )
```

#### 按名称组织相关测试
测试名称添加`/`即可
```cmake
add_test(
  NAME python/long
  COMMAND ${PYTHON_EXECUTABLE} test.py --executable $<TARGET_FILE:sum_up>
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
  )
```
#### 为测试脚本设置环境变量
```cmake
set_tests_properties(python_test
  PROPERTIES
    ENVIRONMENT
      ACCOUNT_MODULE_PATH=${CMAKE_CURRENT_SOURCE_DIR}
      ACCOUNT_HEADER_FILE=${CMAKE_CURRENT_SOURCE_DIR}/account/account.h
      ACCOUNT_LIBRARY_FILE=$<TARGET_FILE:account>
  )
```
也可以通过`CMAKE_COMMAND`调用CMake来预先设置环境变量。
```cmake
add_test(
  NAME
      python_test
  COMMAND
    ${CMAKE_COMMAND} -E env
    ACCOUNT_MODULE_PATH=${CMAKE_CURRENT_SOURCE_DIR}
    ACCOUNT_HEADER_FILE=${CMAKE_CURRENT_SOURCE_DIR}/account/account.h
    ACCOUNT_LIBRARY_FILE=$<TARGET_FILE:account>
    ${PYTHON_EXECUTABLE}
    ${CMAKE_CURRENT_SOURCE_DIR}/account/test.py
  )
```

## Catch2 Test
Catch2是一个C++的测试框架。
### Catch2的安装
```bash
git clone -b v3.3.2 https://github.com/catchorg/Catch2.git

cd Catch2
mkdir -p build&&cd build
cmake ..
make && make install 
```
[Catch2在cmake中的使用](https://github.com/catchorg/Catch2/blob/devel/docs/cmake-integration.md#top )

### Catch2 CMake
1. 找到Catch2库
```cmake
find_package(Catch2 3 REQUIRED)
```
2. 测试文件链接到Catch2
```cmake
target_link_libraries(target_name 
            PRIVATE 
                Catch2::Catch2WithMain
)
```
3. 开启测试
```cmake
enable_testing()
```
4. 添加测试项
```cmake
add_test(
    NAME catch2_test
    COMMAND $<TARGET_FILE:target_name> --success
)
```
### 执行测试
```bash
ctest -v //测试时输出详细信息
或
make test //如果构建器是unix makefile
```
也可以测试二进制文件，`--success`是catch2的选项
```bash
./target_name --success
```
使用`-h`可以查看Catch2提供的选项
```bash
./target_name --help
```

## googleTest
Google Test框架不仅仅是一个头文件，也是一个库，包含两个需要构建和链接的文件(gtest gtest_main gmock gmock_main)。

使用`FetchContent`来获取第三方库，并链接。（不用安装，更加轻量级）。

### 获取googletest
```cmake
include(FetchContent)
FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG v1.13.0
)
#使gtest可用
FetchContent_MakeAvailable(googletest)
```
[googletest在cmake中的使用](https://google.github.io/googletest/quickstart-cmake.html)

### 测试项链接到googletest
```cmake
target_link_libraries(test_target
  PRIVATE
    gtest_main
)
```
### 启动测试项
```cmake
enable_testing()
add_test(
  NAME google_test
  COMMAND $<TARGET_FILE:test_target>
)
```

## Boost Test
Boost是c++社区非常流行的测试框架。
### 安装Boost
```bash
apt-get  install libboost-all-dev
```
### 查找boost库并链接
```cmake
find_package(Boost 1.74 REQUIRED COMPONENTS unit_test_framework)

target_link_libraries(
    test_target
    PRIVATE
        Boost::unit_test_framework
)
```
### 给测试文件添加main函数的定义
```cmake
target_compile_definitions(
    test_target
    PRIVATE
        BOOST_TEST_DYN_LINK
)
```
### 启用测试项
```cmake
enable_testing()
add_test(
  NAME boost_test
  COMMAND $<TARGET_FILE:test_target>
)
```
### 测试
```bash
make test //如果构建器为unix makefile
或
ctest -vv
```

## 使用动态分析检测内存缺陷
内存缺陷：写入或读取越界，或者内存泄漏(已分配但从未释放的内存)，会产生难以跟踪的bug

Valgrind 是一个通用的工具，用来检测内存缺陷和内存泄漏。
### valgrind安装
```bash
apt-get install valgrind
```

### 定义测试目标和`MEMORYCHECK_COMMAND`
```cmake
# 查找valgrind，并将MEMORYCHECK_COMMAND设置为其绝对路径
find_program(MEMORYCHECK_COMMAND NAMES valgrind)
# 将相关参数传递给valgrind
set(MEMORYCHECK_COMMAND_OPTIONS "--trace-children=yes --leak-check=full")
```
### 添加内存检测到ctest中
```cmake
#显示添加CTest模块启用memcheck
include(CTest)
```
### 开启测试
```cmake
enable_testing()
add_test(
  NAME test_target_name
  COMMAND $<TARGET_FILE:test_target>
  )
```

### 检查内存缺陷
```bash
ctest -T memcheck
```
## 预期测试失败的测试项
在某些情况，我们就是测试希望测试失败的测试项。即指定测试失败的项为成功。
- 当使用测试框架(gtest boost catch2)时，可以通过测试框架进行设置。
- 当不使用框架时，设定该测试项的选项即可。

### 设置测试项失败为成功
```cmake
# 将属性WILL_FAIL设置为true,将转换成功与失败
set_tests_properties(test_target PROPERTIES WILL_FAIL true)
```
如果需要更大的灵活性，可以将测试属性`PASS_REGULAR_EXPRESSION`和`FAIL_REGULAR_EXPRESSION`与`set_tests_properties`组合使用。如果设置了这些参数，测试输出将根据参数给出的正则表达式列表进行检查，如果匹配了正则表达式，测试将通过或失败。

## 设置超时测试运行时间过长的测试
设置超时来终止耗时过长的测试。
```cmake
# 超过10s即测试失败
set_tests_properties(test_target_name PROPERTIES TIMEOUT 10)
```
## 并行测试
使用多核来减少测试时间。
执行测试时，可以使用以下命令，利用多核进行测试。
```bash
ctest --parallel N
```
或者在CMakeLists.txt中将`CTEST_PARALLEL_LEVEL`设置为所需要的级别即可。
例如：
```cmake
set(CTEST_PARALLEL_LEVEL 4)
```
### 并行测试须知
- 不并行测试时，测试顺序执行
- 当第一次并行测试时，测试顺序执行
- 当非第一次并行测试时，测试从耗时最长的测试项开始进行
- cmake会记录各个对应测试项的测试时间，在非第一次测试时，会从耗时最长的开始执行。
- 可以通过`set_tests_properties`来预先评估测试时间，以便cmake自动从最长的测试项开始测试。（即使时首次测试）

例如：
```cmake
set_tests_properties(
    test_target
    PROPERTIES COST 2.5
)
```
## 测试子集
有时不需要运行所有测试项，可以使用测试子集。
- 通过添加测试项的标签，从而可以只测试部分项。
```cmake
ctest --parallel 4 -L myLabel
```
- 也可以通过名称只测试部分
```
ctest --parallel 4 -R testName
```
- 当在CMakeLists.txt中添加测试项后，cmake会自动为每个测试项设置编号，从1开始。可以指定测试项编号进行测试
```
ctest --parallel 4 -I 3,5
```
### 为测试项添加测试标签
```
set_test_properties(
  test_target
  PROPERTIES
    LABELS "myLabel"
)
```
## 使用测试固件
有时在测试前需要进行某些操作，在测试完成后需要执行某些操作。这些都可以通过测试固件绑定测试项完成。
例如：
```
add_test(
  NAME setup
  COMMAND ${PYTHON_EXECUTABLE} setup.py
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/test/
  )
set_tests_properties(
  setup
  PROPERTIES
      FIXTURES_SETUP my-fixture
  )
add_test(
  NAME feature-a
  COMMAND ${PYTHON_EXECUTABLE} feature-a.py
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/test/

)
add_test(
  NAME feature-b
  COMMAND ${PYTHON_EXECUTABLE} feature-b.py
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/test/

)
set_tests_properties(
  feature-a
  feature-b
  PROPERTIES
      FIXTURES_REQUIRED my-fixture
  )
add_test(
  NAME cleanup
  COMMAND ${PYTHON_EXECUTABLE} cleanup.py
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/test/
)
set_tests_properties(
  cleanup
  PROPERTIES
      FIXTURES_CLEANUP my-fixture
  )
```
- setup为测试时的前置操作，cleanup为测试后所需要进行的操作。
- 定义了一个my-fixture的测试固件，该测试固件设定了 `FIXTURES_SETUP`和`FIXTURES_CLEANUP`属性。
- 将测试固件绑定到feature-a和feature-b,并设定为必须(`FIXTURES_REQUIRED`)
  
上述例子，在测试执行前会执行setup操作，测试完成后会执行cleanup操作。










