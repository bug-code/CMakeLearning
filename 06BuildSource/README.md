# 生成源码
## 配置时生成源码
有些源码需要在配置时进行生成。例如一些基于特定操作系统和可用库源码，需要在配置时获取操作系统的配置信息，并基于该信息生成源码。

例如：
```c
#include <stdio.h>
#include <unistd.h>
void print_info(void)
{
  printf("C compiler | %s\n","@CMAKE_C_COMPILER@");
  printf("\n");
  fflush(stdout);
}
```
在该c文件中，需要获取到系统的c编译器类型变量。但根据操作系统等不同，c编译器不一样，所以需要在config时根据平台生成不同的源码。

将该c文件命名为print_info.c.in文件，通过cmake获取`CMAKE_C_COMPILER`变量，并传递给`print_info.c.in`从而生成`print_info.c`的c文件。cmake将print_info.c.in中的`@@`包括的变量用cmake检测到的同名变量代替。

### cmake生成源码文件
在CMakeLists.txt文件中添加以下语句生成相应的源码文件。
```cmake
configure_file(print_info.c.in print_info.c @ONLY)
```
### configure_file
`configure_file`命令：
- 复制文件
- 将cmake的变量值替换源文件中的内容
- 将替换后的文件内容复制到指定位置(不指定则为build文件夹)
- 输入和输出文件作为参数时，cmake将配置`@VAR@`变量和`${VAR}`变量。
- 当`${VAR}`是语法的一部分时，通过添加`@ONLY`选项，让cmake只替换`@VAR@`变量
- 源码文件和cmake中的变量需同名才能替换

### 其他
获取其他系统信息
```cmake
# host name information
cmake_host_system_information(RESULT _host_name QUERY HOSTNAME)
cmake_host_system_information(RESULT _fqdn QUERY FQDN)
# processor information
cmake_host_system_information(RESULT _processor_name QUERY PROCESSOR_NAME)
cmake_host_system_information(RESULT _processor_description QUERY PROCESSOR_DESCRIPTION)
# os information
cmake_host_system_information(RESULT _os_name QUERY OS_NAME)
cmake_host_system_information(RESULT _os_release QUERY OS_RELEASE)
cmake_host_system_information(RESULT _os_version QUERY OS_VERSION)
cmake_host_system_information(RESULT _os_platform QUERY OS_PLATFORM)
```
获取内部cmake变量列表
```bash
cmake --help-variable-list
```

## 使用其他语言在配置时生成源码
可以使用其他语言代替cmake中的`configure_file`命令功能。但对于需要生成更复杂的源码模板，建议使用外部工具Jinja。

### python脚本
```python
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
```
通过该python脚本可以使用指定的源码文件配置生成对应的文件，代替`configure_file`功能。

### 生成源码文件
执行该脚本即可生成源码文件
```cmake
find_package(PythonInterp QUIET REQUIRED)
execute_process(
  COMMAND
      ${PYTHON_EXECUTABLE} "-c" ${_config_script}
  )
```
### 其他
可以使用其他语言将生成任务委托给外部脚本，将配置报告编译成可执行文件，甚至库目标。

可以使用`get_cmake_property(_vars VARIABLES)`来获取所有变量的列表，而不是显示的构造`vars_dict`,并且可以遍历`_vars`的所有元素来访值。
```cmake
get_cmake_property(_vars VARIABLES)
```
使用该语句能够代替`cmake_host_system_information`命令的内容。
- 但是，必须注意转义包含字符的值，例如:;， Python会将其解析为一条指令的末尾。


## 构建时生成源码
构建时根据某些规则生成冗长和重复的代码，同时避免在源代码存储库中显式地跟踪生成的代码生成源代码。例如：根据检测到的平台或体系结构生成不同的源代码。

解析器工具有：
- Flex和Bison
- 元对象编译器，例如QT的moc
- 序列化框架，例如谷歌的protobuf

### 示例：python脚本生成源文件
```python
"""
generate.py
Generates C++ vector of prime numbers up to max_number
using sieve of Eratosthenes.
"""
import pathlib
import sys
# for simplicity we do not verify argument list
max_number = int(sys.argv[-2])
output_file_name = pathlib.Path(sys.argv[-1])
numbers = range(2, max_number + 1)
is_prime = {number: True for number in numbers}
for number in numbers:
  current_position = number
  if is_prime[current_position]:
    while current_position <= max_number:
      current_position += number
      is_prime[current_position] = False
primes = (number for number in numbers if is_prime[number])
code = """#pragma once
#include <vector>
const std::size_t max_number = {max_number};
std::vector<int> & primes() {{
  static std::vector<int> primes;
  {push_back}
  return primes;
}}
"""
push_back = '\n'.join([' primes.push_back({:d});'.format(x) for x in primes])
output_file_name.write_text(
code.format(max_number=max_number, push_back=push_back))
```

通过该python脚本可以生成一个c++的头文件。例如执行以下命令
```bash
python generate.py 10 prime.hpp
```

###  构建时生成源码文件
```cmake
add_custom_command(
  OUTPUT
      ${CMAKE_CURRENT_BINARY_DIR}/generated/primes.hpp
  COMMAND
      ${PYTHON_EXECUTABLE} generate.py ${MAX_NUMBER}     ${CMAKE_CURRENT_BINARY_DIR}/generated/primes.hpp
  WORKING_DIRECTORY
      ${CMAKE_CURRENT_SOURCE_DIR}/src
  DEPENDS
      ${CMAKE_CURRENT_SOURCE_DIR}/src/generate.py
)
```
所谓构建时生成源码文件就是：在执行`make`命令时生成源码文件。即在CMakeLists.txt中添加上述命令，即在make时执行该脚本命令。
在`cmake .. `时不会生成。

