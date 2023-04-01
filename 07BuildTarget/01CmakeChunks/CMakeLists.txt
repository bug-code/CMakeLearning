cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(CmakeChunks LANGUAGES NONE)
#增加cmake搜索路径，以便找到自己写的cmake模块
list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake")
#添加colors模块
include(colors)
#使用自己写的cmake模块的宏
define_colors()
message(STATUS "This is a normal message")
message(STATUS "${Red}This is a red${ColourReset}")
message(STATUS "${BoldRed}This is a bold red${ColourReset}")
message(STATUS "${Green}This is a green${ColourReset}")
message(STATUS "${BoldMagenta}This is bold${ColourReset}")