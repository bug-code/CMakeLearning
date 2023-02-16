cmake_minimum_required(VERSION 3.21.1 FATAL_ERROR)
project(setCompiler03 LANGUAGES C CXX)

message(STATUS "Is the C++ compiler loaded? ${CMAKE_CXX_COMPILER_LOADED}")
if(CMAKE_CXX_COMPILER_LOADED)
    message(STATUS "The C++ compiler ID is: ${CMAKE_CXX_COMPILER_ID}")
    #查询该语言的编译器是否为GNC编译器集合中的一个
    message(STATUS "Is the C++ from GNU? ${CMAKE_COMPILER_IS_GNUCXX}")
    message(STATUS "The C++ compiler version is: ${CMAKE_CXX_COMPILER_VERSION}")
endif()

message(STATUS "Is the C compiler loaded? ${CMAKE_C_COMPILER_LOADED}")
if(CMAKE_C_COMPILER_LOADED)
    message(STATUS "The C compiler ID is: ${CMAKE_C_COMPILER_ID}")
    #查询该语言的编译器是否为GNC编译器集合中的一个
    message(STATUS "Is the C from GNU? ${CMAKE_COMPILER_IS_GNUCC}")
    message(STATUS "The C compiler version is: ${CMAKE_C_COMPILER_VERSION}")
endif()

message(STATUS "Is the CUDA compiler loaded? ${CMAKE_CUDA_COMPILER_LOADED}")
if(CMAKE_CUDA_COMPILER_LOADED)
    message(STATUS "The CUDA compiler ID is: ${CMAKE_CUDA_COMPILER_ID}")
    message(STATUS "The CUDA compiler version is: ${CMAKE_CUDA_COMPILER_VERSION}")
endif()