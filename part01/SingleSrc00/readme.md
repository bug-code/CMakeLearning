 

最简单的创建单个源文件CMakeLists.txt

# 创建可执行文件

在CMakeLists.txt目录执行以下命令即可构建可执行文件
```bash
mkdir -p build && cd build
cmake ..
cmake --build .
```

# 切换生成器(构建系统)
unix系统默认(Unix Makefile), 还有其他ninja之类的构建系统
```bash
mkdir -p build && cd build
cmake -G Ninja ..
cmake --build .
```
