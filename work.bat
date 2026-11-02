@echo Compile changed version
@del tmp\lstone.obj > NUL
@SOFT\lzasmx /c /z lstone tmp
@SOFT\tlink /t /x /v tmp\lstone.obj
@copy /y tmp\lstone.com bin\s.com

