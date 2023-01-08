cmake_minimum_required(VERSION 3.21.5 FATAL_ERROR)
project(langStandard LANGUAGES CXX)
#生成动态库
include(CMakeDependentOption)
cmake_dependent_option(
    use_animals_shared "use animals shared" 0
    use_animals_static "use animals static"  1
)
if(use_animals_shared)
    add_library(animals
        SHARED
            ${CMAKE_CURRENT_SOURCE_DIR}/src/Animal.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/src/Animal.hpp
            ${CMAKE_CURRENT_SOURCE_DIR}/src/Cat.hpp
            ${CMAKE_CURRENT_SOURCE_DIR}/src/Cat.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/src/Dog.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/src/Dog.hpp
            ${CMAKE_CURRENT_SOURCE_DIR}/src/Factory.hpp
    )
elseif()
    add_library(animals
        STATIC
            ${CMAKE_CURRENT_SOURCE_DIR}/src/Animal.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/src/Animal.hpp
            ${CMAKE_CURRENT_SOURCE_DIR}/src/Cat.hpp
            ${CMAKE_CURRENT_SOURCE_DIR}/src/Cat.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/src/Dog.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/src/Dog.hpp
            ${CMAKE_CURRENT_SOURCE_DIR}/src/Factory.hpp
    )
endif()
#为animals设置编译语言标准
set_target_properties(animals
    PROPERTIES
        #设置为C++14语言标准
        CXX_STANDARD 14
        #只启用ISO C++标准的编译器标志，而不使用特定编译器的扩展
        CXX_EXTENSIONS OFF
        #找到匹配的语言标准，找不到报错
        CXX_STANDARD_REQUIRED ON
        #生成位置无关代码
        POSITION_INDEPENDENT_CODE 1
)
set(LIBRARY_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/lib)
set(EXECUTABLE_OUTPUT_PATH ${CMAKE_CURRENT_SOURCE_DIR}/bin)
#生成animal-farm可执行文件
add_executable(animals_farm ${CMAKE_CURRENT_SOURCE_DIR}/src/animal-farm.cpp)
set_target_properties(animals_farm
    PROPERTIES
        CXX_STANDARD 14
        CXX_EXTENSIONS off
        CXX_STANDARD_REQUIRED on
        POSITION_INDEPENDENT_CODE 1
)
target_link_libraries(animals_farm animals)