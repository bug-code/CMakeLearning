cmake_minimum_required(VERSION 3.5 FATAL_ERROR)
project(CheckCompilerFlags LANGUAGES CXX)
set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

list(APPEND CXX_BASIC_FLAGS "-g3" "-O1")
include(CheckCXXCompilerFlag)
set(ASAN_FLAGS "-fsanitize=address -fno-omit-frame-pointer")
set(CMAKE_REQUIRED_FLAGS ${ASAN_FLAGS})
check_cxx_compiler_flag(${ASAN_FLAGS} asan_works)
unset(CMAKE_REQUIRED_FLAGS)
if(asan_works)
    string(REPLACE " " ";" _asan_flags ${ASAN_FLAGS})
    add_executable(asan-example ${CMAKE_CURRENT_SOURCE_DIR}/src/asan-example.cpp)
    target_compile_options(asan-example
        PUBLIC
            ${CXX_BASIC_FLAGS}
            ${_asan_flags}
    )
    target_link_libraries(asan-example PUBLIC ${_asan_flags})
endif()