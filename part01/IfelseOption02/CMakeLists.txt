# cmake_minimum_required(VERSION 3.25.1 FATAL_ERROR)
# project(IfelseOption LANGUAGES CXX)
# option(use_Message_shared "use Message shared lib" 1)
# #添加库 .h头文件路径
# include_directories(${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message/include)
# #添加链接第三方库.so或.a文件的路径
# link_directories(${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message/lib)
# add_executable(Helloworld ${CMAKE_CURRENT_SOURCE_DIR}/src/Helloworld.cpp)
# if(use_Message_shared)
#     target_link_libraries(Helloworld libMessage.so) 
#     message(STATUS "use Message shared lib")
# else()
#     target_link_libraries(Helloworld libMessage.a)
#     message(STATUS "use Message STATIC lib")
# endif()

########选项依赖

cmake_minimum_required(VERSION 3.25.1 FATAL_ERROR)
project(IfelseOption LANGUAGES CXX)
include(CMakeDependentOption)
cmake_dependent_option(
    use_Message_shared "use Message shared " 0
    
)


#添加库 .h头文件路径
include_directories(${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message/include)
#添加链接第三方库.so或.a文件的路径
link_directories(${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message/lib)
add_executable(Helloworld ${CMAKE_CURRENT_SOURCE_DIR}/src/Helloworld.cpp)
if(use_Message_shared)
    target_link_libraries(Helloworld libMessage.so) 
    message(STATUS "use Message shared lib")
else()
    target_link_libraries(Helloworld libMessage.a)
    message(STATUS "use Message STATIC lib")
endif()
