cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(Function LANGUAGES CXX C Fortran)
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

# 测试C++标志列表
set_compiler_flag(
  working_compile_flag CXX 
  "-foo" # this should fail
  "-g" # this should work with GNU, Intel, PGI
  "/RTCcsu" # this should work with MSVC
  )
message(STATUS "working CXX compile flag: ${working_compile_flag}")

