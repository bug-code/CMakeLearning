cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)

project(04BoostTest LANGUAGES CXX)
#生成库文件
add_library(sum_integers sum_integers.cpp)
#创建可执行程序main
add_executable(sum_up main.cpp)
target_link_libraries(sum_up sum_integers)

find_package(Boost 1.74 REQUIRED COMPONENTS unit_test_framework)
add_executable(cpp_test test.cpp)

set_target_properties(
    sum_integers
    sum_up
    cpp_test
    PROPERTIES
        CXX_EXTENSIONS OFF
        CXX_STANDARD 14
        CXX_STANDARD_REQUIRED ON
)

target_link_libraries(
    cpp_test
    PRIVATE
        sum_integers
        Boost::unit_test_framework
)

#给测试文件添加main函数的定义
target_compile_definitions(
    cpp_test
    PRIVATE
        BOOST_TEST_DYN_LINK
)

#开启测试
enable_testing()
add_test(
  NAME boost_test
  COMMAND $<TARGET_FILE:cpp_test>
)