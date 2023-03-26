# in case Git is not available, we default to "unknown"
set(GIT_HASH "unknown")
# find Git and if available set GIT_HASH variable
find_package(Git QUIET REQUIRED)
if(GIT_FOUND)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} log -1 --pretty=format:%h
    OUTPUT_VARIABLE GIT_HASH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
    WORKING_DIRECTORY
        ${CMAKE_CURRENT_SOURCE_DIR}
  )
endif()
message(STATUS "Git hash is ${GIT_HASH}")
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/generated)
# generate file version.hpp based on version.hpp.in
configure_file(
  version.hpp.in
  ${CMAKE_BINARY_DIR}/generated/version.hpp
  @ONLY
)