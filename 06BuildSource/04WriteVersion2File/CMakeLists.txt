cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(04WriteVersion2File LANGUAGES CXX)

# read version info
if(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/src/VERSION")
    file(READ "${CMAKE_CURRENT_SOURCE_DIR}/src/VERSION" PROGRAM_VERSION)
    string(STRIP "${PROGRAM_VERSION}" PROGRAM_VERSION)
else()
    message(FATAL_ERROR "File ${CMAKE_CURRENT_SOURCE_DIR}/src/VERSION not found")
endif()

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/src/version.hpp.in
  generated/version.hpp
  @ONLY
)

add_executable(example ${CMAKE_CURRENT_SOURCE_DIR}/src/example.cpp)
set_target_properties(example
    PROPERTIES
        CXX_STANDARD 11
        CXX_EXTENSIONS OFF
        CXX_STANDARD_REQUIRED ON
)
target_include_directories(example
  PRIVATE
      ${CMAKE_CURRENT_BINARY_DIR}/generated
  )