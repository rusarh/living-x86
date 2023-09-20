@echo Compile original modified experiment
@del lstone3.obj > NUL
@SOFT\lzasmx /c /z lstone3 tmp
@SOFT\tlink /t /x tmp\lstone3.obj
@copy /y tmp\lstone3.com bin\s.com
@s


