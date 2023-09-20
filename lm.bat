@echo Compile micro
@del tmp\lstone.obj > NUL
@SOFT\lzasmx /c /z lmin tmp
@SOFT\tlink /t /x /v tmp\lmin.obj
@copy /y tmp\lmin.com bin\s.com

