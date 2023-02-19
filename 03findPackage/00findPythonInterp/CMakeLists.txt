#检测python解释器
cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(findPythonInterp LANGUAGES C CXX)
find_package(PythonInterp REQUIRED)
#执行python命令
execute_process(
  COMMAND
      ${PYTHON_EXECUTABLE} "-c" "print('Hello, world!')"
  RESULT_VARIABLE _status
  OUTPUT_VARIABLE _hello_world
  ERROR_QUIET
  OUTPUT_STRIP_TRAILING_WHITESPACE
  )
#打印Python命令返回值和输出
message(STATUS "RESULT_VARIABLE is: ${_status}")
message(STATUS "OUTPUT_VARIABLE is: ${_hello_world}")