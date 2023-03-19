cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(08GeneratorExpression LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

option(USE_MPI "Use MPI parallelization" ON)
if(USE_MPI)
    # find MPI lib
    find_package(MPI REQUIRED)
endif()
# generate execute
add_executable(example ${CMAKE_CURRENT_SOURCE_DIR}/src/example.cpp)
#link MPI lib
target_link_libraries(example
  PUBLIC
      $<$<BOOL:${MPI_FOUND}>:MPI::MPI_CXX>
)
#set definitions
target_compile_definitions(example
  PRIVATE
      $<$<BOOL:${MPI_FOUND}>:HAVE_MPI>
)
if(MPI_FOUND)
  #print MPI properties
  include(CMakePrintHelpers)
  cmake_print_properties(
    TARGETS MPI::MPI_CXX
    PROPERTIES INTERFACE_LINK_LIBRARIES
    )
endif()