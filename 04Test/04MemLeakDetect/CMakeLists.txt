cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(04MemLeakDetect LANGUAGES CXX)

add_library(example_library leaky_implementation.cpp)

add_executable(cpp_test test.cpp)
target_link_libraries(cpp_test PRIVATE example_library)

set_target_properties(
    example_library
    cpp_test
    PROPERTIES
        CXX_EXTENSIONS OFF
        CXX_STANDARD 11
        CXX_STANDARD_REQUIRED ON
)

# 定义测试目标，同时定义`MEMORYCHECK_COMMAND`
find_program(MEMORYCHECK_COMMAND NAMES valgrind)
set(MEMORYCHECK_COMMAND_OPTIONS "--trace-children=yes --leak-check=full")
# add memcheck test action
include(CTest)
enable_testing()
add_test(
  NAME cpp_test
  COMMAND $<TARGET_FILE:cpp_test>
  )