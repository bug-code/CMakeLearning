cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(03AddCustomTarget LANGUAGES CXX Fortran)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
add_subdirectory(deps)
add_executable(linear-algebra ${CMAKE_CURRENT_SOURCE_DIR}/src/linear-algebra.cpp)
target_link_libraries(linear-algebra
  PRIVATE
      math
)