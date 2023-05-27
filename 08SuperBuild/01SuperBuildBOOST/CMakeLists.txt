cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
project(SuperBuildDep LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
#给目录设置超级构建属性
set_property(DIRECTORY PROPERTY EP_BASE ${CMAKE_BINARY_DIR}/subprojects)
#安装构建树的依赖项
set(STAGED_INSTALL_PREFIX ${CMAKE_BINARY_DIR}/stage)
message(STATUS "${PROJECT_NAME} staged install: ${STAGED_INSTALL_PREFIX}")
#设置依赖组件
list(APPEND BOOST_COMPONENTS_REQUIRED Filesystem System)
set(Boost_MINIMUM_REQUIRED 1.61)
#包含子目录,包含boost库构建的cmake文件
add_subdirectory(external/upstream)
# 超级构建模式，构建和管理boost库
include(ExternalProject)
ExternalProject_Add(${PROJECT_NAME}_core
    DEPENDS  
      boost_external #添加项目依赖的boost库
    SOURCE_DIR  
      ${CMAKE_CURRENT_LIST_DIR}/src #项目源文件目录
    CMAKE_ARGS #添加编译选项
      -DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}
      -DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}
      -DCMAKE_CXX_EXTENSIONS=${CMAKE_CXX_EXTENSIONS}
      -DCMAKE_CXX_STANDARD_REQUIRED=${CMAKE_CXX_STANDARD_REQUIRED}
    CMAKE_CACHE_ARGS
      -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
      #添加cmake查找boost的路径 
      -DCMAKE_INCLUDE_PATH:PATH=${BOOST_INCLUDEDIR} 
      -DCMAKE_LIBRARY_PATH:PATH=${BOOST_LIBRARYDIR}
    BUILD_ALWAYS
      1
    INSTALL_COMMAND
      ""
)

