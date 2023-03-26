cmake_minimum_required(VERSION 3.22.1 FATAL_ERROR)
project(00Config2BuildSource LANGUAGES Fortran C)

# get the user information
execute_process(
  COMMAND
      whoami
  TIMEOUT
      1
  OUTPUT_VARIABLE
      _user_name
  OUTPUT_STRIP_TRAILING_WHITESPACE
)

#get system information

##get variables by manual
# # host name information
# cmake_host_system_information(RESULT _host_name QUERY HOSTNAME)
# cmake_host_system_information(RESULT _fqdn QUERY FQDN)
# # processor information
# cmake_host_system_information(RESULT _processor_name QUERY PROCESSOR_NAME)
# cmake_host_system_information(RESULT _processor_description QUERY PROCESSOR_DESCRIPTION)
# # os information
# cmake_host_system_information(RESULT _os_name QUERY OS_NAME)
# cmake_host_system_information(RESULT _os_release QUERY OS_RELEASE)
# cmake_host_system_information(RESULT _os_version QUERY OS_VERSION)
# cmake_host_system_information(RESULT _os_platform QUERY OS_PLATFORM)

# get variables by auto
get_cmake_property(_vars VARIABLES)


# get config time stamp
string(TIMESTAMP _configuration_time "%Y-%m-%d %H:%M:%S [UTC]" UTC)

#build source code when config
configure_file(${CMAKE_CURRENT_SOURCE_DIR}/src/print_info.c.in print_info.c @ONLY)

add_executable(example "")
target_sources(example
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src/example.f90
    ${CMAKE_CURRENT_BINARY_DIR}/print_info.c
)