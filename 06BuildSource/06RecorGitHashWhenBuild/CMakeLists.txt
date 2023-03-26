cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(06RecordGitHashWhenBuild LANGUAGES CXX)

add_executable(
    example
    ${CMAKE_CURRENT_SOURCE_DIR}/src/example.cpp
)
target_include_directories(example
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/src/generated
)
add_custom_command(
 OUTPUT
     ${CMAKE_CURRENT_BINARY_DIR}/generated/version.hpp
 ALL
 COMMAND
     ${CMAKE_COMMAND} -D TARGET_DIR=${CMAKE_CURRENT_BINARY_DIR} -P ${CMAKE_CURRENT_SOURCE_DIR}/src/git_hash.cmake
 WORKING_DIRECTORY
     ${CMAKE_CURRENT_SOURCE_DIR}/src
 )
# rebuild version.hpp every time
add_custom_target(
 get_git_hash
 ALL
 DEPENDS
     ${CMAKE_CURRENT_BINARY_DIR}/generated/version.hpp
 )
# version.hpp has to be generated
# before we start building example
add_dependencies(example get_git_hash)
