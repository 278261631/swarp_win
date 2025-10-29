# SWarp Windows 编译指南

本文档说明如何在 Windows 平台上编译 SWarp。

## 前置要求

### 必需工具

1. **CMake** (版本 3.15 或更高)
   - 已安装在: `C:\CMake`
   - 确保 CMake 已添加到系统 PATH

2. **编译器** (选择其一):
   - **MSYS2/MinGW-w64** (推荐)
     - 已安装在: `C:\msys64`
   - **Visual Studio 2017 或更高版本**
   - **Intel C++ Compiler**

3. **CFITSIO 库** (可选但推荐)
   - 用于支持压缩的 FITS 文件
   - 下载地址: https://heasarc.gsfc.nasa.gov/fitsio/

## 编译步骤

### 方法 1: 使用 MSYS2/MinGW-w64 (推荐)

#### 1. 安装 MSYS2 依赖

打开 MSYS2 MinGW 64-bit 终端，安装必要的包：

```bash
# 更新包数据库
pacman -Syu

# 安装编译工具链
pacman -S mingw-w64-x86_64-gcc
pacman -S mingw-w64-x86_64-cmake
pacman -S make

# 安装 CFITSIO (可选)
pacman -S mingw-w64-x86_64-cfitsio
```

#### 2. 配置和编译

在 MSYS2 MinGW 64-bit 终端中：

```bash
# 进入项目目录
cd /e/github/swarp_win

# 创建构建目录
mkdir build
cd build

# 配置项目
cmake .. -G "MinGW Makefiles" \
    -DCMAKE_BUILD_TYPE=Release \
    -DUSE_THREADS=ON \
    -DUSE_CFITSIO=ON

# 编译
cmake --build . --config Release

# 复制必要的 DLL 文件
cd ..
bash copy_dlls.sh

# 测试运行
./build/src/swarp.exe -v

# 可选：安装
cmake --install . --prefix ../install
```

#### 3. 不使用 CFITSIO 编译

如果不需要 CFITSIO 支持：

```bash
cmake .. -G "MinGW Makefiles" \
    -DCMAKE_BUILD_TYPE=Release \
    -DUSE_THREADS=ON \
    -DUSE_CFITSIO=OFF

cmake --build . --config Release

# 复制必要的 DLL 文件
cd ..
bash copy_dlls.sh
```

#### 4. 关于 DLL 依赖

编译完成后，需要复制以下 DLL 文件到可执行文件目录：

**必需的 DLL：**
- `msys-2.0.dll` - MSYS2 运行时库
- `msys-gcc_s-seh-1.dll` - GCC 异常处理库

**可选的 DLL：**
- `libwinpthread-1.dll` - 多线程支持（如果启用了 USE_THREADS）

**自动复制方法：**

项目提供了两个脚本来自动复制 DLL：

在 MSYS2 环境中：
```bash
bash copy_dlls.sh
```

在 Windows CMD 中：
```cmd
copy_dlls.bat
```

这些脚本会自动从 `C:\msys64\usr\bin` 复制所需的 DLL 文件到 `build\src\` 目录。

### 方法 2: 使用 Visual Studio

#### 1. 安装 CFITSIO (可选)

如果需要 CFITSIO 支持，需要先编译或下载预编译的 CFITSIO 库。

下载 CFITSIO 源码并编译：
```cmd
# 下载并解压 CFITSIO
# 在 CFITSIO 目录中
mkdir build
cd build
cmake .. -G "Visual Studio 16 2019" -A x64
cmake --build . --config Release
cmake --install . --prefix C:\cfitsio
```

#### 2. 配置和编译 SWarp

打开 "x64 Native Tools Command Prompt for VS":

```cmd
cd E:\github\swarp_win

mkdir build
cd build

# 配置项目 (不使用 CFITSIO)
cmake .. -G "Visual Studio 16 2019" -A x64 ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DUSE_THREADS=ON ^
    -DUSE_CFITSIO=OFF

# 或者使用 CFITSIO
cmake .. -G "Visual Studio 16 2019" -A x64 ^
    -DCMAKE_BUILD_TYPE=Release ^
    -DUSE_THREADS=ON ^
    -DUSE_CFITSIO=ON ^
    -DCFITSIO_ROOT=C:\cfitsio

# 编译
cmake --build . --config Release

# 可选：安装
cmake --install . --prefix ..\install
```

### 方法 3: 使用 Ninja 构建系统 (快速)

```bash
# 在 MSYS2 MinGW 64-bit 终端中
pacman -S mingw-w64-x86_64-ninja

cd /e/github/swarp_win
mkdir build
cd build

cmake .. -G "Ninja" \
    -DCMAKE_BUILD_TYPE=Release \
    -DUSE_THREADS=ON \
    -DUSE_CFITSIO=ON

ninja
```

## CMake 配置选项

- `USE_THREADS`: 启用多线程支持 (默认: ON)
- `USE_CFITSIO`: 启用 CFITSIO 支持 (默认: ON)
- `BUILD_SHARED_LIBS`: 构建共享库而非静态库 (默认: OFF)
- `CMAKE_BUILD_TYPE`: 构建类型 (Release/Debug/RelWithDebInfo)
- `CFITSIO_ROOT`: CFITSIO 安装路径 (如果未在标准位置)

## 手动指定 CFITSIO 路径

如果 CMake 无法自动找到 CFITSIO，可以手动指定：

```bash
cmake .. -G "MinGW Makefiles" \
    -DCFITSIO_ROOT=C:/cfitsio \
    -DCFITSIO_INCLUDE_DIR=C:/cfitsio/include \
    -DCFITSIO_LIBRARY=C:/cfitsio/lib/cfitsio.lib
```

## 编译输出

成功编译后，可执行文件位于：
- MSYS2/MinGW: `build/src/swarp.exe`
- Visual Studio: `build/src/Release/swarp.exe`

## 运行测试

```bash
# 查看版本信息
./src/swarp.exe -v

# 生成默认配置文件
./src/swarp.exe -d > default.swarp

# 运行测试
./src/swarp.exe test/test.fits
```

## 常见问题

### 1. CMake 找不到

确保 CMake 在 PATH 中：
```cmd
set PATH=C:\CMake\bin;%PATH%
```

### 2. 找不到 CFITSIO

- 确保 CFITSIO 已正确安装
- 使用 `-DCFITSIO_ROOT` 指定路径
- 或者使用 `-DUSE_CFITSIO=OFF` 禁用 CFITSIO 支持

### 3. 线程库错误

如果遇到线程相关错误，可以禁用多线程：
```bash
cmake .. -DUSE_THREADS=OFF
```

### 4. MSYS2 路径问题

在 MSYS2 中，Windows 路径需要转换：
- `C:\` → `/c/`
- `E:\github\swarp_win` → `/e/github/swarp_win`

## 依赖库说明

### 必需依赖
- 标准 C 库
- 数学库 (libm)

### 可选依赖
- **CFITSIO**: 用于读写压缩的 FITS 文件
- **pthread**: 多线程支持 (Windows 上使用 winpthreads)

## 性能优化

对于发布版本，建议使用以下优化选项：

```bash
cmake .. -G "MinGW Makefiles" \
    -DCMAKE_BUILD_TYPE=Release \
    -DCMAKE_C_FLAGS="-O3 -march=native"
```

## 技术支持

如有问题，请访问：
- 官方网站: https://astromatic.net/software/swarp
- GitHub: https://github.com/astromatic/swarp
- 邮件: astromatic@astromatic.net

