cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(findPythonModule LANGUAGES C CXX)
#两个if内等价
set(NumPyAsComponents OFF)
set(InterpreterAsComponents OFF )
if(InterpreterAsComponents)
  find_package(Python COMPONENTS Interpreter)
else()
  find_package(PythonInterp REQUIRED)  
endif()

#检测python头文件和库模块
find_package(PythonLibs 
            ${PYTHON_VERSION_STRING}
            EXACT REQUIRED)


if(NumPyAsComponents)
  find_package(Python COMPONENTS
            NumPy 
            REQUIRED)
  message(STATUS NOTICE " Python_EXECUTABLE: ${Python_EXECUTABLE} ")
else()

  #查找指定python版本对应numpy
  execute_process(
    COMMAND
        ${Python_EXECUTABLE} "-c" "import re, numpy; print(re.compile('/__init__.py.*').sub('',numpy.__file__))"
  #查找的结果，保存在变量中    
    RESULT_VARIABLE _numpy_status
  #查找的路径保存在变量中
    OUTPUT_VARIABLE _numpy_location
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  message(STATUS NOTICE " _numpy_status : ${_numpy_status}")
  # 查找到后设置numpy路径
  if(NOT _numpy_status)
      set(NumPy ${_numpy_location} CACHE STRING "Location of NumPy")
  endif()
  #检测numpy版本，保存在变量中
  execute_process(
    COMMAND
        ${Python_EXECUTABLE} "-c" "import numpy; print(numpy.__version__)"
    OUTPUT_VARIABLE _numpy_version
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  #设置NumPy_FOUND变量和输出信息
  include(FindPackageHandleStandardArgs)
  find_package_handle_standard_args(NumPy
    FOUND_VAR NumPy_FOUND
    REQUIRED_VARS NumPy
    VERSION_VAR _NumPy_version
  )  
endif()

 
#查看find_package设置了哪些变量
get_cmake_property(_variableNames VARIABLES)
foreach (_variableName ${_variableNames})
    message(STATUS "${_variableName}=${${_variableName}}")
endforeach()



#编译可执行文件，及链接到python库
add_executable(pure-embedding "")
set_target_properties(pure-embedding
                    PROPERTIES
                    CXX_STANDARD_REQUIRED ON
                    CXX_STANDARD 11
                    CXX_EXTENSIONS OFF)
target_sources(pure-embedding
  PRIVATE
      Py3_pure_embedding.cpp
  )
target_include_directories(pure-embedding
  PRIVATE
      ${PYTHON_INCLUDE_DIRS}
  )
target_link_libraries(pure-embedding
  PRIVATE
      ${PYTHON_LIBRARIES}
  )

# 保证use-numpy.py在build目录中可用
add_custom_command(
  OUTPUT
      ${CMAKE_CURRENT_BINARY_DIR}/use_numpy.py
  COMMAND
      ${CMAKE_COMMAND} -E copy_if_different ${CMAKE_CURRENT_SOURCE_DIR}/use_numpy.py
      ${CMAKE_CURRENT_BINARY_DIR}/use_numpy.py
  DEPENDS
      ${CMAKE_CURRENT_SOURCE_DIR}/use_numpy.py
  )

# make sure building pure-embedding triggers the above custom command
target_sources(pure-embedding
  PRIVATE
      ${CMAKE_CURRENT_BINARY_DIR}/use_numpy.py
)

message(STATUS NOTICE " after make command, you can run as ./pure-embedding use_numpy print_ones 2 3")