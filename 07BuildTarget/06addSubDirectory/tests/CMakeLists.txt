set(CMAKE_INCLUDE_CURRENT_DIR_IN_INTERFACE ON)
find_package(Catch2 3 REQUIRED)
add_executable(cpp_test test.cpp)
target_link_libraries(cpp_test evolution Catch2::Catch2WithMain)

add_test(
  NAME
    test_evolution
  COMMAND
    $<TARGET_FILE:cpp_test>
  )
