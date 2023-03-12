cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(07parallelTest LANGUAGES NONE)

find_package(PythonInterp REQUIRED)
enable_testing()
add_test(
    NAME 0.5/A
    COMMAND ${PYTHON_EXECUTABLE} testA.py 
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
add_test(
    NAME 0.5/B
    COMMAND ${PYTHON_EXECUTABLE} testB.py 
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
add_test(
    NAME 0.5/C
    COMMAND ${PYTHON_EXECUTABLE} testC.py 
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
add_test(
    NAME 0.5/D
    COMMAND ${PYTHON_EXECUTABLE} testD.py 
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
set_tests_properties(
    0.5/A 0.5/B 0.5/C 0.5/D PROPERTIES COST 0.5
)
add_test(
    NAME 1.5/E
    COMMAND ${PYTHON_EXECUTABLE} testE.py 
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
add_test(
    NAME 1.5/F
    COMMAND ${PYTHON_EXECUTABLE} testF.py 
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
add_test(
    NAME 1.5/G
    COMMAND ${PYTHON_EXECUTABLE} testG.py 
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

set_tests_properties(1.5/E 1.5/F 1.5/G PROPERTIES COST 1.5)

add_test(
    NAME 2.5/H
    COMMAND ${PYTHON_EXECUTABLE} testH.py 
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)

set_tests_properties(
    2.5/H
    PROPERTIES COST 2.5
)

add_test(
    NAME 3.5/I
    COMMAND ${PYTHON_EXECUTABLE} testI.py 
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
set_tests_properties(3.5/I PROPERTIES COST 3.5)

add_test(
    NAME 4.5/J
    COMMAND ${PYTHON_EXECUTABLE} testJ.py 
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
)
set_tests_properties(4.5/J PROPERTIES COST 4.5)
