cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(01Catch2Test LANGUAGES CXX)

add_library(sum_integers sum_integers.cpp)

add_executable(sum_up main.cpp)
target_link_libraries(sum_up sum_integers)

find_package(Catch2 3 REQUIRED)
add_executable(cpp_test test.cpp)
target_link_libraries(cpp_test 
            PRIVATE 
                sum_integers
                Catch2::Catch2WithMain
)
set_target_properties(
    sum_integers
    sum_up
    cpp_test
    PROPERTIES
    CXX_EXTENSIONS OFF
    CXX_STANDARD 11
    CXX_STANDARD_REQUIRED ON
)

enable_testing()
add_test(
    NAME catch2_test
    COMMAND $<TARGET_FILE:cpp_test> --success
)


