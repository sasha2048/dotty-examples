@echo off
setlocal enabledelayedexpansion

@rem output parameter: _CPATH

if not defined _DEBUG set _DEBUG=%~1
if not defined _MVN_CMD set _MVN_CMD=mvn.cmd

if %_DEBUG%==1 ( set _MVN_OPTS=
) else ( set _MVN_OPTS=--quiet
)
set __CENTRAL_REPO=https://repo1.maven.org/maven2
set __LOCAL_REPO=%USERPROFILE%\.m2\repository

set __TEMP_DIR=%TEMP%\lib
if not exist "%__TEMP_DIR%" mkdir "%__TEMP_DIR%"

set _LIBS_CPATH=

rem https://mvnrepository.com/artifact/org.portable-scala
call :add_jar "1.0.0" "portable-scala-reflect_2.13" "org/portable-scala"

rem https://mvnrepository.com/artifact/org.scala-lang.modules/scala-xml
call :add_jar "1.2.0" "scala-xml_2.13" "org/scala-lang/modules"

rem https://mvnrepository.com/artifact/junit/junit
call :add_jar "4.13" "junit" "junit"

rem https://mvnrepository.com/artifact/com.novocode/junit-interface
call :add_jar "0.11" "junit-interface" "com/novocode"

rem https://mvnrepository.com/artifact/org.hamcrest/hamcrest
call :add_jar "2.2" "hamcrest" "org/hamcrest"

set __SCALATEST_VERSION=3.1.1

rem https://mvnrepository.com/artifact/org.scalatest/scalatest
call :add_jar "%__SCALATEST_VERSION%" "scalatest_2.13" "org/scalatest"

rem https://mvnrepository.com/artifact/org.scalactic
call :add_jar "%__SCALATEST_VERSION%" "scalactic_2.13" "org/scalactic"

set __SPECS2_CORE_VERSION=4.9.2

rem https://mvnrepository.com/artifact/org.specs2/specs2-core
call :add_jar "%__SPECS2_CORE_VERSION%" "specs2-core_2.13" "org/specs2"

rem https://mvnrepository.com/artifact/org.specs2/specs2-common
call :add_jar "%__SPECS2_CORE_VERSION%" "specs2-common_2.13" "org/specs2"

rem https://mvnrepository.com/artifact/org.specs2/specs2-junit
call :add_jar "%__SPECS2_CORE_VERSION%" "specs2-junit_2.13" "org/specs2"

rem https://mvnrepository.com/artifact/org.specs2/specs2-junit
call :add_jar "%__SPECS2_CORE_VERSION%" "specs2-matcher_2.13" "org/specs2"

rem https://mvnrepository.com/artifact/org.specs2/specs2-fp
call :add_jar "%__SPECS2_CORE_VERSION%" "specs2-fp_2.13" "org/specs2"

goto end

@rem #########################################################################
@rem ## Subroutines

@rem input parameters: %1=version, %2=artifact ID, %3=group ID
@rem global variable: _LIBS_CPATH
:add_jar
@rem https://mvnrepository.com/artifact/org.portable-scala
set __VERSION=%~1
set __ARTIFACT_ID=%~2
set __GROUP_ID=%~3

set __JAR_NAME=%__ARTIFACT_ID%-%__VERSION%.jar
set __JAR_PATH=%__GROUP_ID:/=\%\%__ARTIFACT_ID:/=\%
set __JAR_FILE=
for /f %%f in ('where /r "%__LOCAL_REPO%\%__JAR_PATH%" %__JAR_NAME% 2^>NUL') do (
    set __JAR_FILE=%%f
)
if not exist "%__JAR_FILE%" (
    set __JAR_URL=%__CENTRAL_REPO%/%__GROUP_ID%/%__ARTIFACT_ID%/%__VERSION%/%__JAR_NAME%
    set __JAR_FILE=%__TEMP_DIR%\%__JAR_NAME%
    if not exist "!__JAR_FILE!" (
        if %_DEBUG%==1 ( echo %_DEBUG_LABEL% powershell -c "Invoke-WebRequest -Uri !__JAR_URL! -Outfile !__JAR_FILE!" 1>&2
        ) else if %_VERBOSE%==1 ( echo Download file %__JAR_NAME% to directory "%%USERPROFILE%%!__TEMP_DIR:%USERPROFILE%=!" 1>&2
        )
        powershell -c "$progressPreference='silentlyContinue';Invoke-WebRequest -Uri !__JAR_URL! -Outfile !__JAR_FILE!"
        if not !ERRORLEVEL!==0 (
            echo %_ERROR_LABEL% Failed to download file %__JAR_NAME% 1>&2
            set _EXITCODE=1
            goto :eof
        )
    )
    if %_DEBUG%==1 ( echo %_DEBUG_LABEL% %_MVN_CMD% install:install-file -Dfile="!__JAR_FILE!" -DgroupId="%__GROUP_ID:/=.%" -DartifactId=%__ARTIFACT_ID% -Dversion=%__VERSION% 1>&2
    ) else if %_VERBOSE%==1 ( echo Install Maven archive into directory "%%USERPROFILE%%!__LOCAL_REPO:%USERPROFILE%=!\%__SCALA_XML_PATH%" 1>&2
    )
    call %_MVN_CMD% %_MVN_OPTS% install:install-file -Dfile="!__JAR_FILE!" -DgroupId="%__GROUP_ID:/=.%" -DartifactId=%__ARTIFACT_ID% -Dversion=%__VERSION% -Dpackaging=jar
)
set "_LIBS_CPATH=%_LIBS_CPATH%%__JAR_FILE%;"
goto :eof

@rem #########################################################################
@rem ## Cleanups

:end
endlocal & (
    set _CPATH=%_LIBS_CPATH%
)