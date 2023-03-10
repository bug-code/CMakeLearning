cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(DIYTest LANGUAGES CXX)
find_package(PythonInterp REQUIRED)
find_program(BASH_EXECUTABLE NAMES bash REQUIRED)

# example library
add_library(sum_integers sum_integers.cpp)
# main code
add_executable(sum_up main.cpp)
target_link_libraries(sum_up sum_integers)
# testing binary
add_executable(cpp_test test.cpp)
target_link_libraries(cpp_test sum_integers)

set_target_properties(
    sum_integers
    sum_up
    cpp_test
    PROPERTIES
        CXX_EXTENSIONS OFF
        CXX_STANDARD 11
        CXX_STANDARD_REQUIRED ON
)

# enable test
enable_testing()
add_test(
  NAME bash_test
  COMMAND ${BASH_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/test.sh $<TARGET_FILE:sum_up>
  )
add_test(
  NAME cpp_test
  COMMAND $<TARGET_FILE:cpp_test>
  )
add_test(
  NAME python/long
  COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/test.py --executable $<TARGET_FILE:sum_up>
  )
add_test(
  NAME python/short
  COMMAND ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/test.py --short --executable $<TARGET_FILE:sum_up>
  )