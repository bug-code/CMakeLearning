cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(UseDeprecatedFunc LANGUAGES NONE)
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
include(include_guard)

custom_include_guard()


message(STATUS "list of all included modules: ${included_modules}")