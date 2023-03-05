#include <cstdlib>
#include <iostream>
#include <string>
//宏定义处理，将x转换为字符
//两个宏定义不能少,不然无法正常显示
#define STRINGIFY(x) #x
#define TOSTRING(x) STRINGIFY(x)
std::string say_hello()
{
  //ARCHITECTURE为CMakeLists.txt的宏定义
  std::string arch_info(TOSTRING(ARCHITECTURE));
  arch_info += std::string(" architecture. ");
#ifdef IS_32_BIT_ARCH //CMakeLists.txt中的宏定义
  return arch_info + std::string("Compiled on a 32 bit host processor.");
#elif IS_64_BIT_ARCH
  return arch_info + std::string("Compiled on a 64 bit host processor.");
#else
  return arch_info + std::string("Neither 32 nor 64 bit, puzzling ...");
#endif
}
int main()
{
  std::cout << say_hello() << std::endl;
  return EXIT_SUCCESS;
}