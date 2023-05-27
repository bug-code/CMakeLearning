CMAKE_MINIMUM_REQUIRED(VERSION 3.22.1 FATAL_ERROR)
project(fftw3_example LANGUAGES C)
find_package(FFTW3 CONFIG REQUIRED)
# get_property(_loc TARGET FFTW3::fftw3 PROPERTY LOCATION)
# message(STATUS "found FFTW3:${_loc} (found vesion ${FFTW3_VERSION})")
add_executable(fftw3_example fftw_example.c)
target_link_libraries(fftw3_example PRIVATE FFTW3::fftw3)

