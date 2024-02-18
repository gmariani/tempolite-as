
set asdoc_bin="C:\flex_sdk\bin\asdoc.exe"
set title="TempoLite API Documentation"
set footer="Copyright 2008 Gabriel Mariani (http://labs.coursevector.com)"

set ext_lib_path="C:\Program Files\Adobe\Adobe Flash CS3\en\Configuration\ActionScript 3.0\Classes"
set src_path=src

%asdoc_bin% -source-path %src_path% -library-path %ext_lib_path% -main-title %title% -window-title %title% -footer %footer% -exclude-classes cv.formats.RSS -doc-sources src\cv\data src\cv\events src\cv\formats src\cv\interfaces src\cv\media src\cv\Tempolite.as src\fl\ -output doc\tempolite

pause