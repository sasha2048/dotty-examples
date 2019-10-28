@echo off

rem ##########################################################################
rem ## This batch file is based on configuration file .drone.yml

setlocal enabledelayedexpansion

rem only for interactive debugging
set _DEBUG=0

rem ##########################################################################
rem ## Environment setup

set _BASENAME=%~n0

set _EXITCODE=0

for %%f in ("%~dp0") do set _ROOT_DIR=%%~sf

call :env
if not %_EXITCODE%==0 goto end

call :args %*
if not %_EXITCODE%==0 goto end
if defined _HELP call :help & exit /b %_EXITCODE%

rem ##########################################################################
rem ## Main

call :init
if not %_EXITCODE%==0 goto end

if defined _CLEAN_ALL (
    call :clean_all
    if not !_EXITCODE!==0 goto end
)
if defined _CLONE (
    call :clone
    if not !_EXITCODE!==0 goto end
)
if defined _COMPILE (
    call :test
    if not !_EXITCODE!==0 goto end
)
if defined _BOOTSTRAP (
    call :test_bootstrapped
    rem if not !_EXITCODE!==0 goto end
    if not !_EXITCODE!==0 (
        if defined _IGNORE ( echo ###### Warning: _EXITCODE=!_EXITCODE! ####### 1>&2
        ) else ( goto end
        )
    )
)
if defined _COMMUNITY (
    call :community_build
    if not !_EXITCODE!==0 goto end
)
if defined _SBT (
    call :test_sbt
    if not !_EXITCODE!==0 goto end
)
if defined _DOCUMENTATION (
    call :documentation
    if not !_EXITCODE!==0 goto end
)
if defined _ARCHIVES (
    call :archives
    if not !_EXITCODE!==0 goto end
)
goto end

rem ##########################################################################
rem ## Subroutines

rem output parameter(s): _SCRIPTS_DIR,
rem                      _DRONE_BUILD_EVENT, _DRONE_REMOTE_URL, _DRONE_BRANCH
rem                      _DEBUG_LABEL, _ERROR_LABEL, _WARNING_LABEL
:env
set _SCRIPTS_DIR=%_ROOT_DIR%\project\scripts

call %_SCRIPTS_DIR%\common.bat
if not %_EXITCODE%==0 goto end

rem set _DRONE_BUILD_EVENT=pull_request
set _DRONE_BUILD_EVENT=
set _DRONE_REMOTE_URL=
set _DRONE_BRANCH=

