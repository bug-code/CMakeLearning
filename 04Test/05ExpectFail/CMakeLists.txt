cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(05ExpactFail LANGUAGES NONE)
find_package(PythonInterp REQUIRED)
enable_testing()
add_test(example ${PYTHON_EXECUTABLE} ${CMAKE_CURRENT_SOURCE_DIR}/test.py)
set_tests_properties(example PROPERTIES WILL_FAIL true)
