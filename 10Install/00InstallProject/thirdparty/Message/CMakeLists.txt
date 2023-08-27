set(Message_src ${CMAKE_CURRENT_LIST_DIR}/src/Message.cpp)
add_library(Message SHARED ${Message_src})
set(Message_include ${CMAKE_CURRENT_LIST_DIR}/include/)
target_include_directories(Message PUBLIC ${Message_include})

set_target_properties(
  Message
  PROPERTIES 
    POSITION_INDEPENDENT_CODE 1
    OUTPUT_NAME "Message"
    DEBUG_POSTFIX "_d"
    PUBLIC_HEADER ${Message_include}/Message.hpp
)

install(
    TARGETS
      Message
    ARCHIVE
      DESTINATION ${INSTALL_LIBDIR}
      COMPONENT lib
    RUNTIME
      DESTINATION ${INSTALL_BINDIR}
      COMPONENT bin
    LIBRARY
      DESTINATION ${INSTALL_LIBDIR}
      COMPONENT lib
    PUBLIC_HEADER
      DESTINATION ${INSTALL_INCLUDEDIR}/message
      COMPONENT dev
)
