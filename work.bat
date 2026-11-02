@echo Compile changed version
@del tmp\ls_work.obj > NUL
@SOFT\lzasmx /c /z ls_work tmp
@SOFT\tlink /t /x /v tmp\ls_work.obj
@copy /y tmp\ls_work.com bin\w.com

