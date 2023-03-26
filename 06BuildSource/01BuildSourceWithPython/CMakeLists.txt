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
#get variables auto
get_cmake_property(_vars  VARIABLES)
# get config time stamp
string(TIMESTAMP _configuration_time "%Y-%m-%d %H:%M:%S [UTC]" UTC)

# python config  script
set(_config_script
"
from pathlib import Path
source_dir = Path('${CMAKE_CURRENT_SOURCE_DIR}')
binary_dir = Path('${CMAKE_CURRENT_BINARY_DIR}')
src_dir = Path('${CMAKE_CURRENT_SOURCE_DIR}/src')
input_file = src_dir / 'print_info.c.in'
output_file = binary_dir / 'print_info.c'
import sys
sys.path.insert(0, str(source_dir))

#use python script to replace configure_fille command
def configure_file(input_file, output_file, vars_dict):
  with input_file.open('r') as f:
      template = f.read()
  for var in vars_dict:
      template = template.replace('@' + var + '@', vars_dict[var])
  with output_file.open('w') as f:
      f.write(template)

vars_dict = {
  '_user_name': '${_user_name}',
  '_host_name': '${_host_name}',
  '_fqdn': '${_fqdn}',
  '_processor_name': '${_processor_name}',
  '_processor_description': '${_processor_description}',
  '_os_name': '${_os_name}',
  '_os_release': '${_os_release}',
  '_os_version': '${_os_version}',
  '_os_platform': '${_os_platform}',
  '_configuration_time': '${_configuration_time}',
  'CMAKE_VERSION': '${CMAKE_VERSION}',
  'CMAKE_GENERATOR': '${CMAKE_GENERATOR}',
  'CMAKE_Fortran_COMPILER': '${CMAKE_Fortran_COMPILER}',
  'CMAKE_C_COMPILER': '${CMAKE_C_COMPILER}',
}
configure_file(input_file, output_file, vars_dict)
")

# find python
find_package(PythonInterp QUIET REQUIRED)

#build source code when config
execute_process(
  COMMAND
      ${PYTHON_EXECUTABLE} "-c" ${_config_script}
)

add_executable(example "")
target_sources(example
  PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/src/example.f90
    ${CMAKE_CURRENT_BINARY_DIR}/print_info.c
)