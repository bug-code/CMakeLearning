cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(02Gtest LANGUAGES CXX)

# example library
add_library(sum_integers sum_integers.cpp)
# main code
add_executable(sum_up main.cpp)
target_link_libraries(sum_up sum_integers)

#从链接下载gtest
include(FetchContent)
FetchContent_Declare(
    googletest
    GIT_REPOSITORY https://github.com/google/googletest.git
    GIT_TAG v1.13.0
)
#使gtest可用
FetchContent_MakeAvailable(googletest)

add_executable(cpp_test "")
target_sources(cpp_test
  PRIVATE
      test.cpp
)
target_link_libraries(cpp_test
  PRIVATE
    sum_integers
    gtest_main
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




