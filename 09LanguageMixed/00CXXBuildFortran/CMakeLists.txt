cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(00CXXBUILDFORTRAN LANGUAGES Fortran C)
#设置生成的动态库和静态库保存在build目录下的lib目录下
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/lib)
# 设置生成的可执行文件保存在bin目录下
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/bin)
# Fortran编译模块保存在modules目录下
set(CMAKE_Fortran_MODULE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/modules)
#添加src的子目录
add_subdirectory(src)
