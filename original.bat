@echo Compile original
@del lstone.obj > NUL
@SOFT\lzasmx /c /z lstone tmp
@SOFT\tlink /t /x tmp\lstone.obj
@copy /y tmp\lstone.com bin\l.com