rem ANSI colors in standard Windows 10 shell
rem see https://gist.github.com/mlocati/#file-win10colors-cmd
set _DEBUG_LABEL=[46m[%_BASENAME%][0m
set _ERROR_LABEL=[91mError[0m:
set _WARNING_LABEL=[93mWarning[0m:
goto :eof

rem input parameter: %*
rem output parameters: _CLONE, _COMPILE, _DOCUMENTATION, _SBT, _TIMER, _VERBOSE
:args
set _ARCHIVES=
set _BOOTSTRAP=
set _COMPILE=
set _CLEAN_ALL=
set _CLONE=
set _COMMUNITY=
set _DOCUMENTATION=
set _HELP=
set _SBT=
set _TIMER=0
set _VERBOSE=0

set __N=0
:args_loop
set "__ARG=%~1"
if not defined __ARG (
    if !__N!==0 set _HELP=1
    goto args_done
)
if "%__ARG:~0,1%"=="-" (
    rem option
    if /i "%__ARG%"=="-debug" ( set _DEBUG=1
    ) else if /i "%__ARG%"=="-timer" ( set _TIMER=1
    ) else if /i "%__ARG%"=="-verbose" ( set _VERBOSE=1
    ) else (
        echo %_ERROR_LABEL% Unknown option %__ARG% 1>&2
        set _EXITCODE=1
        goto :args_done
    )
) else (
    rem subcommand
	set /a __N=+1
    if /i "%__ARG:~0,4%"=="arch" (
        if not "%__ARG:~-5%"=="-only" set _CLONE=1& set _COMPILE=1& set _BOOTSTRAP=1
        set _ARCHIVES=1
    ) else if /i "%__ARG:~0,4%"=="boot" (
        if not "%__ARG:~-5%"=="-only" set _CLONE=1& set _COMPILE=1
        set _BOOTSTRAP=1
    ) else if /i "%__ARG%"=="cleanall" ( set _CLEAN_ALL=1
    ) else if /i "%__ARG%"=="clone" ( set _CLONE=1
    ) else if /i "%__ARG:~0,7%"=="compile" (
        if not "%__ARG:~-5%"=="-only" set _CLONE=1
        set _COMPILE=1
    ) else if /i "%__ARG:~0,9%"=="community" (
        rem if not "%__ARG:~-5%"=="-only" set _CLONE=1& set _COMPILE=1& set _BOOTSTRAP=1
        set _COMMUNITY=1
    ) else if /i "%__ARG:~0,3%"=="doc" (
        if not "%__ARG:~-5%"=="-only" set _CLONE=1& set _COMPILE=1& set _BOOTSTRAP=1
        set _DOCUMENTATION=1
    ) else if /i "%__ARG%"=="help" ( set _HELP=1
    ) else if /i "%__ARG%"=="sbt" (
        set _CLONE=1& set _COMPILE=1& set _BOOTSTRAP=1& set _SBT=1
    ) else if /i "%__ARG%"=="sbt-only" (
        set _SBT=1
    ) else (
        echo %_ERROR_LABEL% Unknown subcommand %__ARG% 1>&2
        set _EXITCODE=1
        goto :args_done
    )
)
shift
goto args_loop
:args_done
if %_TIMER%==1 (
    for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set _TIMER_START=%%i
)
goto :eof

:help
echo Usage: %_BASENAME% { options ^| subcommands }
echo   Options:
echo     -timer                 display total execution time
echo     -verbose               display environment settings
echo   Subcommands:
echo     arch[ives]             generate gz/zip archives (after bootstrap)
echo     boot[strap]            generate+test bootstrapped compiler (after compile)
echo     cleanall               clean project (sbt+git) and quit
echo     clone                  update submodules
echo     compile                generate+test 1st stage compiler (after clone)
echo     community              test community-build
echo     doc[umentation]        generate documentation (after bootstrap)
echo     help                   display this help message
echo     sbt                    test sbt-dotty (after bootstrap)
echo   Advanced subcommands (no deps):
echo     arch[ives]-only        generate ONLY gz/zip archives
echo     boot[strap]-only       generate+test ONLY bootstrapped compiler
echo     compile-only           generate+test ONLY 1st stage compiler
echo     doc[umentation]-only]  generate ONLY documentation
echo     sbt-only               test ONLY sbt-dotty

goto :eof

:init
if %_VERBOSE%==1 (
    for /f "delims=" %%i in ('where git.exe') do (
        if not defined __GIT_CMD1 set __GIT_CMD1=%%i
    )
    for /f "delims=" %%i in ('where java.exe') do (
        if not defined __JAVA_CMD1 set __JAVA_CMD1=%%i
    )
    set __BRANCH_NAME=unknown
    for /f %%i in ('!__GIT_CMD1! rev-parse --abbrev-ref HEAD') do set __BRANCH_NAME=%%i
    echo Tool paths
    echo    GIT_CMD=!__GIT_CMD1!
    echo    JAVA_CMD=!__JAVA_CMD1!
    echo    SBT_CMD=%_SBT_CMD%
    echo Tool options
    echo    JAVA_OPTS=%JAVA_OPTS%
    echo    SBT_OPTS=%SBT_OPTS%
    echo Current Git branch:
    echo    !__BRANCH_NAME!
    echo.
)
goto :eof

:clean_all
echo run sbt clean and git clean -xdf --exclude=*.bat --exclude=*.ps1
if %_DEBUG%==1 echo %_DEBUG_LABEL% call "%_SBT_CMD%" clean 1>&2
call "%_SBT_CMD%" clean
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% %_GIT_CMD% clean -xdf --exclude=*.bat --exclude=*.ps1 1>&2
%_GIT_CMD% clean -xdf --exclude=*.bat --exclude=*.ps1
if not %ERRORLEVEL%==0 (
    set _EXITCODE=1
    goto :eof
)
goto :eof

:clone
if "%_DRONE_BUILD_EVENT%"=="pull_request" if defined _DRONE_REMOTE_URL (
    %_GIT_CMD% config user.email "dotty.bot@epfl.ch"
    %_GIT_CMD% config user.name "Dotty CI"
    %_GIT_CMD% pull "%_DRONE_REMOTE_URL%" "%_DRONE_BRANCH%"
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% %_GIT_CMD% submodule update --init --recursive --jobs 3 1>&2
%_GIT_CMD% submodule update --init --recursive --jobs 3
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to update Git submodules 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:test
echo sbt compile and sbt test
if %_DEBUG%==1 echo %_DEBUG_LABEL% "%_SBT_CMD%" "compile ;test" 1>&2
call "%_SBT_CMD%" "compile ;test"
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to run sbt command "compile ;test" 1>&2
    set _EXITCODE=1
    goto :eof
)

rem see shell script project/scripts/cmdTests
if %_DEBUG%==1 echo %_DEBUG_LABEL% %_SCRIPTS_DIR%\cmdTests.bat 1>&2
call %_SCRIPTS_DIR%\cmdTests.bat
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to run cmdTest.bat 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:test_bootstrapped
if %_DEBUG%==1 echo %_DEBUG_LABEL% call "%_SBT_CMD%" ";dotty-bootstrapped/compile ;dotty-bootstrapped/test ;dotty-semanticdb/compile ;dotty-semanticdb/test ;sjsSandbox/run"
call "%_SBT_CMD%" ";dotty-bootstrapped/compile ;dotty-bootstrapped/test ;dotty-semanticdb/compile ;dotty-semanticdb/test ;sjsSandbox/run" 1>&2
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to run sbt command ";dotty-bootstrapped/compile ;dotty-bootstrapped/test ;dotty-semanticdb/compile ;dotty-semanticdb/test ;sjsSandbox/run" 1>&2
    set _EXITCODE=1
    goto :eof
)

rem see shell script project/scripts/bootstrapCmdTests
if %_DEBUG%==1 echo %_DEBUG_LABEL% call %_SCRIPTS_DIR%\bootstrapCmdTests.bat 1>&2
call %_SCRIPTS_DIR%\bootstrapCmdTests.bat
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to run bootstrapCmdTests.bat 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:community_build
if %_DEBUG%==1 echo %_DEBUG_LABEL% %_GIT_CMD% submodule update --init --recursive --jobs 7 1>&2
%_GIT_CMD% submodule update --init --recursive --jobs 7
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to update Git submodules 1>&2
    set _EXITCODE=1
    goto :eof
)
echo sbt community-build/test
if %_DEBUG%==1 echo %_DEBUG_LABEL% call "%_SBT_CMD%" "-Dsbt.cmd=%_SBT_CMD%" community-build/test 1>&2
call "%_SBT_CMD%" "-Dsbt.cmd=%_SBT_CMD%" community-build/test
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to run sbt command community-build/test 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:test_sbt
if %_DEBUG%==1 echo %_DEBUG_LABEL% call "%_SBT_CMD%" sbt-dotty/scripted 1>&2
call "%_SBT_CMD%" sbt-dotty/scripted
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to run sbt command sbt-dotty/scripted 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:test_java11
set __PATH=C:\opt
for /f "delims=" %%f in ('dir /ad /b "!__PATH!\jdk-11*" 2^>NUL') do set __JDK11_HOME=!__PATH!\%%f
if not defined __JDK11_HOME (
    set __PATH=C:\Progra~1\Java
    for /f %%f in ('dir /ad /b "!__PATH!\jdk-11*" 2^>NUL') do set __JDK11_HOME=!__PATH!\%%f
)
if not defined __JDK11_HOME (
    echo %_ERROR_LABEL% Java SDK 11 installation directory not found 1>&2
    set _EXITCODE=1
    goto :eof
)
setlocal
rem export PATH="/usr/lib/jvm/java-11-openjdk-amd64/bin:$PATH"
set "PATH=%__JDK11_HOME%\bin;%PATH%"
rem ./project/scripts/sbt "compile ;test"
echo sbt compile and sbt test (Java 11)
if %_DEBUG%==1 echo %_DEBUG_LABEL% "%_SBT_CMD%" "compile ;test"
call "%_SBT_CMD%" ";compile ;test"
if not %ERRORLEVEL%==0 (
    endlocal
    echo %_ERROR_LABEL% Failed to run sbt command ";compile ;test" 1>&2
    set _EXITCODE=1
    goto :eof
)
endlocal
goto :eof

:documentation
rem see shell script project/scripts/genDocs
if %_DEBUG%==1 echo %_DEBUG_LABEL% call %_SCRIPTS_DIR%\genDocs.bat 1>&2
call %_SCRIPTS_DIR%\genDocs.bat
if not %ERRORLEVEL%==0 (
    echo %_ERROR_LABEL% Failed to run genDocs.bat 1>&2
    set _EXITCODE=1
    goto :eof
)
goto :eof

:archives
if %_DEBUG%==1 echo %_DEBUG_LABEL% call "%_SBT_CMD%" dist-bootstrapped/packArchive 1>&2
call "%_SBT_CMD%" dist-bootstrapped/packArchive
rem output directory for gz/zip archives
set __TARGET_DIR=%_ROOT_DIR%\dist-bootstrapped\target
if not exist "%__TARGET_DIR%\" (
    echo %_ERROR_LABEL% Directory target not found 1>&2
    set _EXITCODE=1
    goto :eof
)
if %_DEBUG%==1 (
    echo.
    echo Output directory: %__TARGET_DIR%\
    dir /b /a-d "%__TARGET_DIR%"
)
goto :eof

rem output parameter: _DURATION
:duration
set __START=%~1
set __END=%~2

for /f "delims=" %%i in ('powershell -c "$interval = New-TimeSpan -Start '%__START%' -End '%__END%'; Write-Host $interval"') do set _DURATION=%%i
goto :eof

rem ##########################################################################
rem ## Cleanups

:end
if %_TIMER%==1 (
    for /f "delims=" %%i in ('powershell -c "(Get-Date)"') do set __TIMER_END=%%i
    call :duration "%_TIMER_START%" "!__TIMER_END!"
    echo Total elasped time: !_DURATION!
)
if %_DEBUG%==1 echo %_DEBUG_LABEL% _EXITCODE=%_EXITCODE% 1>&2
exit /b %_EXITCODE%
endlocal
