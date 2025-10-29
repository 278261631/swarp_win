# SWarp for Windows

这是 SWarp (Software for Warping and Co-adding FITS images) 的 Windows 移植版本。

## 快速开始

### 编译项目

1. **在 MSYS2 环境中编译：**

```bash
# 创建构建目录
mkdir build && cd build

# 配置 CMake
cmake .. -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DUSE_THREADS=ON -DUSE_CFITSIO=OFF

# 编译
make -j4

# 复制必要的 DLL 文件
cd ..
bash copy_dlls.sh
```

2. **测试运行：**

```bash
# 在 MSYS2 中
./build/src/swarp.exe -v

# 在 Windows CMD 中
build\src\swarp.exe -v
```

### 运行程序

编译完成后，可执行文件位于 `build/src/swarp.exe`。

**重要：** 在 Windows 环境中运行需要以下 DLL 文件（已由 `copy_dlls.sh` 或 `copy_dlls.bat` 自动复制）：
- `msys-2.0.dll`
- `msys-gcc_s-seh-1.dll`
- `libwinpthread-1.dll` (如果启用了多线程)

### 基本用法

```bash
# 查看版本
swarp.exe -v

# 生成默认配置文件
swarp.exe -d > default.swarp

# 处理 FITS 文件
swarp.exe image1.fits image2.fits -c config.swarp
```

## 文件说明

### 编译相关文件

- `CMakeLists.txt` - 主 CMake 配置文件
- `config.h.in` - 配置头文件模板
- `src/CMakeLists.txt` - 源代码构建配置
- `src/fits/CMakeLists.txt` - FITS 库构建配置
- `src/wcs/CMakeLists.txt` - WCS 库构建配置
- `cmake/FindCFITSIO.cmake` - CFITSIO 查找模块

### 辅助脚本

- `copy_dlls.sh` - 在 MSYS2 环境中复制 DLL 的脚本
- `copy_dlls.bat` - 在 Windows CMD 中复制 DLL 的批处理脚本

### 文档

- `BUILD_WINDOWS.md` - 详细的 Windows 编译指南
- `COMPILE_SUCCESS.md` - 编译成功报告
- `README_WINDOWS.md` - 本文件

## 编译选项

CMake 提供以下编译选项：

| 选项 | 说明 | 默认值 |
|------|------|--------|
| `USE_THREADS` | 启用多线程支持 | ON |
| `USE_CFITSIO` | 启用 CFITSIO 库支持 | OFF |
| `CMAKE_BUILD_TYPE` | 构建类型 (Debug/Release) | Release |

示例：

```bash
# 启用 CFITSIO 支持
cmake .. -DUSE_CFITSIO=ON

# 禁用多线程
cmake .. -DUSE_THREADS=OFF

# Debug 构建
cmake .. -DCMAKE_BUILD_TYPE=Debug
```

## 分发程序

如果要将编译好的程序复制到其他位置或其他计算机，需要同时复制以下文件：

```
swarp.exe
msys-2.0.dll
msys-gcc_s-seh-1.dll
libwinpthread-1.dll
```

建议创建一个独立的文件夹，将这些文件放在一起：

```
swarp/
├── swarp.exe
├── msys-2.0.dll
├── msys-gcc_s-seh-1.dll
└── libwinpthread-1.dll
```

## 常见问题

### 1. 运行时提示找不到 DLL

**问题：** 双击 `swarp.exe` 时提示 "找不到 msys-2.0.dll"

**解决方法：**
```bash
# 在项目根目录运行
bash copy_dlls.sh
# 或
copy_dlls.bat
```

### 2. 编译时出现 mmap 相关错误

**问题：** 编译时出现 `implicit declaration of function 'mmap'` 错误

**解决方法：** 这个问题已经在源代码中修复。确保使用最新的代码。

### 3. 找不到 CFITSIO

**问题：** CMake 配置时找不到 CFITSIO 库

**解决方法：**
```bash
# 方法 1: 安装 CFITSIO
pacman -S mingw-w64-x86_64-cfitsio

# 方法 2: 禁用 CFITSIO 支持
cmake .. -DUSE_CFITSIO=OFF
```

### 4. 在 Windows CMD 中无法运行

**问题：** 在 Windows CMD 中运行提示找不到 DLL

**解决方法：**
1. 确保已运行 `copy_dlls.bat` 或 `copy_dlls.sh`
2. 或者将 `C:\msys64\usr\bin` 添加到系统 PATH（不推荐）
3. 或者将所有 DLL 文件复制到 swarp.exe 所在目录

## 系统要求

- **操作系统：** Windows 7 或更高版本 (64-bit)
- **编译器：** GCC 15.2.0 或更高版本 (MSYS2/MinGW-w64)
- **CMake：** 3.15 或更高版本
- **内存：** 建议 4GB 或更多
- **磁盘空间：** 至少 100MB

## 性能说明

- 启用多线程 (`USE_THREADS=ON`) 可以显著提高处理大型图像的速度
- Release 构建比 Debug 构建快得多
- 建议在处理大量数据时使用 SSD

## 技术支持

如果遇到问题，请检查：

1. **编译文档：** `BUILD_WINDOWS.md`
2. **编译报告：** `COMPILE_SUCCESS.md`
3. **原始项目：** https://astromatic.net/software/swarp

## 许可证

SWarp 是自由软件，遵循 GNU General Public License v3.0 或更高版本。

详见项目根目录的 LICENSE 文件。

## 致谢

- 原始 SWarp 项目：Emmanuel Bertin (IAP/CNRS/SorbonneU)
- Windows 移植：基于 CMake 构建系统

## 更新日志

### 2025-10-29
- ✅ 创建完整的 CMake 构建系统
- ✅ 修复 Windows 平台兼容性问题
- ✅ 添加 DLL 自动复制脚本
- ✅ 成功编译 Windows 可执行文件
- ✅ 基本功能测试通过

---

**注意：** 这是一个非官方的 Windows 移植版本。如有问题，请先查阅文档。

