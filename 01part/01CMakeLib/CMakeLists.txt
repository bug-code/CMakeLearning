
#不适合多层级结构的cmake
cmake_minimum_required(VERSION 3.21.5 FATAL_ERROR)
project(CMakeLib LANGUAGES CXX)
#将Message源文件编译成静态库
#CMAKE_CURRENT_SOURCE_DIR当前cmakelists.txt文件所在目录
add_library(Message
STATIC
    ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message.cpp
)
#Helloworld编译成可执行文件
add_executable(Helloworld ${CMAKE_CURRENT_SOURCE_DIR}/src/Helloworld.cpp)
#Message静态库链接到将helloworld文件
target_link_libraries(Helloworld Message)

###############创建对象库
# cmake_minimum_required(VERSION 3.25.1 FATAL_ERROR)
# project(CMakeLib LANGUAGES CXX)

# add_library(Message
# OBJECT
#     ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message.hpp
#     ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message.cpp
# )

# set_target_properties(Message 
# ##下两命令暂时不能缺
#     PROPERTIES
#         POSITION_INDEPENDENT_CODE 1
# )

# add_library(Message_shared
#     SHARED
#         $<TARGET_OBJECTS:Message>    
# )
# add_library(Message_static
#     STATIC
#         $<TARGET_OBJECTS:Message>
# )

# #Helloworld编译成可执行文件
# add_executable(Helloworld ${CMAKE_CURRENT_SOURCE_DIR}/src/Helloworld.cpp)
# #Message静态库链接到将helloworld文件
# target_link_libraries(Helloworld Message_shared)

############## 生成同名第三方库文件
# cmake_minimum_required(VERSION 3.25.1 FATAL_ERROR)
# project(CMakeLib LANGUAGES CXX)

# add_library(Message
# OBJECT
#     ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message.hpp
#     ${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message.cpp
# )

# set_target_properties(Message 
# ##下两命令暂时不能缺
#     PROPERTIES
#         POSITION_INDEPENDENT_CODE 1
# )

# add_library(Message_shared
#     SHARED
#         $<TARGET_OBJECTS:Message>    
# )
# #设置Message_shared库的属性
# set_target_properties(Message_shared
#     PROPERTIES
#         OUTPUT_NAME "Message"
# )

# add_library(Message_static
#     STATIC
#         $<TARGET_OBJECTS:Message>
# )
# #设置Message_static库的属性
# set_target_properties(Message_static
#     PROPERTIES
#         OUTPUT_NAME "Message"
# )

# #Helloworld编译成可执行文件
# add_executable(Helloworld ${CMAKE_CURRENT_SOURCE_DIR}/src/Helloworld.cpp)
# #Message静态库链接到将helloworld文件
# target_link_libraries(Helloworld Message_shared)

##################链接已有的第三方库.so文件
# cmake_minimum_required(VERSION 3.25.1 FATAL_ERROR)
# project(CMakeLib LANGUAGES CXX)
# #添加库 .h头文件路径
# target_include_directories(${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message/include)
# # include_directories(${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message/include)
# #添加要链接库.so文件的路径
# link_directories(${CMAKE_CURRENT_SOURCE_DIR}/thirdparty/Message/lib)
# #Helloworld编译成可执行文件
# add_executable(Helloworld ${CMAKE_CURRENT_SOURCE_DIR}/src/Helloworld.cpp)
# #Message静态库链接到将helloworld文件
# target_link_libraries(Helloworld libMessage.so)


