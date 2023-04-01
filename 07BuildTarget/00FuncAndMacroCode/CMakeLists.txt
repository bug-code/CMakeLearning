cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(FuncAndMacroCode LANGUAGES CXX)

find_package(Catch2 3 REQUIRED)
#根据GNU标准定义`binary`和`library`
include(GNUInstallDirs)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY
    ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY
    ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY
    ${CMAKE_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})

#添加子目录
add_subdirectory(src)
enable_testing()
add_subdirectory(tests)

