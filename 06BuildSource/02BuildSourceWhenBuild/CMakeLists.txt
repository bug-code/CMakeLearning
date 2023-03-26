cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(02BuildSourceWhenBuild LANGUAGES CXX)
find_package(PythonInterp REQUIRED)

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/generated)
set(MAX_NUMBER "100" CACHE STRING "Upper bound for primes")
add_custom_command(
  OUTPUT
      ${CMAKE_CURRENT_BINARY_DIR}/generated/primes.hpp
  COMMAND
      ${PYTHON_EXECUTABLE} generate.py ${MAX_NUMBER}     ${CMAKE_CURRENT_BINARY_DIR}/generated/primes.hpp
  WORKING_DIRECTORY
      ${CMAKE_CURRENT_SOURCE_DIR}/src
  DEPENDS
      ${CMAKE_CURRENT_SOURCE_DIR}/src/generate.py
)

add_executable(example "")
set_target_properties(example
    PROPERTIES
        CXX_STANDARD 11
        CXX_EXTENSIONS OFF
        CXX_STANDARD_REQUIRED ON
)
target_sources(example
  PRIVATE
      ${CMAKE_CURRENT_SOURCE_DIR}/src/example.cpp
      ${CMAKE_CURRENT_BINARY_DIR}/generated/primes.hpp
  )
target_include_directories(example
  PRIVATE
      ${CMAKE_CURRENT_BINARY_DIR}/generated
  )
