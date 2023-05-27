find_package(GTest CONFIG QUIET)

if(GTest_FOUND)
  add_library(GTest_external INTERFACE)
else()
  message(NOTICE "no suitable googletest, Downloading and building!")
  include(ExternalProject)
  ExternalProject_Add(
    GTest_external
    URL
       https://github.com/google/googletest/archive/refs/tags/v1.13.0.tar.gz
    UPDATE_COMMAND
      ""
    DOWNLOAD_NO_PROGRESS
      0
    LOG_CONFIGURE
      1
    LOG_BUILD
      1
    LOG_INSTALL
      1
    BUILD_IN_SOURCE
      1
    CMAKE_ARGS
      -DCMAKE_INSTALL_PREFIX=${STAGED_INSTALL_PREFIX}
      -DGTEST_HAS_PTHREAD=1
      -DGTEST_LINKED_AS_SHARED_LIBRARY=1
      -DGTEST_CREATE_SHARED_LIBRARY=1
    BUILD_ALWAYS
      1
  )
  include(GNUInstallDirs)
  set(GTest_DIR
      ${STAGED_INSTALL_PREFIX}/lib/cmake/GTest/
      CACHE PATH "path to internally built GTESTCONFIG.cmake"
      FORCE
    )
endif()
