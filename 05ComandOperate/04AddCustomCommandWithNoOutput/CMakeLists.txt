cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(04AddCustomCommandWithNoOutput LANGUAGES Fortran)
find_package(PythonInterp REQUIRED)
if(NOT CMAKE_BUILD_TYPE)
    set(CMAKE_BUILD_TYPE Release CACHE STRING "Build type" FORCE)
endif()
add_executable(example "")
target_sources(example
  PRIVATE
      ${CMAKE_CURRENT_SOURCE_DIR}/src/example.f90
)

add_custom_command(
  TARGET
      example
  PRE_LINK
      COMMAND
          ${PYTHON_EXECUTABLE}
          ${CMAKE_CURRENT_SOURCE_DIR}/src/echo_file.py
          ${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/example.dir/link.txt
  COMMENT
      "link line:"
  VERBATIM
)
