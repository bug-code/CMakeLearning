cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(02AddCustomCommand LANGUAGES CXX Fortran)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
#find BLAS and LAPACK
find_package(BLAS REQUIRED)
find_package(LAPACK REQUIRED)
# set val which include source files
set(wrap_BLAS_LAPACK_sources
  ${CMAKE_CURRENT_BINARY_DIR}/wrap_BLAS_LAPACK/CxxBLAS.hpp
  ${CMAKE_CURRENT_BINARY_DIR}/wrap_BLAS_LAPACK/CxxBLAS.cpp
  ${CMAKE_CURRENT_BINARY_DIR}/wrap_BLAS_LAPACK/CxxLAPACK.hpp
  ${CMAKE_CURRENT_BINARY_DIR}/wrap_BLAS_LAPACK/CxxLAPACK.cpp
)
# unpack package provided
add_custom_command(
  OUTPUT
      ${wrap_BLAS_LAPACK_sources}
  COMMAND
      ${CMAKE_COMMAND} -E tar xzf ${CMAKE_CURRENT_SOURCE_DIR}/wrap_BLAS_LAPACK.tar.gz
  COMMAND
      ${CMAKE_COMMAND} -E touch ${wrap_BLAS_LAPACK_sources}
  WORKING_DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}
  DEPENDS
      ${CMAKE_CURRENT_SOURCE_DIR}/wrap_BLAS_LAPACK.tar.gz
  COMMENT
      "Unpacking C++ wrappers for BLAS/LAPACK"
  VERBATIM
)

# build libraries
add_library(math "")
target_sources(math
  PRIVATE
      ${CMAKE_CURRENT_BINARY_DIR}/wrap_BLAS_LAPACK/CxxBLAS.cpp
      ${CMAKE_CURRENT_BINARY_DIR}/wrap_BLAS_LAPACK/CxxLAPACK.cpp
  PUBLIC
      ${CMAKE_CURRENT_BINARY_DIR}/wrap_BLAS_LAPACK/CxxBLAS.hpp
      ${CMAKE_CURRENT_BINARY_DIR}/wrap_BLAS_LAPACK/CxxLAPACK.hpp
  )
target_include_directories(math
  INTERFACE
      ${CMAKE_CURRENT_BINARY_DIR}/wrap_BLAS_LAPACK
  )
target_link_libraries(math
  PUBLIC
      ${LAPACK_LIBRARIES}
)
# build target
add_executable(linear-algebra ${CMAKE_CURRENT_SOURCE_DIR}/src/linear-algebra.cpp)
target_link_libraries(linear-algebra
  PRIVATE
      math
)