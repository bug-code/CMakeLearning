# 设置满足条件的cmake最小版本
cmake_minimum_required(VERSION 3.25 FATAL_ERROR)
#设置项目名称，项目用到的语言
project(SingleSrc LANGUAGES CXX)
#生成可执行文件printHello, 添加源文件test01.cpp
add_executable(printHello test01.cpp)
