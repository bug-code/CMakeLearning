#添加FortranCInterface.cmake模块
include(FortranCInterface)
#验证C和Fortran编译器可以正确的交互
FortranCInterface_VERIFY()
#查找Backtrace系统库
find_package(Backtrace REQUIRED)
#创建共享库，包含该目录下的源码文件
add_library(bt-randomgen-warp SHARED "")
target_sources(bt-randomgen-warp PRIVATE interface_backtrace.f90
                                         interface_randomgen.f90 randomgen.c)
#bt-randomgen-warp库链接到Backtrace系统库
target_link_libraries(bt-randomgen-warp PUBLIC ${Backtrace_LIBRARIES})
