cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(VecForEigen LANGUAGES CXX)
#set language standard option
# set(CMAKE_CXX_STANDARD 11)
# set(CMAKE_CXX_EXTENSIONS OFF)
# set(CMAKE_CXX_STANDARD_REQUIRED ON)

find_package(Eigen3 3.4.0 REQUIRED CONFIG)
# add standard Moulde file
include(CheckCXXCompilerFlag)
#check compiler option
check_cxx_compiler_flag("-march=native" _march_native_works)
check_cxx_compiler_flag("-xHost" _xhost_works)

#add compiler option flexibly
set(_CXX_FLAGS)
if(_march_native_works)
    message(STATUS "Using processor's vector instructions (-march=native compiler flag set)")
    set(_CXX_FLAGS "-march=native")
elseif(_xhost_works)
    message(STATUS "Using processor's vector instructions (-xHost compiler flag set)")
    set(_CXX_FLAGS "-xHost")
else()
    message(STATUS "No suitable compiler flag found for vectorization")
endif()

# generate exacutable without compiler optimization
add_executable(linear-algebra-unoptimized linear-algebra.cpp)
target_link_libraries(linear-algebra-unoptimized
  PRIVATE
      Eigen3::Eigen
  )

# generate exacutable with compiler optimization
add_executable(linear-algebra linear-algebra.cpp)
set_target_properties(linear-algebra PROPERTIES
                        CMAKE_CXX_STANDARD 17
                        CMAKE_CXX_EXTENSIONS OFF
                        MAKE_CXX_STANDARD_REQUIRED ON)
target_compile_options(linear-algebra
  PRIVATE
      ${_CXX_FLAGS}
  )
target_link_libraries(linear-algebra
  PRIVATE
      Eigen3::Eigen
  )