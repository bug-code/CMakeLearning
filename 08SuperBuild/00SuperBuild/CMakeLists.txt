cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(SuperBuild LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

set_property(DIRECTORY PROPERTY EP_BASE ${CMAKE_BINARY_DIR}/subproject)

include(ExternalProject)
ExternalProject_Add(HelloWorld
                    SOURCE_DIR
                        ${CMAKE_CURRENT_LIST_DIR}/src
                    CMAKE_ARGS
                        -DCMAKE_CXX_COMPILE=${CMAKE_CXX_COMPILER}
                        -DCMAKE_CXX_STANDARD=${CMAKE_CXX_STANDARD}
                        -DCMAKE_CXX_EXTENSIONS=${CMAKE_CXX_EXTENSIONS}
                        -DCMAKE_CXX_STANDARD_REQUIRED=${CMAKE_CXX_STANDARD_REQUIRED}
                    CMAKE_CACHE_ARGS
                        -DCMAKE_CXX_FLAGS:STRING=${CMAKE_CXX_FLAGS}
                    BUILD_ALWAYS
                        1
                    INSTALL_COMMAND
                        ""
)

