cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(findEigen LANGUAGES CXX)
find_package(OpenMP REQUIRED)
find_package(Eigen3 REQUIRED CONFIG)
#print Eigen status
if(TARGET Eigen3::Eigen)
  message(STATUS "Eigen3 v${EIGEN3_VERSION_STRING} found in ${EIGEN3_INCLUDE_DIR}")
endif()

add_executable(linear-algebra linear-algenbra.cpp)
set_target_properties(linear-algebra
    PROPERTIES
    CXX_EXTENSIONS OFF
    CXX_STANDARD 11
    CXX_STANDARD_REQUIRED ON
)
find_package(BLAS)
#if find BLAS，offload the matrix function compute to BLAS 
if(BLAS_FOUND)
  message(STATUS "Eigen will use some subroutines from BLAS.")
  message(STATUS "See: http://eigen.tuxfamily.org/dox-devel/TopicUsingBlasLapack.html")
  target_compile_definitions(linear-algebra
    PRIVATE
        EIGEN_USE_BLAS
    )
  target_link_libraries(linear-algebra
    PUBLIC
        ${BLAS_LIBRARIES}
    )
else()
    message(STATUS "BLAS not found. Using Eigen own functions")
endif()

# set compiler symbol and link flags
target_link_libraries(linear-algebra
  PUBLIC
    Eigen3::Eigen
    OpenMP::OpenMP_CXX
)

