cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(FINDBLAS LANGUAGES C CXX Fortran)
#check Fortran and c/c++ compiler co-work
#generate head file to manage namespace confuse
include(FortranCInterface)
FortranCInterface_VERIFY(CXX)
FortranCInterface_HEADER(
  fc_mangle.h
  MACRO_NAMESPACE "FC_"
  SYMBOLS DSCAL DGESV
)
# find BLAS and LAPACK
find_package(BLAS REQUIRED)
find_package(LAPACK REQUIRED)
#add libraries which include the wrapper of BLAS and LAPACK source code
#link to LAPACK_LIBRARIES and BLAS_LIBRARIES
add_library(math "")
target_sources(math
  PRIVATE
    CxxBLAS.cpp
    CxxLAPACK.cpp
)
target_include_directories(math
  PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}
)
target_link_libraries(math
  PUBLIC
      ${LAPACK_LIBRARIES}
)
#generate exacutable which link to math
add_executable(linear-algebra "")
set_target_properties(linear-algebra
    PROPERTIES
    C_EXTENSIONS OFF
    C_STANDARD 11
    C_STANDARD_REQUIRED ON
)
target_sources(linear-algebra
  PRIVATE
      linear_algebra.cpp
)
target_link_libraries(linear-algebra
  PRIVATE
      math
)