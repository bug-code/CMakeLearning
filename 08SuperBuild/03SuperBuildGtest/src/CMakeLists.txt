cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(03SuperBuildGTest LANGUAGES CXX)

# example library
add_library(sum_integers sum_integers.cpp)
# main code
add_executable(sum_up main.cpp)
target_link_libraries(sum_up sum_integers)


find_package(GTest CONFIG REQUIRED ) 
add_executable(cpp_test "")
target_sources(cpp_test
  PRIVATE
      test.cpp
)
target_link_libraries(cpp_test
  PRIVATE
    sum_integers
    GTest::gtest_main
)

set_target_properties(
  sum_integers
  sum_up
  cpp_test
  PROPERTIES
    CXX_STANDARD 14
    CXX_EXTENSIONS OFF
    CXX_STANDARD_REQUIRED ON
)

#启用gtest
enable_testing()
add_test(
  NAME google_test
  COMMAND $<TARGET_FILE:cpp_test>
  )