### 其他
所有的生成文件，都应该作为某个目标的依赖项。但是，我们可能不知道这个文件列表，因为它是由生成文件的脚本决定的，这取决于我们提供给配置的输入。这种情况下，我们可能会尝试使用`file(GLOB…)`将生成的文件收集到一个列表中.

`file(GLOB…)`在配置时执行，而代码生成是在构建时发生的。因此可能需要一个间接操作，将`file(GLOB…)`命令放在一个单独的CMake脚本中，使用`${CMAKE_COMMAND} -P`执行该脚本，以便在构建时获得生成的文件列表。

## 记录项目版本信息
代码版本很重要，不仅是为了可重复性，还为了记录API功能或简化支持请求和bug报告。将可执行文件记录项目版本信息。

### 配置时生成版本源码文件
```c
//version.h.in
#pragma once
#define PROJECT_VERSION_MAJOR @PROJECT_VERSION_MAJOR@
#define PROJECT_VERSION_MINOR @PROJECT_VERSION_MINOR@
#define PROJECT_VERSION_PATCH @PROJECT_VERSION_PATCH@
#define PROJECT_VERSION "v@PROJECT_VERSION@"
```
config时生成源码文件
```cmake
configure_file(
  version.h.in
  generated/version.h
  @ONLY
  )
```

### 指定版本
```cmake
project(03GetVersionInfo VERSION 0.0.0 LANGUAGES C)
```
### 其他
CMake以x.y.z格式给出的版本号，并将变量PROJECT_VERSION和<project-name>_VERSION设置为给定的值。

此外,PROJECT_VERSION_MAJOR(<project-name>_VERSION_MAJOR),PROJECT_VERSION_MINOR(<project-name>_VERSION_MINOR) PROJECT_VERSION_PATCH(<project-name>_VERSION_PATCH)和PROJECT_VERSION_TWEAK(<project-name>_VERSION_TWEAK),将分别设置为X, Y, Z和t。

## 记录项目版本到文件
从文件中读取版本信息，而不是将其设置在CMakeLists.txt中。将版本保存在单独文件中的动机，是允许其他构建框架或开发工具使用独立于CMake的信息，而无需将信息复制到多个文件中。

### 读取文件中的版本信息
```cmake
file(READ "${CMAKE_CURRENT_SOURCE_DIR}/src/VERSION" PROGRAM_VERSION)
    string(STRIP "${PROGRAM_VERSION}" PROGRAM_VERSION)
```

### 配置时生成版本信息源文件
```cmake
configure_file(
  ${CMAKE_CURRENT_SOURCE_DIR}/src/version.hpp.in
  generated/version.hpp
  @ONLY
)
```
从VERSION文件中获取的版本信息，通过`configure_file`在config时将版本信息变量传递给源码文件，并生成源码文件。


## 配置时将git hash值写入源码文件中
每次构建项目时，将最新git hash值写入到源码文件中。

### cmake中获取git hash值
```cmake
# in case Git is not available, we default to "unknown"
set(GIT_HASH "unknown")
# find Git and if available set GIT_HASH variable
find_package(Git QUIET)
if(GIT_FOUND)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} log -1 --pretty=format:%h
    OUTPUT_VARIABLE GIT_HASH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
    WORKING_DIRECTORY
        ${CMAKE_CURRENT_SOURCE_DIR}
  )
endif()
message(STATUS "Git hash is ${GIT_HASH}")
```

### 其他
在`version.hpp.in`中设置一个git hash的变量。cmake通过configure_file将git hash值传递给`version.hpp.in`文件，从而生成`version.hpp`源码文件。

## 构建时将git hash值写入源码文件
如果在配置代码之后更改分支或提交更改，则源代码中包含的版本记录可能指向错误的Git Hash值。

### 将git hash模块为一个单独模块
```cmake
#git_hash.cmake
# in case Git is not available, we default to "unknown"
set(GIT_HASH "unknown")
# find Git and if available set GIT_HASH variable
find_package(Git QUIET REQUIRED)
if(GIT_FOUND)
  execute_process(
    COMMAND ${GIT_EXECUTABLE} log -1 --pretty=format:%h
    OUTPUT_VARIABLE GIT_HASH
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
    WORKING_DIRECTORY
        ${CMAKE_CURRENT_SOURCE_DIR}
  )
endif()
message(STATUS "Git hash is ${GIT_HASH}")
file(MAKE_DIRECTORY ${CMAKE_BINARY_DIR}/generated)
# generate file version.hpp based on version.hpp.in
configure_file(
  version.hpp.in
  ${CMAKE_BINARY_DIR}/generated/version.hpp
  @ONLY
)
```

### 在构建时写入git hash
在主CMakeLists.txt文件中
```cmake
add_custom_command(
 OUTPUT
     ${CMAKE_CURRENT_BINARY_DIR}/generated/version.hpp
 ALL
 COMMAND
     ${CMAKE_COMMAND} -D TARGET_DIR=${CMAKE_CURRENT_BINARY_DIR} -P ${CMAKE_CURRENT_SOURCE_DIR}/src/git_hash.cmake
 WORKING_DIRECTORY
     ${CMAKE_CURRENT_SOURCE_DIR}/src
 )
# rebuild version.hpp every time
add_custom_target(
 get_git_hash
 ALL
 DEPENDS
     ${CMAKE_CURRENT_BINARY_DIR}/generated/version.hpp
 )
# version.hpp has to be generated
# before we start building example
add_dependencies(example get_git_hash)

```
通过cmake执行git_hash.cmake脚本将获取的git hash值传递给version.hpp.in源文件，cmake再通过configure_file将生成对应的源文件。

`-p`选项表示传入脚本的具体位置。
