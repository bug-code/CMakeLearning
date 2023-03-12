cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(09testFixture LANGUAGES NONE)
find_package(PythonInterp REQUIRED)
enable_testing()


add_test(
  NAME setup
  COMMAND ${PYTHON_EXECUTABLE} setup.py
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/test/
  )
set_tests_properties(
  setup
  PROPERTIES
      FIXTURES_SETUP my-fixture
  )
add_test(
  NAME feature-a
  COMMAND ${PYTHON_EXECUTABLE} feature-a.py
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/test/

)
add_test(
  NAME feature-b
  COMMAND ${PYTHON_EXECUTABLE} feature-b.py
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/test/

)
set_tests_properties(
  feature-a
  feature-b
  PROPERTIES
      FIXTURES_REQUIRED my-fixture
  )
add_test(
  NAME cleanup
  COMMAND ${PYTHON_EXECUTABLE} cleanup.py
  WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/test/
)
set_tests_properties(
  cleanup
  PROPERTIES
      FIXTURES_CLEANUP my-fixture
  )