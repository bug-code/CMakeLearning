set(CMAKE_DISABLE_FINND_PACKAGE_Boost "TRUE")
find_package(Boost ${Boost_MINIMUM_REQUIRED} QUIET COMPONENTS ${BOOST_COMPONENTS_REQUIRED})
if(Boost_FOUND)
    message(STATUS "Found Boost version ${Boost_MAJOR_VERSION}.${Boost_MINOR_VERSION}.${Boost_SUBMINOR_VERSION}")
    #如果找到boost库，则创建一个空的接口库
    add_library(boost_external INTERFACE)
else()
   
   message(STATUS "Boost ${Boost_MINIMUM_REQUIRED} could not be located, Building Boost 1.61.0 instead.")
   #检测编译环境
   if(CMAKE_CXX_COMPILER_ID MATCHES "GNU")
     if(APPLE)
         set(_toolset "darwin")
     else()
       set(_toolset "gcc")
     endif()
   elseif(CMAKE_CXX_COMPILER_ID MATCHES ".*Clang")
     set(_toolset "clang")
   elseif(CMAKE_CXX_COMPILER_ID MATCHES "Intel")
     if(APPLE)
         set(_toolset "intel-darwin")
     else()
         set(_toolset "intel-linux")
     endif()
   endif()

   if(NOT "${BOOST_COMPONENTS_REQUIRED}" STREQUAL "")
    # Replace unit_test_framework (used by CMake's find_package) with test (understood by Boost build toolchain)
     string(REPLACE "unit_test_framework" "test" _b2_needed_components "${BOOST_COMPONENTS_REQUIRED}")
     # Generate argument for BUILD_BYPRODUCTS
     set(_build_byproducts)#设置构建库的绝对路径
     set(_b2_select_libraries) #设置要依赖的组件
     
     foreach(_lib IN LISTS _b2_needed_components)
       list(APPEND _build_byproducts ${STAGED_INSTALL_PREFIX}/boost/lib/libboost_${_lib}${CMAKE_SHARED_LIBRARY_SUFFIX})
       list(APPEND _b2_select_libraries --with-${_lib})
     endforeach()
     
     # Transform the ;-separated list to a ,-separated list (digested by the Boost build toolchain!)
     string(REPLACE ";" "," _b2_needed_components "${_b2_needed_components}")
     set(_bootstrap_select_libraries "--with-libraries=${_b2_needed_components}")
     string(REPLACE ";" ", " printout "${BOOST_COMPONENTS_REQUIRED}")
     message(STATUS " Libraries to be built: ${printout}")
   endif()
   
   include(ExternalProject)
   ExternalProject_Add(boost_external
                       URL #设置下载链接
                           https://sourceforge.net/projects/boost/files/boost/1.61.0/boost_1_61_0.zip
                       URL_HASH #设置校验
                           SHA256=02d420e6908016d4ac74dfc712eec7d9616a7fc0da78b0a1b5b937536b2e01e8
                       DOWNLOAD_NO_PROGRESS
                           0
                       UPDATE_COMMAND
                          ""
                       CONFIGURE_COMMAND #配置命令
                          <SOURCE_DIR>/bootstrap.sh
                          --with-toolset=${_toolset}
                          --prefix=${STAGED_INSTALL_PREFIX}/boost
                          ${_bootstrap_select_libraries}
                       BUILD_COMMAND #构建命令 
                           <SOURCE_DIR>/b2 -q
                           link=shared
                           threading=multi
                           variant=release
                           toolset=${_toolset}
                           ${_b2_select_libraries}
                       LOG_BUILD
                         1
                       BUILD_IN_SOURCE
                         1

                       INSTALL_COMMAND #安装命令
                         <SOURCE_DIR>/b2 -q install
                         link=shared
                         threading=multi
                         variant=release
                         toolset=${_toolset}
                         ${_b2_select_libraries}
                       LOG_INSTALL #可选
                         1
                       BUILD_BYPRODUCTS
                         "${_build_byproducts}"
                      )
  # 设置变量以便cmake能查找到
   set(
       BOOST_ROOT ${STAGED_INSTALL_PREFIX}/boost
       CACHE PATH "Path to internally built Boost installation root"
       FORCE
       )
   set(
       BOOST_INCLUDEDIR ${BOOST_ROOT}/include
       CACHE PATH "Path to internally built Boost include directories"
       FORCE
     )
   set(
       BOOST_LIBRARYDIR ${BOOST_ROOT}/lib
       CACHE PATH "Path to internally built Boost library directories"
       FORCE
       )
   #取消本文件中的变量设置 
   unset(_toolset)
   unset(_b2_needed_components)
   unset(_build_byproducts)
   unset(_b2_select_libraries)
   unset(_boostrap_select_libraries)
endif()
