cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(findOpenMP LANGUAGES CXX)
find_package(OpenMP REQUIRED)
# generate exacutable program
add_executable(example example.cpp)
set_target_properties(example
    PROPERTIES
    CXX_EXTENSIONS OFF
    CXX_STANDARD 11
    CXX_STANDARD_REQUIRED ON
)
target_link_libraries(example
  PUBLIC
      OpenMP::OpenMP_CXX
)
## use CMakePrintHelpers print OpenMP compiler symbol and so on
include(CMakePrintHelpers)
cmake_print_properties(
    TARGETS
        OpenMP::OpenMP_CXX
    PROPERTIES
        INTERFACE_COMPILE_OPTIONS
        INTERFACE_INCLUDE_DIRECTORIES
        INTERFACE_LINK_LIBRARIES
)
