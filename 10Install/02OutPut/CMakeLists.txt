cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(IfelseOption LANGUAGES C CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# 设置GNU标准安装路径
include(GNUInstallDirs)
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY
    ${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY
    ${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_LIBDIR})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY
    ${PROJECT_BINARY_DIR}/${CMAKE_INSTALL_BINDIR})

# 配置新的非cmake系统变量设置安装位置 Offer the user the choice of overriding the installation
# directories
set(INSTALL_LIBDIR
    ${CMAKE_INSTALL_LIBDIR}
    CACHE PATH "Installation directory for libraries")
set(INSTALL_BINDIR
    ${CMAKE_INSTALL_BINDIR}
    CACHE PATH "Installation directory for executables")
set(INSTALL_INCLUDEDIR
    ${CMAKE_INSTALL_INCLUDEDIR}
    CACHE PATH "Installation directory for header files")

set(DEF_INSTALL_CMAKEDIR share/cmake/)

set(INSTALL_CMAKEDIR
    ${DEF_INSTALL_CMAKEDIR}
    CACHE PATH "Installation directory for CMake files")

# 报告组件安装位置 Report to user
foreach(p LIB BIN INCLUDE CMAKE)
  file(TO_NATIVE_PATH ${CMAKE_INSTALL_PREFIX}/${INSTALL_${p}DIR} _path)
  message(STATUS "Installing ${p} components to ${_path}")
  unset(_path)
endforeach()

# 设置可执行文件的 RPATH
file(RELATIVE_PATH _rel ${CMAKE_INSTALL_PREFIX}/${INSTALL_BINDIR}
     ${CMAKE_INSTALL_PREFIX})

set(_rpath "\$ORIGIN/${_rel}")

# 添加第三方库
add_subdirectory(thirdPart)
file(TO_NATIVE_PATH "${_rpath}/${INSTALL_LIBDIR}" message_RPATH)

# 生成可执行文件

add_executable(hello_world ${CMAKE_CURRENT_LIST_DIR}/src/Helloworld.cpp)
target_link_libraries(hello_world PUBLIC Message)

set_target_properties(
  hello_world
  PROPERTIES 
             SKIP_BUILD_RPATH OFF
             BUILD_WITH_INSTALL_RPATH OFF
             INSTALL_RPATH "${message_RPATH}"
             INSTALL_RPATH_USE_LINK_PATH ON)

install(
  TARGETS hello_world
  DESTINATION ${INSTALL_BINDIR}
  COMPONENT bin)
