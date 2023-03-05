#查找python库，将python嵌入到c，c++中
cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(FINDPYTHON LANGUAGES C)
set(newcmake OFF)
message(STATUS NOTICE " if not find PythonLibs, you can:  apt-get install python-dev-is-python3")


#if内等价
if(newcmake)
    find_package(Python COMPONENTS Interpreter Development REQUIRED)
else()
    #检测python解释器
    find_package(PythonInterp REQUIRED)  
endif()
#检测python头文件和库模块
find_package(PythonLibs 
            ${PYTHON_VERSION_MAJOR}.${PYTHON_VERSION_MINOR} 
            EXACT REQUIRED)  

add_executable(hello-embedded-python 
                hello-embedded-python.c)
#设置target属性
set_target_properties(hello-embedded-python
                    PROPERTIES
                    C_STANDARD_REQUIRED ON
                    C_STANDARD 11
                    C_EXTENSIONS OFF)
#源文件须include<python.h>,所以tagret添加python头文件
target_include_directories(hello-embedded-python
                            PRIVATE
                                ${PYTHON_INCLUDE_DIRS}
)
#可执行文件链接到python库
target_link_libraries(hello-embedded-python
                        PRIVATE
                            ${PYTHON_LIBRARIES}
)

