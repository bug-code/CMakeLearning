find_package(LAPACK)
if(LAPACK_FOUND)
  add_library(LAPACK_external INTERFACE)
else()
  message(NOTICE "no suitable lapack, Downloading and build")
  include(ExternalProject)
  ExternalProject_Add(
    LAPACK_external
    GIT_REPOSITORY https://github.com/Reference-LAPACK/lapack.git
    GIT_TAG v3.11.0
    UPDATE_COMMAND ""
    DOWNLOAD_NO_PROGRESS 1
    CMAKE_ARGS -DCMAKE_INSTALL_PREFIX=${STAGED_INSTALL_PREFIX}
    BUILD_ALWAYS 1)
  include(GNUInstallDirs)
  set(LAPACK_DIR
      ${STAGED_INSTALL_PREFIX}/lib/cmake
      CACHE PATH "path to internally built LAPACKCONFIG.cmake" FORCE)
  set(LAPACK_LIBRARIES
      ${STAGED_INSTALL_PREFIX}/lib/liblapack.a
      CACHE PATH "PATH to internally lib" FORCE)
  
  set(BLAS_LIBRARIES
      ${STAGED_INSTALL_PREFIX}/lib/libblas.a
      CACHE PATH "path to internally built library" FORCE)
endif()
