
set asdoc_bin="C:\flex_sdk\bin\asdoc.exe"
set title="TempoLite API Documentation"
set footer="Copyright 2008 Gabriel Mariani (http://labs.coursevector.com)"

set ext_lib_path="H:\SVN\CourseVector\global\as3\lib"
set src_path=H:\SVN\CourseVector\global\as3\classes
set src_path2=H:\SVN\CourseVector\projects\tempo\src

%asdoc_bin% -source-path %src_path2% %src_path% -library-path %ext_lib_path% -main-title %title% -window-title %title% -footer %footer% -doc-classes com.coursevector.tempo.TempoLite com.coursevector.data.PlayList fl.data.DataProvider -output doc\tempolite -exclude-dependencies

pause