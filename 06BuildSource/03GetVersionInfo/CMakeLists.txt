cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(03GetVersionInfo VERSION 0.0.0 LANGUAGES C)

configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/version.h.in
  generated/version.h
  @ONLY
)
add_executable(example "")
target_sources(example 
    PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/example.c 
)
target_include_directories(example
  PRIVATE
      ${CMAKE_CURRENT_BINARY_DIR}/generated
  )