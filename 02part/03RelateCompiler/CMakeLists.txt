cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(RelateCompiler LANGUAGES CXX)
add_executable(HelloWorld HelloWorld.cpp)
# 为源项目定义编译器名称的宏定义
target_compile_definitions(HelloWorld PUBLIC "COMPILER_NAME=\"${CMAKE_CXX_COMPILER_ID}\"")
# 定义源项目中使用的宏定义 IS_XXX_CXX_COMPILER
target_compile_definitions(HelloWorld PUBLIC "IS_${CMAKE_CXX_COMPILER_ID}_CXX_COMPILER")

