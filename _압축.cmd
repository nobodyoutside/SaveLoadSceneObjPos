@edho off
SET ARCHIVE="C:\Program Files\7-Zip\7z.exe"
SET PARAMETERS=a -tzip
REM English OS = MM/DD/YYYY 
REM FOR /F "tokens=2-6 delims=/ " %%i IN ('date /t') DO SET MZP_FILE=SEO_preview_%%k%%i%%j.mzp
REM Korean OS = YYYY-MM-DD 
FOR /F "tokens=1-4 delims=- " %%i IN ('date /t') DO SET MZP_FILE=SEO_preview_%%i%%j%%k.mzp

%ARCHIVE% %PARAMETERS% %MZP_FILE% @_ArchiveList.txt

REM  pause