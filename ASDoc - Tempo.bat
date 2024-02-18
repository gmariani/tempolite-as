
set asdoc_bin="C:\flex_sdk\bin\asdoc.exe"
set title="TempoLite API Documentation"
set doc_sources=H:\SVN\CourseVector\projects\tempo\src\
set footer="Copyright 2008 Gabriel Mariani (http://labs.coursevector.com)"

set ext_lib_path=H:\SVN\CourseVector\global\as3\lib\PureMVC_AS3_MultiCore_1_0_4.swc
set src_path=H:\SVN\CourseVector\global\as3\classes\

%asdoc_bin% -sp %src_path% -ds %doc_sources% -exclude-classes com.coursevector.tempo.TempoLite -main-title %title% -window-title %title% -external-library-path %ext_lib_path% -footer %footer% -output doc\tempo -warnings -strict=false

pause