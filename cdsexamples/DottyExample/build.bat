@echo off
setlocal enabledelayedexpansion

rem only for interactive debugging !
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

set _SOURCE_DIR=%_ROOT_DIR%src
set _TARGET_DIR=%_ROOT_DIR%target
set _LOG_DIR=%_TARGET_DIR%\logs

set _MAIN_CLASS_NAME=Main
set _MAIN_PKG_NAME=cdsexamples
set _MAIN_CLASS=%_MAIN_PKG_NAME%.%_MAIN_CLASS_NAME%

set _APP_NAME=DottyExample
set _JAR_FILE=%_TARGET_DIR%\%_APP_NAME%.jar
set _CLASSLIST_FILE=%_TARGET_DIR%\%_APP_NAME%.classlist
set _JSA_FILE=%_TARGET_DIR%\%_APP_NAME%.jsa

call :args %*
if not %_EXITCODE%==0 goto end

rem ##########################################################################
rem ## Main

call :init
if not %_EXITCODE%==0 goto end

if %_CLEAN%==1 (
    call :clean
    if not !_EXITCODE!==0 goto end
)
if %_COMPILE%==1 (
    call :compile
    if not !_EXITCODE!==0 goto end
)
if %_RUN%==1 (
    call :run
    if not !_EXITCODE!==0 goto end
)

goto end

rem ##########################################################################
rem ## Subroutines

rem input parameter: %*
:args
set _CLEAN=0
set _COMPILE=0
set _RUN=0
set _RUN_ITER=1
set _SHARE_FLAG=off
set _VERBOSE=0
set __N=0
:args_loop
set __ARG=%~1
if not defined __ARG (
    if !__N!==0 call :help
    goto args_done
) else if not "%__ARG:~0,1%"=="-" (
    set /a __N=!__N!+1
)
if /i "%__ARG%"=="clean" ( set _CLEAN=1
) else if /i "%__ARG%"=="compile" ( set _COMPILE=1
) else if /i "%__ARG%"=="run" ( set _COMPILE=1& set _RUN=1
) else if /i "%__ARG%"=="help" ( call :help & goto end
) else if /i "%__ARG:~0,6%"=="-iter:" (
    call :iter "%__ARG:~6%"
	if not !_EXITCODE!==0 goto :eof
) else if /i "%__ARG%"=="-share" ( set _SHARE_FLAG=on
) else if /i "%__ARG%"=="-share:off" ( set _SHARE_FLAG=off
) else if /i "%__ARG%"=="-share:on" ( set _SHARE_FLAG=on
) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
) else (
    echo Error: Unknown subcommand %__ARG% 1>&2
    set _EXITCODE=1
    goto :eof
)
shift
goto :args_loop
:args_done
if %_DEBUG%==1 (
    for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set _TOTAL_TIME_START=%%i
    echo [%_BASENAME%] _CLEAN=%_CLEAN% _COMPILE=%_COMPILE% _RUN=%_RUN%
)
goto :eof

:help
echo Usage: %_BASENAME% { options ^| subcommands }
echo   Options:
echo     -iter:1..99         set number of run iterations
echo     -share[:(on^|off)]  enable/disable data sharing ^(default:off^)
echo     -verbose            display progress messages
echo   Subcommands:
echo     clean               delete generated files
echo     compile             compile Scala source files
echo     help                display this help message
echo     run                 execute main class
goto :eof

