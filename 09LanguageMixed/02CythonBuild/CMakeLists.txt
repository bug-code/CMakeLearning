cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(recipe-03 LANGUAGES CXX)
#设置  C++ 标准
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
#设置构建模式
if(NOT CMAKE_BUILD_TYPE)
      set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()

find_package(PythonInterp REQUIRED)

# cmake 追加cython查找模块
list(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake-cython)
# 添加UseCython模块
include(UseCython)
# 设置源文件属性，CYTHON_IS_CXX源文件属性设置为TRUE，以便cython_add_module函数知道如何将pyx作为C++文件进行编译
set_source_files_properties(account.pyx PROPERTIES CYTHON_IS_CXX TRUE)
# 创建Cython模块
cython_add_module(account account.pyx account.cpp)
# 添加头文件
target_include_directories(account
    PRIVATE
          ${CMAKE_CURRENT_SOURCE_DIR}
)

# 启用测试
enable_testing()
# define test
add_test(
    NAME
      python_test
    COMMAND
      ${CMAKE_COMMAND} -E env ACCOUNT_MODULE_PATH=$<TARGET_FILE_DIR:account>
      #指定测试文件路径
      ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/test.py
)
