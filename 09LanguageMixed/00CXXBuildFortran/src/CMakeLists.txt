#添加子目录，生成动态库
add_subdirectory(interfaces)
add_subdirectory(utils)
#生成可执行文件
add_executable(bt-randomgen-example bt-randomgen-example.f90)
#可执行文件链接到两个动态库
target_link_libraries(bt-randomgen-example
    PRIVATE
      bt-randomgen-warp
      utils
  
)