:iter
set /a __ITER=%~1
if %__ITER% geq 100 set __ITER=0
if %__ITER% lss 1 (
    echo Error: Iteration value "%~1" is out of range ^(0..99^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set _RUN_ITER=%__ITER%
goto :eof

rem output parameters: _JAVAC_CMD, _JAR_CMD, _JAVA_CMD, _JAVA_VERSION
:init
where /q jar.exe
if not %ERRORLEVEL%==0 (
    echo Error: Java archiver not found ^(run setenv.bat^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set _JAR_CMD=jar.exe

where /q java.exe
if not %ERRORLEVEL%==0 (
    echo Error: Java executable not found ^(run setenv.bat^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set _JAVA_CMD=java.exe

set __JAVA_11=
for /f "tokens=1,2,3,*" %%i in ('%_JAVA_CMD% -version 2^>^&1 ^| findstr version 2^>^&1') do (
    set _JAVA_VERSION=%%~k
    for /f %%j in ('echo %%~k ^| findstr "^1[1-9]\. ^1[1-9]-ea" 2^>NUL') do set __JAVA_11=1
)
if not defined __JAVA_11 (
    echo Error: Java 11 LTS or newer is required ^(found %_JAVA_VERSION%^) 1>&2
    set _EXITCODE=1
    goto :eof
)

where /q dotc.bat
if not %ERRORLEVEL%==0 (
    echo Error: Scala compiler not found ^(run setenv.bat^) 1>&2
    set _EXITCODE=1
    goto :eof
)
set _COMPILE_CMD=dotc.bat
set _RUN_CMD=dotr.bat
goto :eof

:clean
if not exist "%_TARGET_DIR%\" goto :eof
if %_DEBUG%==1 echo [%_BASENAME%] rmdir /s /q %_TARGET_DIR%
rmdir /s /q "%_TARGET_DIR%"
if not %ERRORLEVEL%==0 (
    echo Error: Failed to clean output directory %_TARGET% 1>&2
    set _EXITCODE=1
	goto :eof
)
goto :eof

:compile
set __SOURCE_FILE=%_SOURCE_DIR%\main\scala\%_MAIN_CLASS_NAME%.scala
if not exist "%__SOURCE_FILE%" (
    echo Error: Java source file not found ^(%__SOURCE_FILE%^) 1>&2
	set _EXITCODE=1
	goto :eof
)
set __CLASSES_DIR=%_TARGET_DIR%\classes
if not exist "%__CLASSES_DIR%\" mkdir "%__CLASSES_DIR%" 1>NUL

set __TIMESTAMP_FILE=%__CLASSES_DIR%\.latest-build

set __SCALA_SOURCE_FILES=
for /f %%i in ('dir /s /b "%_SOURCE_DIR%\main\scala\*.scala" 2^>NUL') do (
    set __SCALA_SOURCE_FILES=!__SCALA_SOURCE_FILES! %%i
)

call :compile_required "%__TIMESTAMP_FILE%" "%__SCALA_SOURCE_FILES%"
if %_COMPILE_REQUIRED%==0 goto :eof

set __COMPILE_OPTS=-deprecation
if %_DEBUG%==1 echo [%_BASENAME%] call %_COMPILE_CMD% %__COMPILE_OPTS% -d %__CLASSES_DIR% %__SCALA_SOURCE_FILES%
call %_COMPILE_CMD% %__COMPILE_OPTS% -d %__CLASSES_DIR% %__SCALA_SOURCE_FILES%
if not %ERRORLEVEL%==0 (
    echo Error: Failed to compile Scala source file %__SOURCE_FILE% 1>&2
    set _EXITCODE=1
    goto :eof
)

if %_VERBOSE%==1 echo Create Java archive !_JAR_FILE:%_ROOT_DIR%=!
set __MANIFEST_FILE=%_TARGET_DIR%\MANIFEST.MF
(
    echo Manifest-Version: 1.0
	echo Built-By: Stephane
    echo Build-Jdk: %_JAVA_VERSION%
    echo Specification-Title: %_MAIN_PKG_NAME%
    echo Specification-Version: 0.1-SNAPSHOT
    echo Implementation-Title: %_MAIN_PKG_NAME%
    echo Implementation-Version: 0.1-SNAPSHOT
	echo Main-Class: %_MAIN_CLASS%
) > %__MANIFEST_FILE%
if %_DEBUG%==1 echo [%_BASENAME%] %_JAR_CMD% -cfm %_JAR_FILE% %__MANIFEST_FILE% -C %__CLASSES_DIR% .
%_JAR_CMD% -cfm %_JAR_FILE% %__MANIFEST_FILE% -C %__CLASSES_DIR% .
if not %ERRORLEVEL%==0 (
    echo Error: Failed to generate Java archive %_JAR_FILE% 1>&2
    set _EXITCODE=1
    goto :eof
)

if %_DEBUG%==1 ( set __REDIRECT_STDOUT=
) else ( set __REDIRECT_STDOUT=1^>NUL
)

if %_VERBOSE%==1 echo Create class list file !_CLASSLIST_FILE:%_ROOT_DIR%=!
rem Important: options containing an "=" character must be quoted
set __JAVA_TOOL_OPTS="-J-XX:DumpLoadedClassList=%_CLASSLIST_FILE%"
if %_DEBUG%==1 (
    set __JAVA_TOOL_OPTS=!__JAVA_TOOL_OPTS! "-J-Xlog:class+path^=info"
) else if %_VERBOSE%==1 (
    set __LOG_FILE=%_LOG_DIR%\log_classlist.log
    if not exist "%_LOG_DIR%\" mkdir "%_LOG_DIR%" 1>NUL
    rem !!! Ignore drive letter (temporary hack, see JDK-8215398)
    set __JAVA_TOOL_OPTS=!__JAVA_TOOL_OPTS! "-J-Xlog:class+path:file=!__LOG_FILE:~2!"
) else (
    set __JAVA_TOOL_OPTS=!__JAVA_TOOL_OPTS! -J-Xlog:disable
)
if %_DEBUG%==1 echo [%_BASENAME%] call %_RUN_CMD% %__JAVA_TOOL_OPTS% -classpath %_JAR_FILE% %_MAIN_CLASS%
call %_RUN_CMD% %__JAVA_TOOL_OPTS% -classpath %_JAR_FILE% %_MAIN_CLASS% %__REDIRECT_STDOUT%
if not %ERRORLEVEL%==0 (
    echo Error: Failed to create file %_CLASSLIST_FILE% 1>&2
    set _EXITCODE=1
    goto :eof
)

if %_VERBOSE%==1 echo Create Java shared archive !_JSA_FILE:%_ROOT_DIR%=!
set __JAVA_TOOL_OPTS=-J-Xshare:dump "-J-XX:SharedClassListFile=%_CLASSLIST_FILE%" "-J-XX:SharedArchiveFile=%_JSA_FILE%"
if %_DEBUG%==1 (
    set __JAVA_TOOL_OPTS=!__JAVA_TOOL_OPTS! "-J-Xlog:class+path=info"
) else if %_VERBOSE%==1 (
    set __LOG_FILE=%_LOG_DIR%\log_dump.log
    if not exist "%_LOG_DIR%\" mkdir "%_LOG_DIR%" 1>NUL
    rem !!! Ignore drive letter (temporary hack, see JDK-8215398)
    set __JAVA_TOOL_OPTS=!__JAVA_TOOL_OPTS! "-J-Xlog:class+path:file=!__LOG_FILE:~2!"
) else (
    set __JAVA_TOOL_OPTS=!__JAVA_TOOL_OPTS! -J-Xlog:disable
)
if %_DEBUG%==1 echo [%_BASENAME%] call %_RUN_CMD% %__JAVA_TOOL_OPTS% -classpath %_JAR_FILE% %_MAIN_CLASS%
call %_RUN_CMD% %__JAVA_TOOL_OPTS% -classpath %_JAR_FILE% %_MAIN_CLASS% %__REDIRECT_STDOUT%
if not %ERRORLEVEL%==0 (
    echo Error: Failed to create shared archive %_JAR_FILE% 1>&2
    set _EXITCODE=1
    goto :eof
)
for /f %%i in ('powershell -C "Get-Date -uformat %%Y%%m%%d%%H%%M%%S"') do (
    echo %%i> %__TIMESTAMP_FILE%
)
goto :eof

rem input parameter: 1=timestamp file 2=source files
rem output parameter: _COMPILE_REQUIRED
:compile_required
set __TIMESTAMP_FILE=%~1
set __SOURCE_FILES=%~2

set __SOURCE_TIMESTAMP=00000000000000
set __N=0
for %%i in (%__SOURCE_FILES%) do (
    call :timestamp "%%i"
    if %_DEBUG%==1 echo [%_BASENAME%] !_TIMESTAMP! %%i
    call :newer "!_TIMESTAMP!" "!__SOURCE_TIMESTAMP!"
    if !_NEWER!==1 set __SOURCE_TIMESTAMP=!_TIMESTAMP!
    set /a __N+=1
)
if exist "%__TIMESTAMP_FILE%" ( set /p __CLASS_TIMESTAMP=<%__TIMESTAMP_FILE%
) else ( set __CLASS_TIMESTAMP=00000000000000
)
if %_DEBUG%==1 echo [%_BASENAME%] %__CLASS_TIMESTAMP% %__TIMESTAMP_FILE%

call :newer "%__SOURCE_TIMESTAMP%" "%__CLASS_TIMESTAMP%"
set _COMPILE_REQUIRED=%_NEWER%
if %_COMPILE_REQUIRED%==0 (
    if %_RUN%==0 echo No compilation needed ^(%__N% source files^)
)
goto :eof

rem output parameter: _NEWER
:newer
set __TIMESTAMP1=%~1
set __TIMESTAMP2=%~2

set __TIMESTAMP1_DATE=%__TIMESTAMP1:~0,8%
set __TIMESTAMP1_TIME=%__TIMESTAMP1:~-6%

set __TIMESTAMP2_DATE=%__TIMESTAMP2:~0,8%
set __TIMESTAMP2_TIME=%__TIMESTAMP2:~-6%

if %__TIMESTAMP1_DATE% gtr %__TIMESTAMP2_DATE% ( set _NEWER=1
) else if %__TIMESTAMP1_DATE% lss %__TIMESTAMP2_DATE% ( set _NEWER=0
) else if %__TIMESTAMP1_TIME% gtr %__TIMESTAMP2_TIME% ( set _NEWER=1
) else ( set _NEWER=0
)
goto :eof

rem input parameter: 1=file path
rem output parameter: _TIMESTAMP
:timestamp
set __FILE_PATH=%~1

set _TIMESTAMP=00000000000000
for /f %%i in ('powershell -C "(Get-ChildItem '%__FILE_PATH%').LastWriteTime | Get-Date -uformat %%Y%%m%%d%%H%%M%%S"') do (
    set _TIMESTAMP=%%i
)
goto :eof

:run
set __N=1
:run_iter
set __SHARE_LOG_FILE=%_LOG_DIR%\log_share_%_SHARE_FLAG%.log
rem Important: options containing an "=" character must be quoted
set __JAVA_TOOL_OPTS=-J-Xshare:%_SHARE_FLAG% "-J-XX:SharedArchiveFile=%_JSA_FILE%"
if %_DEBUG%==1 (
    set __JAVA_TOOL_OPTS=!__JAVA_TOOL_OPTS! "-J-Xlog:class+load^=info"
) else if %_VERBOSE%==1 (
    if not exist "%_LOG_DIR%\" mkdir "%_LOG_DIR%" 1>NUL
    rem !!! Ignore drive letter (temporary hack, see JDK-8215398)
    set __JAVA_TOOL_OPTS=!__JAVA_TOOL_OPTS! "-J-Xlog:class+load:file=!__SHARE_LOG_FILE:~2!"
) else (
    set __JAVA_TOOL_OPTS=!__JAVA_TOOL_OPTS! -J-Xlog:disable
)
if %_DEBUG%==1 echo [%_BASENAME%] call %_RUN_CMD% %__JAVA_TOOL_OPTS% -classpath %_JAR_FILE% %_MAIN_CLASS%
call %_RUN_CMD% %__JAVA_TOOL_OPTS% -classpath %_JAR_FILE% %_MAIN_CLASS%
if not %ERRORLEVEL%==0 (
    echo Error: Failed to execute class %_MAIN_CLASS% 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_VERBOSE%==1 if not %_DEBUG%==1 (
    if %_DEBUG%==1 echo [%_BASENAME%] call :stats "%__SHARE_LOG_FILE%" "%__N%"
    call :stats "%__SHARE_LOG_FILE%" "%__N%"
)
if %__N% lss %_RUN_ITER% (
    set /a __N+=1
    goto :run_iter
)
goto :eof

rem input parameter: %1=share log file %2=n-th iteration
:stats
set __SHARE_LOG_FILE=%~1
set __N=%~2
if not exist "%__SHARE_LOG_FILE%" (
    echo Error: Share log file %__SHARE_LOG_FILE% not found 1>&2
    set _EXITCODE=1
    goto :eof
)
set __N_SHARED=0
if %_DEBUG%==1 echo [%_BASENAME%] findstr shared "%__SHARE_LOG_FILE%"
for /f "delims=" %%i in ('findstr shared "%__SHARE_LOG_FILE%"') do (
    set /a __N_SHARED+=1
    if %_DEBUG%==1 echo %%i
)
set __N_FILE=0
set __FILES=
if %_DEBUG%==1 echo [%_BASENAME%] findstr /c:"file:/" /c:"jrt:/" "%__SHARE_LOG_FILE%"
for /f "tokens=1,*" %%i in ('findstr /c:"file:/" /c:"jrt:/" "%__SHARE_LOG_FILE%"') do (
    set /a __N_FILE+=1
    if %_DEBUG%==1 echo %%j
	if !__N_FILE! lss 2 ( set __FILES=!__FILES! %%j
	) else if not "!__FILES:.=!"=="!__FILES!" ( set __FILES=!__FILES! ...
	)
)

set __N_MAIN=0
if %_DEBUG%==1 echo [%_BASENAME%] findstr /c:"] %_MAIN_PKG_NAME%." "%__SHARE_LOG_FILE%"
for /f "delims=" %%i in ('findstr /c:"] %_MAIN_PKG_NAME%." "%__SHARE_LOG_FILE%"') do (
    set /a __N_MAIN+=1
)
rem Java libraries
set __N_JAVA_IO=0
if %_DEBUG%==1 echo [%_BASENAME%] findstr /c:"] java.io." "%__SHARE_LOG_FILE%"
for /f "delims=" %%i in ('findstr /c:"] java.io." "%__SHARE_LOG_FILE%"') do (
    set /a __N_JAVA_IO+=1
)
set __N_JAVA_LANG=0
if %_DEBUG%==1 echo [%_BASENAME%] findstr /c:"] java.lang." "%__SHARE_LOG_FILE%"
for /f "delims=" %%i in ('findstr /c:"] java.lang." "%__SHARE_LOG_FILE%"') do (
    set /a __N_JAVA_LANG+=1
)
set __N_JAVA_NET=0
if %_DEBUG%==1 echo [%_BASENAME%] findstr /c:"] java.net." "%__SHARE_LOG_FILE%"
for /f "delims=" %%i in ('findstr /c:"] java.net." "%__SHARE_LOG_FILE%"') do (
    set /a __N_JAVA_NET+=1
)
set __N_JAVA_NIO=0
if %_DEBUG%==1 echo [%_BASENAME%] findstr /c:"] java.nio." "%__SHARE_LOG_FILE%"
for /f "delims=" %%i in ('findstr /c:"] java.nio." "%__SHARE_LOG_FILE%"') do (
    set /a __N_JAVA_NIO+=1
)
set __N_JAVA_SECURITY=0
if %_DEBUG%==1 echo [%_BASENAME%] findstr /c:"] java.security." "%__SHARE_LOG_FILE%"
for /f "delims=" %%i in ('findstr /c:"] java.security." "%__SHARE_LOG_FILE%"') do (
    set /a __N_JAVA_SECURITY+=1
)
set __N_JAVA_UTIL=0
if %_DEBUG%==1 echo [%_BASENAME%] findstr /c:"] java.util." "%__SHARE_LOG_FILE%"
for /f "delims=" %%i in ('findstr /c:"] java.util." "%__SHARE_LOG_FILE%"') do (
    set /a __N_JAVA_UTIL+=1
)
set __N_JDK=0
if %_DEBUG%==1 echo [%_BASENAME%] findstr /c:"] jdk." "%__SHARE_LOG_FILE%"
for /f "delims=" %%i in ('findstr /c:"] jdk." "%__SHARE_LOG_FILE%"') do (
    set /a __N_JDK+=1
)
set __N_SUN=0
if %_DEBUG%==1 echo [%_BASENAME%] findstr /c:"] sun." "%__SHARE_LOG_FILE%"
for /f "delims=" %%i in ('findstr /c:"] sun." "%__SHARE_LOG_FILE%"') do (
    set /a __N_SUN+=1
)

rem Scala libraries
set __N_SCALA=0
if %_DEBUG%==1 echo [%_BASENAME%] findstr /c:"] scala." "%__SHARE_LOG_FILE%"
for /f "delims=" %%i in ('findstr /c:"] scala." "%__SHARE_LOG_FILE%" ^| findstr /v "scala.collection scala.io scala.math scala.reflect scala.runtime scala.sys scala.util"') do (
    set /a __N_SCALA+=1
)
set __N_SCALA_COLLECTION=0
if %_DEBUG%==1 echo [%_BASENAME%] findstr /c:"] scala.collection." "%__SHARE_LOG_FILE%"
for /f "delims=" %%i in ('findstr /c:"] scala.collection." "%__SHARE_LOG_FILE%"') do (
    set /a __N_SCALA_COLLECTION+=1
)
set __N_SCALA_IO=0
if %_DEBUG%==1 echo [%_BASENAME%] findstr /c:"] scala.io." "%__SHARE_LOG_FILE%"
for /f "delims=" %%i in ('findstr /c:"] scala.io." "%__SHARE_LOG_FILE%"') do (
    set /a __N_SCALA_IO+=1
)
set __N_SCALA_MATH=0
if %_DEBUG%==1 echo [%_BASENAME%] findstr /c:"] scala.math." "%__SHARE_LOG_FILE%"
for /f "delims=" %%i in ('findstr /c:"] scala.math." "%__SHARE_LOG_FILE%"') do (
    set /a __N_SCALA_MATH+=1
)
set __N_SCALA_REFLECT=0
if %_DEBUG%==1 echo [%_BASENAME%] findstr /c:"] scala.reflect." "%__SHARE_LOG_FILE%"
for /f "delims=" %%i in ('findstr /c:"] scala.reflect." "%__SHARE_LOG_FILE%"') do (
    set /a __N_SCALA_REFLECT+=1
)
set __N_SCALA_RUNTIME=0
if %_DEBUG%==1 echo [%_BASENAME%] findstr /c:"] scala.runtime." "%__SHARE_LOG_FILE%"
for /f "delims=" %%i in ('findstr /c:"] scala.runtime." "%__SHARE_LOG_FILE%"') do (
    set /a __N_SCALA_RUNTIME+=1
)
set __N_SCALA_SYS=0
if %_DEBUG%==1 echo [%_BASENAME%] findstr /c:"] scala.sys." "%__SHARE_LOG_FILE%"
for /f "delims=" %%i in ('findstr /c:"] scala.sys." "%__SHARE_LOG_FILE%"') do (
    set /a __N_SCALA_SYS+=1
)
set __N_SCALA_UTIL=0
if %_DEBUG%==1 echo [%_BASENAME%] findstr /c:"] scala.util." "%__SHARE_LOG_FILE%"
for /f "delims=" %%i in ('findstr /c:"] scala.util." "%__SHARE_LOG_FILE%"') do (
    set /a __N_SCALA_UTIL+=1
)

set _LOAD_TIME[%__N%]=999.999s
for /f "delims=[]" %%i in ('powershell -c "Get-Content %__SHARE_LOG_FILE% | select -Last 1"') do (
    set _T_SECS=%%i
    set __LOAD_TIME[%__N%]=!_T_SECS:s=!
)
if %__N% equ %_RUN_ITER% (
    if "%_SHARE_FLAG%"=="off" ( set __FILE_TEXT=%__N_FILE%
	) else if %__N_FILE% gtr 0 ( set __FILE_TEXT=%__N_FILE% ^(%__FILES:~1%^)
	) else ( set __FILE_TEXT=%__N_FILE%
	)
    call :average
	set __LOAD_TIME_AVERAGE=!_AVERAGE!s
	set /a __N_PACKAGES=__N_MAIN
	rem Java libraries
	set /a __N_PACKAGES=__N_PACKAGES+__N_JAVA_IO+__N_JAVA_LANG+__N_JAVA_NET+__N_JAVA_NIO
	set /a __N_PACKAGES=__N_PACKAGES+__N_JAVA_SECURITY+__N_JAVA_UTIL+__N_JDK+__N_SUN
	rem Scala libraries
	set /a __N_PACKAGES=__N_PACKAGES+__N_SCALA+__N_SCALA_COLLECTION+__N_SCALA_IO+__N_SCALA_MATH
	set /a __N_PACKAGES=__N_PACKAGES+__N_SCALA_REFLECT+__N_SCALA_RUNTIME+__N_SCALA_SYS+__N_SCALA_UTIL
    echo Statistics ^(see details in !__SHARE_LOG_FILE:%_ROOT_DIR%=!^):
    echo    Share flag       : %_SHARE_FLAG%
    echo    Shared classes   : %__N_SHARED%
    echo    File/jrt classes : !__FILE_TEXT!
    echo    Average load time: !__LOAD_TIME_AVERAGE!
    echo    #iteration^(s^)    : %_RUN_ITER%
	echo Classes per package ^(!__N_PACKAGES!^):
	echo    java.io.* ^(%__N_JAVA_IO%^), java.lang.* ^(%__N_JAVA_LANG%^), java.net.* ^(%__N_JAVA_NET%^), java.nio.* ^(%__N_JAVA_NIO%^)
	echo    java.security.* ^(%__N_JAVA_SECURITY%^), java.util.* ^(%__N_JAVA_UTIL%^), jdk.* ^(%__N_JDK%^), sun.* ^(%__N_SUN%^)
	echo    [APP] %_MAIN_PKG_NAME%.* ^(%__N_MAIN%^)
	echo    scala.* ^(%__N_SCALA%^), scala.collection.* ^(%__N_SCALA_COLLECTION%^), scala.io.* ^(%__N_SCALA_IO%^), scala.math.* ^(%__N_SCALA_MATH%^)
	echo    scala.reflect.* ^(%__N_SCALA_REFLECT%^), scala.runtime.* ^(%__N_SCALA_RUNTIME%^), scala.sys.* ^(%__N_SCALA_SYS%^), scala.util.* ^(%__N_SCALA_UTIL%^)
)
goto :eof

rem output parameter: _AVERAGE
:average
rem we construct string __LIST to be passed into the ps1 script
set __LIST=
for /l %%i in (1, 1, %_RUN_ITER%) do set __LIST=!__LIST!,!__LOAD_TIME[%%i]!
set __PS1_SCRIPT= ^
$array=%__LIST:~1%; ^
$avgObj=$array ^| Measure-Object -Average; ^
[math]::Round($avgObj.Average,3)

set _AVERAGE=0.000
if %_DEBUG%==1 echo [%_BASENAME%] powershell -c "..."
for /f %%i in ('powershell -c "%__PS1_SCRIPT%"') do set _AVERAGE=%%i
set _AVERAGE=%_AVERAGE:,=.%
if %_DEBUG%==1 echo [%_BASENAME%] __LIST=%__LIST% _AVERAGE=%_AVERAGE%
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
if %_DEBUG%==1 echo [%_BASENAME%] _EXITCODE=%_EXITCODE%
exit /b %_EXITCODE%
endlocal
