set(Message_src ${CMAKE_CURRENT_LIST_DIR}/src/Message.cpp)
add_library(Message SHARED ${Message_src})
set(Message_include ${CMAKE_CURRENT_LIST_DIR}/include/)
target_include_directories(Message 
  PUBLIC 
    ${Message_include}
    #添加导出的头文件所在路径
    ${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}/
)
set_target_properties(
  Message
  PROPERTIES
    #生成位置的代码
    POSITION_INDEPENDENT_CODE 1
    #隐藏所有符号，除非显示地标记了其他符号。
    CXX_VISIBILITY_PRESET hidden
    #隐藏内联函数的符号
    VISIBILITY_INLINES_HIDDEN 1
    OUTPUT_NAME "Message"
    #debug模式构建时，添加_d后缀
    DEBUG_POSTFIX "_d"
    #添加库的头文件
    PUBLIC_HEADER
    "${Message_include}/Message.hpp;${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}/MessageExport.h"
)

include(GenerateExportHeader)
generate_export_header(
  Message
  #设置生成的头文件和宏的名称
  BASE_NAME
  "Message"
  #设置导出宏的名称
  EXPORT_MACRO_NAME
  "Message_EXPORT"
  #设置导出头文件的名称
  EXPORT_FILE_NAME
  "${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}/MessageExport.h"
  #设置弃用宏的名称
  DEPRECATED_MACRO_NAME
  "Message_DEPRECATED"
  #设置不导出宏的名字
  NO_EXPORT_MACRO_NAME
  "Message_NO_EXPORT"
  #用于定义宏的名称，以便使用相同源编译静态库时的使用
  STATIC_DEFINE
  "Message_STATIC_DEFINE"
  #设置宏的名称，在编译时将未来弃用的代码排除在外
  NO_DEPRECATED_MACRO_NAME
  "Message_NO_DEPRECATED"
  #指示CMAKE生成预处理器代码，以从编译中排除未来弃用的代码
  DEFINE_NO_DEPRECATED)

# 生成静态库
add_library(Message_static STATIC "")
target_sources(Message_static PRIVATE ${CMAKE_CURRENT_LIST_DIR}/src/Message.cpp)

target_compile_definitions(Message_static PUBLIC message_STATIC_DEFINE)
target_include_directories(Message_static
  PUBLIC
    ${Message_include}
    ${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}/)

set_target_properties(
  Message_static
  PROPERTIES
    POSITION_INDEPENDENT_CODE 1
    #设置静态库的名称
    ARCHIVE_OUTPUT_NAME "Message"
    DEBUG_POSTFIX "_sd"
    RELEASE_POSTFIX "_s"
    PUBLIC_HEADER
    "${Message_include}/Message.hpp;${CMAKE_BINARY_DIR}/${INSTALL_INCLUDEDIR}/MessageExport.h")

install(
  TARGETS Message Message_static
  ARCHIVE DESTINATION ${INSTALL_LIBDIR} COMPONENT lib
  RUNTIME DESTINATION ${INSTALL_BINDIR} COMPONENT bin
  LIBRARY DESTINATION ${INSTALL_LIBDIR} COMPONENT lib
  PUBLIC_HEADER DESTINATION ${INSTALL_INCLUDEDIR}/message COMPONENT dev)
