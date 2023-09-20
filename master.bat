cd master
@del lstone2.obj > NUL
lzasmx /c lstone2
tlink /t /x lstone2.obj
copy /y lstone2.com s.com

