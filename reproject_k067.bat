@echo off

if not exist "E:\github\swarp_win\test\output\reproject" mkdir "E:\github\swarp_win\test\output\reproject"
cd  E:/github/swarp_win/test
REM Reproject K067-8-b.fit to the grid defined by K067-8.fits
"E:\github\swarp_win\build\src\swarp.exe" "E:/github/swarp_win/test/K067-8-b.fit[0]" "E:/github/swarp_win/test/K067-8.fits[0]" ^
  -COMBINE N ^
  -RESAMPLE Y ^
  -RESAMPLE_SUFFIX .resamp.fits ^
  -IMAGEOUT_NAME "E:\github\swarp_win\test\output\reproject\coadd.fits" ^
  -WEIGHTOUT_NAME "E:\github\swarp_win\test\output\reproject\coadd.weight.fits" ^
  -VERBOSE_TYPE NORMAL

