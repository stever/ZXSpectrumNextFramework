cls
del framework.dat.map
del framework.dat
del framework.nex
..\bin\snasm -map framework.asm framework.dat
if NOT %ERRORLEVEL% == 0 goto doexit

rem simple 48k model
..\bin\CSpect.exe -w4 -debug -break -60 -fps -map=framework.dat.map -zxnext -mmc=.\ framework.nex

:doexit

exit