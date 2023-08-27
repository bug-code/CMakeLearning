set(Message_src ${CMAKE_CURRENT_LIST_DIR}/src/Message.cpp)
set(Message_include ${CMAKE_CURRENT_LIST_DIR}/include/)
add_library(Message SHARED ${Message_src})
target_include_directories(
  Message PUBLIC
    #只有在项目中使用了该库，下列生成器表达式才会扩展成
    #${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}
    #即在构建中才会展开
    $<BUILD_INTERFACE:${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}>
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include/>
    #只有在安装时才会展开下列生成器表达式
    #即该Message库作为另一个构建树中的依赖目标时才会展开
    $<INSTALL_INTERFACE:${INSTALL_INCLUDEDIR}>)

target_compile_definitions(Message
  INTERFACE
  $<INSTALL_INTERFACE:USING_Message>
  )

set_target_properties(
  Message
  PROPERTIES
    POSITION_INDEPENDENT_CODE 1
    CXX_VISIBILITY_PRESET hidden
    VISIBILITY_INLINES_HIDDEN 1
    OUTPUT_NAME "Message"
    DEBUG_POSTFIX "_d"
    PUBLIC_HEADER
    "${Message_include}/Message.hpp;${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}/MessageExport.h"
)
include(GenerateExportHeader)
generate_export_header(
  Message
  # 设置生成的头文件和宏的名称
  BASE_NAME
  "Message"
  # 设置导出宏的名称
  EXPORT_MACRO_NAME
  "Message_EXPORT"
  # 设置导出头文件的名称
  EXPORT_FILE_NAME
  "${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}/MessageExport.h"
  # 设置弃用宏的名称
  DEPRECATED_MACRO_NAME
  "Message_DEPRECATED"
  # 设置不导出宏的名字
  NO_EXPORT_MACRO_NAME
  "Message_NO_EXPORT"
  # 用于定义宏的名称，以便使用相同源编译静态库时的使用
  STATIC_DEFINE
  "Message_STATIC_DEFINE"
  # 设置宏的名称，在编译时将未来弃用的代码排除在外
  NO_DEPRECATED_MACRO_NAME
  "Message_NO_DEPRECATED"
  # 指示CMAKE生成预处理器代码，以从编译中排除未来弃用的代码
  DEFINE_NO_DEPRECATED)

install(
  TARGETS Message
  EXPORT MessageTargets
  ARCHIVE DESTINATION ${INSTALL_LIBDIR} COMPONENT lib
  RUNTIME DESTINATION ${INSTALL_BINDIR} COMPONENT bin
  LIBRARY DESTINATION ${INSTALL_LIBDIR} COMPONENT lib
  PUBLIC_HEADER DESTINATION ${INSTALL_INCLUDEDIR}/message COMPONENT dev)
# 安装生成的cmake
install(
  EXPORT MessageTargets
  FILE MessageTargets.cmake
  NAMESPACE Message::
  DESTINATION ${INSTALL_CMAKEDIR}/Message/
  COMPONENT dev)

# 生成正确的CMake配置文件
include(CMakePackageConfigHelpers)
write_basic_package_version_file(
  #设置生成文件的路径
  ${CMAKE_CURRENT_BINARY_DIR}/MessageConfigVersion.cmake
  #写入该库的版本号
  VERSION 0.0.1
  #设置该库的兼容性，即同Major的版本就能兼容
  COMPATIBILITY SameMajorVersion)

configure_package_config_file(
  #基于该模板生成实际的cmake配置文件
  ${CMAKE_CURRENT_LIST_DIR}/cmake/MessageConfig.cmake.in
  #生成的实际配置文件
  ${CMAKE_CURRENT_BINARY_DIR}/MessageConfig.cmake
  #设置配置文件的安装路径
  INSTALL_DESTINATION ${INSTALL_CMAKEDIR}/Message/)

# 安装生成的额配置文件
install(FILES 
              #安装两个生成的配置文件
              ${CMAKE_CURRENT_BINARY_DIR}/MessageConfig.cmake
              ${CMAKE_CURRENT_BINARY_DIR}/MessageConfigVersion.cmake
              DESTINATION ${INSTALL_CMAKEDIR}/Message)
