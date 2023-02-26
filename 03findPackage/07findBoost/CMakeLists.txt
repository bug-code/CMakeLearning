cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(findBoost LANGUAGES CXX)
#find Boost components filesystem
find_package(Boost REQUIRED COMPONENTS filesystem)
add_executable(path-info path-info.cpp)
set_target_properties(path-info
    PROPERTIES
    CXX_EXTENSIONS OFF
    CXX_STANDARD 11
    CXX_STANDARD_REQUIRED ON
)
#linke Boost component to target
target_link_libraries(path-info
    PUBLIC
        Boost::filesystem
)
