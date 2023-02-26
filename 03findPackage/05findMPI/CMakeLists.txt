cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(findMPI LANGUAGES C CXX Fortran)
find_package(MPI REQUIRED)
add_executable(hello-mpi hello-mpi.cpp)
set_target_properties(hello-mpi 
    PROPERTIES
    CXX_EXTENSIONS OFF
    CXX_STANDARD 11
    CXX_STANDARD_REQUIRED ON
)
target_link_libraries(hello-mpi
    PUBLIC
    MPI::MPI_CXX
)