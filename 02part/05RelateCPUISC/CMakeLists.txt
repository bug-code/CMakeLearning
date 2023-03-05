cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(RelateCPUISC LANGUAGES CXX)
# add_executable中源文件为空是为了依据检测到的操作系统类型,编译器类型,cpu架构等来添加相应的源文件
add_executable(ISC_info "")
# 添加源文件
target_sources(ISC_info PRIVATE processor_info.cpp)
target_include_directories(ISC_info
  PRIVATE
       ${PROJECT_BINARY_DIR} #当前cmakelists中对应的build文件夹
)
#foreach循环查询系统中对应系统变量的值
foreach(key
  IN ITEMS
    #系统变量
    NUMBER_OF_LOGICAL_CORES
    NUMBER_OF_PHYSICAL_CORES
    TOTAL_VIRTUAL_MEMORY
    AVAILABLE_VIRTUAL_MEMORY
    TOTAL_PHYSICAL_MEMORY
    AVAILABLE_PHYSICAL_MEMORY
    IS_64BIT
    HAS_FPU
    HAS_MMX
    HAS_MMX_PLUS
    HAS_SSE
    HAS_SSE2
    HAS_SSE_FP
    HAS_SSE_MMX
    HAS_AMD_3DNOW
    HAS_AMD_3DNOW_PLUS
    HAS_IA64
    OS_NAME
    OS_RELEASE
    OS_VERSION
    OS_PLATFORM
  )
  #查询主机系统中的指定信息
  cmake_host_system_information(RESULT _${key} QUERY ${key})
endforeach()
#修改并复制一份源文件到另一个位置,比如target_include_directories中指定的build文件夹
configure_file(config.h.in config.h @ONLY)