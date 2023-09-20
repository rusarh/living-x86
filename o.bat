@echo Compile original
@del lstone.obj > NUL
@SOFT\lzasmx /c /z lstone2 tmp
@SOFT\tlink /t /x tmp\lstone2.obj
@copy /y tmp\lstone2.com bin\s.com

