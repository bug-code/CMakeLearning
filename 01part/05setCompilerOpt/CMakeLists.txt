cmake_minimum_required(VERSION 3.21.5 FATAL_ERROR)
set(CMAKE_CXX_COMPILER "/usr/local/corex/bin/clang++")
set(CMAKE_C_COMPILER "/usr/local/corex/bin/clang")
project(setCompilerOpt LANGUAGES C CXX)

if(CMAKE_CXX_COMPILER_LOADED)
  message(STATUS "c++ compiler: ${CMAKE_CXX_COMPILER_ID}")
  #整个项目的编译选项
  message(STATUS "C++ flag:${CMAKE_CXX_FLAGS}")
endif()

#设置整个项目的编译选项
list(APPEND setCompilerOpt_flags "-fPIC" "-Wall")
if(NOT WIN32)
  list(APPEND setCompilerOpt_flags "-Wextra" "-Wpedantic")
endif()

#设置geometry生成库类型
include(CMakeDependentOption)
cmake_dependent_option(
  use_geometry_shared "use geometry shared" 1
  use_geometry_static "use geometry static" 0
)
#设置geometry编译选项
set(geometry_CXX_compiler_flags "-fno-rtti" "-fno-exceptions")
set(geometry_CXX_compiler_flags_debug)
set(geometry_CXX_compiler_flags_release "-O3" "-Wno-unused")
if(CMAKE_CXX_COMPILER_ID MATCHES GNU)
  list(APPEND geometry_CXX_compiler_flags_debug "-Wsuggest-final-types" "-Wsuggest-final-methods" "-Wsuggest-override")
endif()
if(CMAKE_CXX_COMPILER_ID MATCHES Clang)
  list(APPEND geometry_CXX_compiler_flags "-Qunused-arguments" "-fcolor-diagnostics")
  list(APPEND geometry_CXX_compiler_flags_debug "-Wdocumentation")
endif()

#生成动态库
if(use_geometry_shared)
  add_library(geometry
  SHARED
    ${CMAKE_CURRENT_SOURCE_DIR}/src/geometry_circle.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/geometry_polygon.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/geometry_rhombus.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/geometry_square.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/geometry_circle.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/geometry_polygon.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/geometry_rhombus.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/geometry_square.cpp
  )  
elseif(use_geometry_static)
#生成静态库
  add_library(geometry
  STATIC
    ${CMAKE_CURRENT_SOURCE_DIR}/src/geometry_circle.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/geometry_polygon.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/geometry_rhombus.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/geometry_square.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/geometry_circle.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/geometry_polygon.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/geometry_rhombus.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/geometry_square.cpp
  )
endif()

#设置库的输出路径
set(LIBRARY_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/lib)
#设置库编译选项
target_compile_options(geometry 
  PRIVATE
    ${geometry_CXX_compiler_flags}
    "$<$<CONFIG:Debug>:${geometry_CXX_compiler_flags_debug}>"
    "$<$<CONFIG:Release>:${geometry_CXX_compiler_flags_release}>"
)
#使用foreach对特定文件进行其他优化(主要是学习foreach使用)
list(APPEND
  sources_with_lower_optimization
  ${CMAKE_CURRENT_SOURCE_DIR}/src/geometry_circle.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/src/geometry_rhombus.cpp
)

message(STATUS "Setting source properties using IN LISTS syntax:")
foreach(_source IN LISTS sources_with_lower_optimization)
  set_source_files_properties(${_source} PROPERTIES COMPILE_FLAGS -O2)
  message(STATUS "Appending -O2 flag for ${_source}")
endforeach()

#设置可执行文件输出目录
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/bin)
#项目生成可执行文件
add_executable(compute-areas ${CMAKE_CURRENT_SOURCE_DIR}/src/compute-areas.cpp)
#为compute-areas设置编译选项
target_compile_options(compute-areas
  PRIVATE
    ${setCompilerOpt_flags}
)
#链接geometry库
target_link_libraries(compute-areas geometry)



