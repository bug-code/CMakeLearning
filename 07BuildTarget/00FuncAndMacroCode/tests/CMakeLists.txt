add_executable(cpp_test test.cpp)
target_link_libraries(cpp_test sum_integers Catch2::Catch2WithMain)


# #定义宏
# macro(add_catch_test _name _cost)
#   #算术表达式:num_macro_calls为全局变量，表示宏调用次数
#   math(EXPR num_macro_calls "${num_macro_calls} + 1")
#   #ARGC ARGV为cmake系统变量，表示参数数量，和参数列表
#   message(STATUS "add_catch_test called with ${ARGC} arguments: ${ARGV}")
#   #${ARGN}，保存给定参数数量之后的参数列表
#   set(_argn "${ARGN}")
#   if(_argn)
#       message(STATUS "oops - macro received argument(s) we did not expect: ${ARGN}")
#   endif()
#   add_test(
#     NAME
#       ${_name}
#     COMMAND
#         #生成器表达式：$<TARGET_FILE:cpp_test> 如果是cpp_test则执行后面的命令。输出执行结果信息到build目录下的log文件中
#       $<TARGET_FILE:cpp_test> [${_name}] --success --out ${PROJECT_BINARY_DIR}/tests/${_name}.log --durations yes
#     WORKING_DIRECTORY
#       ${CMAKE_CURRENT_BINARY_DIR}
#     )
#     #添加测试目标属性的参数
#   set_tests_properties(
#     ${_name}
#     PROPERTIES
#         COST ${_cost}
#     )
# endmacro()


#定义宏
function(add_catch_test _name _cost)
  #算术表达式:num_macro_calls为全局变量，表示函数调用次数
  set(num_macro_calls ${num_macro_calls} PARENT_SCOPE)
  math(EXPR num_macro_calls "${num_macro_calls} + 1")
  set(num_macro_calls ${num_macro_calls} PARENT_SCOPE)
  #ARGC ARGV为cmake系统变量，表示参数数量，和参数列表
  message(STATUS "add_catch_test called with ${ARGC} arguments: ${ARGV}")
  #${ARGN}，保存给定参数数量之后的参数列表
  set(_argn "${ARGN}")
  if(_argn)
      message(STATUS "oops - macro received argument(s) we did not expect: ${ARGN}")
  endif()
  add_test(
    NAME
      ${_name}
    COMMAND
        #生成器表达式：$<TARGET_FILE:cpp_test> 如果是cpp_test则执行后面的命令。输出执行结果信息到build目录下的log文件中
      $<TARGET_FILE:cpp_test> [${_name}] --success --out ${PROJECT_BINARY_DIR}/tests/${_name}.log --durations yes
    WORKING_DIRECTORY
      ${CMAKE_CURRENT_BINARY_DIR}
    )
    #添加测试目标属性的参数
  set_tests_properties(
    ${_name}
    PROPERTIES
        COST ${_cost}
    )
endfunction()
set(num_macro_calls 0)
add_catch_test(short 1.5)
add_catch_test(long 2.5 extra_argument)
message(STATUS "in total there were ${num_macro_calls} calls to add_catch_test")