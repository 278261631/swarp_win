# SWarp

[![Build Status](https://travis-ci.org/astromatic/swarp.svg?branch=master)](https://travis-ci.org/astromatic/swarp
[![Coverity Scan Build Status](https://scan.coverity.com/projects/swarp/badge.svg)](https://scan.coverity.com/projects/swarp "Coverity Badge")
[![Documentation Status](https://readthedocs.org/projects/swarp/badge/?version=latest)](http://swarp.readthedocs.io/en/latest/?badge=latest)

[Swarp] resamples and coadds FITS images to an arbitrary astrometric projection

Check out the on-line [documentation] and the [official web page].

[SWarp]: https://astromatic.net/software/swarp
[documentation]: https://raw.githubusercontent.com/astromatic/swarp/refs/heads/legacy_doc/prevdoc/swarp.pdf
[official web page]: https://astromatic.net/software/swarp

---

## Windows Build

This repository includes a CMake-based build system for Windows compilation.

### Quick Start (Windows)

```bash
# In MSYS2 MinGW 64-bit terminal
mkdir build && cd build
cmake .. -G "Unix Makefiles" -DCMAKE_BUILD_TYPE=Release -DUSE_THREADS=ON -DUSE_CFITSIO=OFF
make -j4

# Copy required DLLs
cd ..
bash copy_dlls.sh

# Test
./build/src/swarp.exe -v
```

### Documentation

- **[BUILD_WINDOWS.md](BUILD_WINDOWS.md)** - Detailed Windows build instructions
- **[README_WINDOWS.md](README_WINDOWS.md)** - Windows usage guide
- **[COMPILE_SUCCESS.md](COMPILE_SUCCESS.md)** - Build success report
- **[FINAL_SUMMARY.md](FINAL_SUMMARY.md)** - Complete project summary

### Distribution Package

To create a standalone distribution package:

```bash
bash create_dist.sh
```

This creates a `dist/` directory with all necessary files and a ZIP archive.

### Requirements

- Windows 7 or higher (64-bit)
- MSYS2/MinGW-w64
- CMake 3.15+
- GCC 15.2.0+

For more details, see [BUILD_WINDOWS.md](BUILD_WINDOWS.md).
