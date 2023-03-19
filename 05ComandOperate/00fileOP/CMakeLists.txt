cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(00fileOP LANGUAGES CXX)

#download eigen
if(NOT EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/thirdPart/eigen)
    message(NOTICE "-- unpack eigen")
    execute_process(COMMAND wget https://gitlab.com/libeigen/eigen/-/archive/3.4.0/eigen-3.4.0.tar.gz
                    WORKING_DIRECTORY  ${CMAKE_CURRENT_SOURCE_DIR}/thirdPart/
    ) 
    execute_process(                    
        COMMAND tar xzf  eigen-3.4.0.tar.gz
        WORKING_DIRECTORY  ${CMAKE_CURRENT_SOURCE_DIR}/thirdPart/
    )
    execute_process(
        COMMAND mv eigen-3.4.0 eigen
        WORKING_DIRECTORY  ${CMAKE_CURRENT_SOURCE_DIR}/thirdPart/
    )
endif()
#add target fold
add_custom_target(eigen
    ALL
    COMMAND echo "build eigen target"
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/thirdPart/eigen/
)

add_executable(linear-algebra ${CMAKE_CURRENT_SOURCE_DIR}/src/linear-algebra.cpp)
add_dependencies(linear-algebra eigen)
target_include_directories(linear-algebra
    PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/thirdPart/eigen
)
