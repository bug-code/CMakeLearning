cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(05RecordGitHash LANGUAGES CXX)


# in case Git is not available, we default to "unknown"
set(GIT_HASH "unknown")
# find Git and if available set GIT_HASH variable
find_package(Git QUIET)
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

# generate file version.hpp based on version.hpp.in
configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/src/version.hpp.in
  generated/version.hpp
  @ONLY
  )
# example code
add_executable(example ${CMAKE_CURRENT_SOURCE_DIR}/src/example.cpp)

set_target_properties(example
    PROPERTIES
        CXX_STANDARD 11
        CXX_EXTENSIONS OFF
        CXX_STANDARD_REQUIRED ON
)
# needs to find the generated header file
target_include_directories(example
  PRIVATE
      ${CMAKE_CURRENT_BINARY_DIR}/generated
  )