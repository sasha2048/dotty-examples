# <span id="top">Scala 3 examples</span> <span style="size:30%;"><a href="../README.md">⬆</a></span>

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;min-width:120px;">
    <a href="https://dotty.epfl.ch/" rel="external"><img style="border:0;width:120px;" src="../docs/dotty.png" alt="Dotty logo" /></a>
  </td>
  <td style="border:0;padding:0;vertical-align:text-top;">
    Directory <strong><code>examples\</code></strong> contains <a href="https://dotty.epfl.ch/" rel="external">Scala 3</a> code examples coming from various websites - mostly from the <a href="https://dotty.epfl.ch/" rel="external">Dotty project</a>.
  </td>
  </tr>
</table>

Let's choose example [**`enum-Planet`**](enum-Planet) to demonstrate the usage of the build tools we do support:

<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/cd">cd</a></b>
W:\examples\enum-Planet
</pre>

Build tools rely on one or more configuration files to achieve their tasks. In our case we created the following configuration files for [**`enum-Planet`**](enum-Planet):

| Build tool                    | Configuration file(s)                    | Parent file(s)                               | Comment(s) |
|-------------------------------|------------------------------------------|----------------------------------------------|---------|
| [**`ant.bat`**][apache_ant_cli]   | [**`build.xml`**](enum-Planet/build.xml) | [**`build.xml`**](./build.xml), [**`ivy.xml`**](ivy.xml) |  |
| [**`bazel.exe`**][bazel_cli]      | [**`BUILD`**](enum-Planet/BUILD), **`WORKSPACE`** | n.a.                                |  |
| [**`build.bat`**](enum-Planet/build.bat) | [**`build.properties`**](enum-Planet/project/build.properties) | [**`cpath.bat`**](./cpath.bat) <sup>(*)</sup>              |  |
| [**`build.sh`**](enum-Planet/build.sh) | [**`build.properties`**](enum-Planet/project/build.properties) |                   | [Cygwin], [MSYS2], etc. |
| [**`gradle.exe`**][gradle_cli]    | [**`build.gradle`**](enum-Planet/build.gradle) | [**`common.gradle`**](./common.gradle) |  |
| [**`make.exe`**][gmake_cli]       | [**`Makefile`**](enum-Planet/Makefile)   | [**`Makefile.inc`**](./Makefile.inc)         |  |
| [**`mill.bat`**][mill_cli]        | [**`build.sc`**](enum-Planet/build.sc)   | [**`common.sc`**](./common.sc)               |  |
| [**`mvn.cmd`**][apache_maven_cli] | [**`pom.xml`**](enum-Planet/pom.xml)     | [**`pom.xml`**](./pom.xml)                   |  |
| [**`sbt.bat`**][sbt_cli]          | [**`build.sbt`**](enum-Planet/build.sbt) | n.a.                                         |  |
<div style="margin:-4px 50% 0 0;font-size:80%;"><b><sup>(*)</sup></b> This utility batch file manages <a href="https://maven.apache.org/" rel="external">Maven</a> dependencies and returns the associated Java class path (as environment variable).<br/>&nbsp;</div>

## <span id="ant">Ant build tool</span>

The configuration file [**`enum-Planet\build.xml`**](enum-Planet/build.xml) depends on the parent file [**`examples\build.xml`**](build.xml) which provides the macro definition **`dotc`** to compile the [Scala] source files.

> **:mag_right:** Command [**`ant`**][apache_ant_cli] (["Another Neat Tool"][apache_ant_faq]) is a Java-based build tool maintained by the [Apache Software Foundation][apache_history] (tool created in 2000). It works with XML-based configuration files.

Execution of [**`Planet.scala`**](enum-Planet/src/main/scala/Planet.scala) produces the following output ([Ivy][apache_ant_ivy] support is enabled by default):

<pre style="font-size:80%;">
<b>&gt; <a href="https://ant.apache.org/manual/running.html">ant</a> clean run</b>
Buildfile: W:\examples\enum-Planet\build.xml

<span style="font-weight:bold;color:#9966ff;">clean:</span>
   [delete] Deleting directory W:\examples\enum-Planet\target

<span style="font-weight:bold;color:#9966ff;">init.local:</span>

<span style="font-weight:bold;color:#9966ff;">init.ivy:</span>
[ivy:resolve] :: Apache Ivy 2.5.0 - 20191020104435 :: https://ant.apache.org/ivy/ ::
[ivy:resolve] :: loading settings :: url = jar:file:/C:/opt/apache-ant-1.10.9/lib/ivy-2.5.0.jar!/org/apache/ivy/core/settings/ivysettings.xml

<span style="font-weight:bold;color:#9966ff;">init:</span>

<span style="font-weight:bold;color:#9966ff;">compile:</span>
    [mkdir] Created dir: W:\examples\enum-Planet\target\classes
   [scalac] Compiling 1 source file to W:\examples\enum-Planet/target/classes

<span style="font-weight:bold;color:#9966ff;">run:</span>
     [java] Your weight on MERCURY (0) is 0.37775761520093526
     [java] Your weight on VENUS (1) is 0.9049990998410455
     [java] Your weight on EARTH (2) is 0.9999999999999999
     [java] Your weight on MARS (3) is 0.37873718403712886
     [java] Your weight on JUPITER (4) is 2.5305575254957406
     [java] Your weight on SATURN (5) is 1.0660155388115666
     [java] Your weight on URANUS (6) is 0.9051271993894251
     [java] Your weight on NEPTUNE (7) is 1.1383280724696578

BUILD SUCCESSFUL
Total time: 19 seconds
</pre>

> **&#9755;** **Apache Ivy**<br/>
> We observe from task **`init.ivy`** that the [Apache Ivy][apache_ant_ivy] library has been added to the [Ant](https://ant.apache.org/) installation directory. In our case we installed [version 2.5.0][apache_ant_ivy_relnotes] of the [Apache Ivy][apache_ant_ivy] library.
> <pre style="font-size:80%;">
> <b>&gt; <a href="https://curl.haxx.se/docs/manpage.html">curl</a> -sL -o c:\Temp\apache-ivy-2.5.0.zip https://www-eu.apache.org/dist//ant/ivy/2.5.0/apache-ivy-2.5.0-bin.zip</b>
> <b>&gt; <a href="https://linux.die.net/man/1/unzip">unzip</a> c:\temp\apache-ivy-2.5.0.zip -d c:\opt</b>
> <b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/copy">copy</a> c:\opt\apache-ivy-2.5.0\ivy-2.5.0.jar c:\opt\apache-ant-1.10.9\lib</b>
> <b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/dir">dir</a> c:\opt\apache-ant-1.10.9\lib | findstr ivy</b>
> 20.10.2019  09:44         1 402 646 ivy-2.5.0.jar
> </pre>

We can set property **`-Duse.local=true`** to use [Dotty] local installation (*reminder*: in our case environment variable **`DOTTY_HOME`** is set by command **`setenv`**):

<pre style="font-size:80%;">
<b>&gt; <a href="https://ant.apache.org/manual/running.html">ant</a> -Duse.local=true clean run</b>
Buildfile: W:\examples\enum-Planet\build.xml

<span style="font-weight:bold;color:#9966ff;">clean:</span>
   [delete] Deleting directory W:\examples\enum-Planet\target

<span style="font-weight:bold;color:#9966ff;">init.local:</span>
     [echo] SCALA3_HOME=C:\opt\scala-3.0.0-RC1

<span style="font-weight:bold;color:#9966ff;">init.ivy:</span>

<span style="font-weight:bold;color:#9966ff;">init:</span>

<span style="font-weight:bold;color:#9966ff;">compile:</span>
    [mkdir] Created dir: W:\examples\enum-Planet\target\classes
    [scalac] Compiling 1 source file to W:\examples\enum-Planet/target/classes

<span style="font-weight:bold;color:#9966ff;">run:</span>
     [java] Your weight on MERCURY (0) is 0.37775761520093526
     [java] Your weight on VENUS (1) is 0.9049990998410455
     [java] Your weight on EARTH (2) is 0.9999999999999999
     [java] Your weight on MARS (3) is 0.37873718403712886
     [java] Your weight on JUPITER (4) is 2.5305575254957406
     [java] Your weight on SATURN (5) is 1.0660155388115666
     [java] Your weight on URANUS (6) is 0.9051271993894251
     [java] Your weight on NEPTUNE (7) is 1.1383280724696578

BUILD SUCCESSFUL
Total time: 14 seconds
</pre>


## <span id="build">`build.bat` command</span>

Command [**`build.bat`**](enum-Planet/build.bat) is our basic build tool featuring subcommands **`clean`**, **`compile`**, **`decompile`**, **`doc`**, **`help`**, **`lint`**, **`run`** and **`test`**; the batch file consists of ~700 lines of batch/[Powershell ][microsoft_powershell] code <sup id="anchor_01">[[1]](#footnote_01)</sup>.

Command [**`build clean run`**](enum-Planet/build.bat) produces the following output:

<pre style="font-size:80%;">
<b>&gt; <a href="enum-Planet/build.bat">build</a> clean run</b>
Your weight on MERCURY (0) is 0.37775761520093526
Your weight on VENUS (1) is 0.9049990998410455
Your weight on EARTH (2) is 0.9999999999999999
Your weight on MARS (3) is 0.37873718403712886
Your weight on JUPITER (4) is 2.5305575254957406
Your weight on SATURN (5) is 1.0660155388115666
Your weight on URANUS (6) is 0.9051271993894251
Your weight on NEPTUNE (7) is 1.1383280724696578
</pre>

> **:mag_right:** Compilation of the Java/Scala source files is performed only if needed during the build process:
>
> <pre style="font-size:80%;">
> <b>&gt; <a href="enum-Planet/build.bat">build</a> clean</b>
> &nbsp;
> <b>&gt; build compile</b>
> &nbsp;
> <b>&gt; build compile</b>
> No compilation needed ("src\main\scala\*.scala")</pre>

Command [**`build -verbose clean run`**](enum-Planet/build.bat) also displays progress messages:

<pre style="font-size:80%;">
<b>&gt; <a href="enum-Planet/build.bat">build</a> -verbose clean compile run</b>
Delete directory target
Compile 1 Scala sources to directory "target\classes"
Execute Scala main class Planet
Your weight on MERCURY (0) is 0.37775761520093526
Your weight on VENUS (1) is 0.9049990998410455
Your weight on EARTH (2) is 0.9999999999999999
Your weight on MARS (3) is 0.37873718403712886
Your weight on JUPITER (4) is 2.5305575254957406
Your weight on SATURN (5) is 1.0660155388115666
Your weight on URANUS (6) is 0.9051271993894251
Your weight on NEPTUNE (7) is 1.1383280724696578
</pre>

Command [**`build -debug clean compile run`**](enum-Planet/build.bat) also displays internal steps of the build process:

<pre style="font-size:80%;">
<b/>&gt; <a href="enum-Planet/build.bat">build</a> -debug clean compile run</b>
[build] Options    : _EXPLAIN=0 _PRINT=0 _SCALA_VERSION=3 _TASTY=0 _TIMER=0 _VERBOSE=0
[build] Subcommands: _CLEAN=1 _COMPILE=1 _DECOMPILE=0 _DOC=0 _LINT=0 _RUN=1 _TEST=0
[build] Variables  : JAVA_HOME="C:\opt\jdk-11.0.10+9"
[build] Variables  : SCALA3_HOME="C:\opt\scala-3.0.0-RC1"
[build] Variables  : _MAIN_CLASS=Planet _MAINe_ARGS=1
[build] del /s /q W:\dotty\examples\enum-Planet\target\classes\*.class W:\dotty\examples\enum-Planet\target\classes\*.hasTasty W:\dotty\examples\enum-Planet\target\classes\.latest-build
[build] 20180322224754 W:\dotty\examples\enum-Planet\src\main\scala\Planet.scala
[build] 00000000000000 W:\dotty\examples\enum-Planet\target\classes\.latest-build
[build] scalac "@W:\examples\enum-Planet\target\scalac_opts.txt" "@W:\examples\enum-Planet\target\scalac_sources.txt"
[build] scala -classpath [...];W:\dotty\examples\enum-Planet\target\classes Planet 1
Your weight on MERCURY is 0.37775761520093526
Your weight on VENUS (1) is 0.9049990998410455
Your weight on EARTH (2) is 0.9999999999999999
Your weight on MARS (3) is 0.37873718403712886
Your weight on JUPITER (4) is 2.5305575254957406
Your weight on SATURN (5) is 1.0660155388115666
Your weight on URANUS (6) is 0.9051271993894251
Your weight on NEPTUNE (7) is 1.1383280724696578
[build] _EXITCODE=0</pre>

> **:mag_right:** The above `enum-Planet` example expects 1 argument at execution time.<br/>
> For simplicity the [**`build`**](enum-Planet/build.bat) command currently relies on the property `main.args` defined in file [**`project\build.properties`**](enum-Planet/project/build.properties) (part of the SBT configuration) to specify program arguments.<br/>
> <pre style="font-size:80%;">
> <b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/type">type</a> <a href="enum-Planet/project/build.properties">project\build.properties</a></b>
> sbt.version=1.4.1
> main.class=Planet
> main.args=1
> </pre>

> **:mag_right:** Output generated with options **`-verbose`** and **`-debug`** are redirected to [stderr][windows_stderr] and can be discarded by adding **`2>NUL`**, e.g.:
> <pre style="font-size:80%;">
> <b>&gt; <a href="enum-Planet/build.bat">build</a> clean run -debug 2>NUL</b>
> Your weight on MERCURY (0) is 0.37775761520093526
> Your weight on SATURN (5) is 1.0660155388115666
> Your weight on VENUS (1) is 0.9049990998410455
> Your weight on URANUS (6) is 0.9051271993894251
> Your weight on EARTH (2) is 0.9999999999999999
> Your weight on NEPTUNE (7) is 1.1383280724696578
> Your weight on MARS (3) is 0.37873718403712886
> Your weight on JUPITER (4) is 2.5305575254957406
> </pre>

Finally, command [**`build -verbose decompile`**](enum-Planet/build.bat) decompiles the generated bytecode with [CFR][cfr_releases]:

<pre style="font-size:80%;">
<b>&gt; <a href="enum-Planet/build.bat">build</a> -verbose decompile</b>
No compilation needed ("src\main\scala\*.scala")
Decompile Java bytecode to directory "target\cfr-sources"
Processing Planet$
Processing Planet
Save decompiled Java source files to "target\cfr-sources_scala3_3.0.0-RC1.java"
&nbsp;
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/dir">dir</a> /b /s target\*.java</b>
W:\examples\enum-Planet\target\cfr-sources_scala3_3.0.0-RC1.java
W:\examples\enum-Planet\target\cfr-sources\Planet$.java
W:\examples\enum-Planet\target\cfr-sources\Planet.java
</pre>

If the two Java source files `src\build\cfr-sources_scala<n>_<version>.txt` (*check file*) and `target\cfr-sources_scala<n>_<version>.txt` (*output file*) are present subcommand **`decompile`** also invokes the [`diff`][man1_diff] command to show differences between the check file and the output file:

<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/dir">dir</a> /b src\build</b>
cfr-sources_scala3_0.24.0-RC1.java
cfr-sources_scala3_0.27.0-RC1.java
cfr-sources_scala3_3.0.0-RC1.java
&nbsp;
<b>&gt; <a href="enum-Planet/build.bat">build</a> -verbose decompile</b>
No compilation needed ("src\main\scala\*.scala")
Decompile Java bytecode to directory "target\cfr-sources"
Save decompiled Java source files to "target\cfr-sources_scala3_0.27.0-RC1.java"
Compare output file with check file "src\build\cfr-sources_scala3_0.27.0-RC1.java"
</pre>


## <span id="build.shell">`build.sh` command</span>

Command [**`build.sh`**](enum-Planet/build.sh) is our basic build tool for Unix environments like [Cygwin], Linux or [MSYS2]; it features subcommands **`clean`**, **`compile`**, **`doc`**, **`help`**, **`lint`** and **`run`**; the Bash script consists of ~530 lines of [Bash] code.

Command [**`build clean run`**](enum-Planet/build.sh) produces the following output:

<pre style="font-size:80%;">
user@host MINGW64 /w/examples/enum-Planet
<b>$ <a href="enum-Planet/build.sh">./build.sh</a> clean run</b>
Mass of earth is 0.1020132025669991
Your weight on MERCURY (0) is 0.37775761520093526
Your weight on VENUS (1) is 0.9049990998410455
Your weight on EARTH (2) is 0.9999999999999999
Your weight on MARS (3) is 0.37873718403712886
Your weight on JUPITER (4) is 2.5305575254957406
Your weight on SATURN (5) is 1.0660155388115666
Your weight on URANUS (6) is 0.9051271993894251
Your weight on NEPTUNE (7) is 1.1383280724696578
</pre>


## <span id="gradle">Gradle build tool</span>

The configuration file [**`enum-Planet\build.gradle`**](enum-Planet/build.gradle) depends on the parent file [**`examples\common.gradle`**](common.gradle) which defines the task **`compileDotty`** and manages the task dependencies.

> **:mag_right:** Command [**`gradle`**][gradle_cli] is the official build tool for Android applications. Created in 2007 it replaces XML-based build scripts with a [Groovy][gradle_groovy]-based DSL.

Command **`gradle -q clean run`** produces the following output ([**`Planet.scala`**](enum-Planet/src/main/scala/Planet.scala)):

<pre style="font-size:80%;">
<b>&gt; <a href="https://docs.gradle.org/current/userguide/command_line_interface.html">gradle</a> -q clean run</b>
Your weight on MERCURY (0) is 0.37775761520093526
Your weight on VENUS (1) is 0.9049990998410455
Your weight on EARTH (2) is 0.9999999999999999
Your weight on MARS (3) is 0.37873718403712886
Your weight on JUPITER (4) is 2.5305575254957406
Your weight on SATURN (5) is 1.0660155388115666
Your weight on URANUS (6) is 0.9051271993894251
Your weight on NEPTUNE (7) is 1.1383280724696578
</pre>

> **&#9755;** ***Gradle Wrappers***<br/>
> We don't rely on them even if using [Gradle Wrapper][gradle_wrapper] is the  recommended way to execute a Gradle build.<br/>
> Simply execute the **`gradle wrapper`** command to generate the wrapper files; you can then run **`gradlew`** instead of [**`gradle`**][gradle_cli].


## <span id="gmake">Make build tool</span>

The configuration file [**`enum-Planet\Makefile`**](enum-Planet/Makefile) depends on the parent file [**`examples\Makefile.inc`**](Makefile.inc) which defines common settings (i.e. tool and library paths).

> **:mag_right:** Command [**`make`**][gmake_cli] is a build tool that automatically builds executable programs and libraries from source code by reading files called Makefiles which specify how to derive the target program. [Make] was originally created by Stuart Feldman in April 1976 at Bell Labs.

Command **`make clean run`** produces the following output ([**`Planet.scala`**](enum-Planet/src/main/scala/Planet.scala)):

<pre style="font-size:80%;">
<b>&gt; <a href="http://www.glue.umd.edu/lsf-docs/man/gmake.html">make</a> clean run</b>
rm -rf "target"
[ -d "target/classes" ] || mkdir -p "target/classes"
scalac.bat "@target/scalac_opts.txt" "@target/scalac_sources.txt"
scala.bat -classpath "target/classes" Planet 1
Your weight on MERCURY (0) is 0.37775761520093526
Your weight on VENUS (1) is 0.9049990998410455
Your weight on EARTH (2) is 0.9999999999999999
Your weight on MARS (3) is 0.37873718403712886
Your weight on JUPITER (4) is 2.5305575254957406
Your weight on SATURN (5) is 1.0660155388115666
Your weight on URANUS (6) is 0.9051271993894251
Your weight on NEPTUNE (7) is 1.1383280724696578
</pre>

Command **`make test`** executes the test suite [**`PlanetTest.scala`**](enum-Planet/src/test/scala/PlanetTest.scala) for program [**`Planet.scala`**](enum-Planet/src/main/scala/Planet.scala).

<pre style="font-size:80%;">
<b>&gt; <a href="http://www.glue.umd.edu/lsf-docs/man/gmake.html">make</a> test</b>
[ -d "target/test-classes" ] || mkdir -p "target/test-classes"
scalac.bat "@target/scalac_test_opts.txt" "@target/scalac_test_sources.txt"
java.exe -classpath "%USERPROFILE%/.m2/repository/org/scala-lang/scala-library/2.13.2/scala-library-2.13.2.jar;%USERPROFILE%/.m2/repository/ch/epfl/lamp/dotty-library_0.27/0.27.0-RC1/dotty-library_0.27-0.27.0-RC1.jar;%USERPROFILE%/.m2/repository/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar;%USERPROFILE%/.m2/repository/junit/junit/4.13/junit-4.13.jar;%USERPROFILE%/.m2/repository/com/novocode/junit-interface/0.11/junit-interface-0.11.jar;target/classes;target/test-classes" org.junit.runner.JUnitCore PlanetTest
JUnit version 4.13
..
Time: 0.239

OK (2 tests)
</pre>

Command **`make doc`** generates the HTML documentation for program [**`enum-Planet.scala`**](enum-Planet./src/main/scala/enum-Planet.scala):

<pre style="font-size:80%;">
<b>&gt; <a href="http://www.glue.umd.edu/lsf-docs/man/gmake.html">make</a> doc</b>
[ -d "target/docs" ] || mkdir -p "target/docs"
dotd.bat "@target/scaladoc_opts.txt" "@target/scaladoc_sources.txt"
Compiling (1/1): Planet.scala
[doc info] Generating doc page for: <empty>
[doc info] Generating doc page for: <empty>.Planet
[doc info] Generating doc page for: <empty>.Planet$
[doc info] Generating doc page for: <empty>.Planet
[doc info] Generating doc page for: <empty>.Planet$
[...]
public members with docstrings:    0
protected members with docstrings: 0
private members with docstrings:   0/3 (0%)
</pre>


## <span id="maven">Maven build tool</span>

The [Maven][apache_maven_about] configuration file [**`enum-Planet\pom.xml`**](enum-Planet/pom.xml) depends on the parent file [**`../pom.xml`**](pom.xml) which defines common properties (eg. **`java.version`**, **`scala.version`**).

> **:mag_right:** Command [**`mvn`**][mvn_cli] is a Java-based build tool maintained by the [Apache Software Foundation][apache_foundation]. Created in 2002 it works with XML-based configuration files and provides a way to share JARs across several projects.

Command **` mvn compile test`** with option **`-debug`** produces additional debug information, including the underlying command lines executed by our [Maven][apache_maven_about] plugin **`scala-maven-plugin`**:

<pre style="font-size:80%;">
<b>&gt; <a href="https://maven.apache.org/ref/3.6.3/maven-embedder/cli.html">mvn</a> -debug compile test | <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/findstr">findstr</a> /b /c:"[DEBUG]\ [execute]" 2>NUL</b>
[DEBUG] [execute] C:\opt\jdk-11.0.10+9\bin\java.exe \
 -Xms64m -Xmx1024m -Dscala.home=C:\opt\scala-3.0.0-RC1 \
 -cp C:\opt\scala-3.0.0-RC1\lib\*.jar -Dscala.usejavacp=true  \
 dotty.tools.dotc.Main \
 -classpath W:\examples\hello-scala\target\classes \
 -d W:\examples\hello-scala\target\classes \
 W:\examples\hello-scala\src\main\scala\hello.scala
[DEBUG] [execute] C:\opt\jdk-11.0.10+9\bin\java.exe \
 -Xms64m -Xmx1024m -Dscala.home=C:\opt\scala-3.0.0-RC1 [...]
[DEBUG] [execute] C:\opt\jdk-11.0.10+9\bin\java.exe \
 -Xms64m -Xmx1024m -cp C:\opt\scala-3.0.0-RC1\lib\*.jar;\
W:\examples\hello-scala\target\classes hello
</pre>

Command [**`mvn --quiet clean test`**](enum-Planet/pom.xml) produces the following output:

<pre style="font-size:80%;">
<b>&gt; <a href="https://maven.apache.org/ref/3.6.3/maven-embedder/cli.html">mvn</a> --quiet clean test</b>
Your weight on MERCURY (0) is 0.37775761520093526
Your weight on VENUS (1) is 0.9049990998410455
Your weight on EARTH (2) is 0.9999999999999999
Your weight on MARS (3) is 0.37873718403712886
Your weight on JUPITER (4) is 2.5305575254957406
Your weight on SATURN (5) is 1.0660155388115666
Your weight on URANUS (6) is 0.9051271993894251
Your weight on NEPTUNE (7) is 1.1383280724696578
</pre>

<pre style="font-size:80%;">
<b>&gt; <a href="https://maven.apache.org/ref/3.6.3/maven-embedder/cli.html">mvn</a> clean compile package</b>
...
[INFO]
[INFO] --- maven-jar-plugin:3.2.0:jar (default-jar) @ enum-Planet ---
[INFO] Building jar: W:\examples\enum-Planet\target\enum-Planet-1.0-SNAPSHOT.jar
[INFO] ------------------------------------------------------------------------
[INFO] BUILD SUCCESS
[INFO] ------------------------------------------------------------------------
[INFO] Total time:  9.468 s
[INFO] Finished at: 2019-07-27T19:53:09+01:00
[INFO] ------------------------------------------------------------------------

<b>&gt; <a href="https://docs.oracle.com/javase/8/docs/technotes/tools/windows/java.html">java</a> -version 2>&1 | findstr version</b>
openjdk version "11.0.10" 2021-01-19

<b>&gt; <a href="https://docs.oracle.com/javase/8/docs/technotes/tools/windows/java.html">java</a> -Xbootclasspath/a:"c:\opt\scala-3.0.0-RC1\lib\dotty-library_3.0.0-RC1-scala-3.0.0-RC1.jar;c:\opt\scala-3.0.0-RC1\lib\scala-library-2.13.4.jar" -jar target\enum-Planet-1.0-SNAPSHOT.jar 1</b>
Your weight on MERCURY (0) is 0.37775761520093526
Your weight on VENUS (1) is 0.9049990998410455
Your weight on EARTH (2) is 0.9999999999999999
Your weight on MARS (3) is 0.37873718403712886
Your weight on JUPITER (4) is 2.5305575254957406
Your weight on SATURN (5) is 1.0660155388115666
Your weight on URANUS (6) is 0.9051271993894251
Your weight on NEPTUNE (7) is 1.1383280724696578
</pre>

> **&#9755;** **Scala Maven Plugin**<br/>
> In the above [Maven][apache_maven_about] configuration file we note the presence of the Maven plugin [**`scala-maven-plugin`**](../bin/scala-maven-plugin-1.0.zip). In fact the parent file [**`examples\pom.xml`**](pom.xml) depends on [**`scala-maven-plugin`**](../bin/scala-maven-plugin-1.0.zip), a Maven plugin we developed specifically for this project:
>
> <pre style="font-size:80%;">
> <b>&gt; <a href="https://docs.microsoft.com/en-us/windows-server/administration/windows-commands/more">more</a> ..\pom.xml</b>
> &lt;?xml version="1.0" encoding="UTF-8"?&gt;
> ...
>     <b>&lt;properties&gt;</b>
>         <b>&lt;project.build.sourceEncoding&gt;</b>UTF-8<b>&lt;/project.build.sourceEncoding&gt;</b>
>         <b>&lt;java.version&gt;</b>1.8<b>&lt;/java.version&gt;</b>
> &nbsp;
>         <i style="color:#66aa66;">&lt;!-- Scala settings --&gt;</i>
>         <b>&lt;scala.version&gt;</b>3.0.0-RC1<b>&lt;/scala.version&gt;</b>
>         <b>&lt;scala.local.install&gt;</b>true<b>&lt;/scala.local.install&gt;</b>
> &nbsp;
>         <i style="color:#66aa66;">&lt;!-- Maven plugins --&gt;</i>
>         <b>&lt;scala.maven.version&gt;</b>1.0-SNAPSHOT<b>&lt;/scala.maven.version&gt;</b>
>         ...
>     <b>&lt;/properties&gt;</b>
>     <b>&lt;dependencies&gt;</b>
>         <b>&lt;dependency&gt;</b>
>             <b>&lt;groupId&gt;</b>ch.epfl.alumni<b>&lt;/groupId&gt;</b>
>             <b>&lt;artifactId&gt;</b>scala-maven-plugin<b>&lt;/artifactId&gt;</b>
>             <b>&lt;version&gt;</b>${scala.maven.version}<b>&lt;/version&gt;</b>
>         <b>&lt;/dependency&gt;</b>
>         ...
>     <b>&lt;/dependencies&gt;</b>
>
> <b>&lt;/project&gt;</b>
> </pre>
> The plugin is available as [Zip archive][zip_archive] and its installation is deliberately very simple:
> <pre style="font-size:80%;">
> <b>&gt; unzip ..\bin\scala-maven-plugin-1.0.zip %USERPROFILE%\.m2\repository\</b>
> <b>&gt; tree /a /f %USERPROFILE%\.m2\repository\ch\epfl\alumni | findstr /v "^[A-Z]"</b>
> |   maven-metadata-local.xml
> |
> \---scala-maven-plugin
>     |   maven-metadata-local.xml
>     |
>     \---1.0-SNAPSHOT
>             maven-metadata-local.xml
>             scala-maven-plugin-1.0-SNAPSHOT.jar
>             scala-maven-plugin-1.0-SNAPSHOT.pom
>             _remote.repositories
> </pre>


## <span id="mill">Mill build tool</span>

The Mill configuration file [**`enum-Planet\build.sc`**](enum-Planet/build.sc) depends on the parent file [**`examples\common.sc`**](common.sc) which defines the common settings.

> **:mag_right:** Command [**`mill`**][mill_cli] is a Scala-based build tool which aims for simplicity to build projects in a fast and predictable manner.

Command [**`mill -i app`**](enum-Planet/build.sc) produces the following output:

<pre style="font-size:80%;">
<b>&gt; <a href="https://www.lihaoyi.com/mill/#command-line-tools">mill</a> -i app.run 1</b>
[38/38] app.run
Your weight on MERCURY (0) is 0.37775761520093526
Your weight on VENUS (1) is 0.9049990998410455
Your weight on EARTH (2) is 0.9999999999999999
Your weight on MARS (3) is 0.37873718403712886
Your weight on JUPITER (4) is 2.5305575254957406
Your weight on SATURN (5) is 1.0660155388115666
Your weight on URANUS (6) is 0.9051271993894251
Your weight on NEPTUNE (7) is 1.1383280724696578
</pre>


## <span id="sbt">SBT build tool</span>

The configuration file [**`build.sbt`**](enum-Planet/build.sbt) is written in [Scala] and obeys the [sbt build definitions][sbt_docs_defs].

> **:mag_right:** [Lightbend] provides commercial support for the [**`sbt`**][sbt_cli] build tool.

Command **`sbt -warn clean "run 1"`** produces the following output:

<pre style="font-size:80%;">
<b>&gt; <a href="https://www.scala-sbt.org/1.x/docs/Command-Line-Reference.html">sbt</a> -warn clean "run 1"</b>
Your weight on MERCURY (0) is 0.37775761520093526
Your weight on VENUS (1) is 0.9049990998410455
Your weight on EARTH (2) is 0.9999999999999999
Your weight on MARS (3) is 0.37873718403712886
Your weight on JUPITER (4) is 2.5305575254957406
Your weight on SATURN (5) is 1.0660155388115666
Your weight on URANUS (6) is 0.9051271993894251
Your weight on NEPTUNE (7) is 1.1383280724696578
</pre>


## <span id="footnotes">Footnotes</span>

<b name="footnote_01">[1]</b> ***Batch files and coding conventions*** [↩](#anchor_01)

<p style="margin:0 0 1em 20px;">
We strive to obey the following coding conventions in our batch files (e.g. <a href="enum-Planet/build.bat"><b><code>enum-Planet\build.bat</code></b></a>) :

- We use at most 80 characters per line. In general we would say that 80 characters fit well with 4:3 screens and 100 characters fit well with 16:9 screens (both [Databricks](https://github.com/databricks/scala-style-guide#line-length) and [Google](https://google.github.io/styleguide/javaguide.html#s4.4-column-limit) use the convention of 100 characters).
- We organize our code in 4 sections: `Environment setup`, `Main`, `Subroutines` and `Cleanups`.
- We write exactly ***one exit instruction*** (label **`end`** in section **`Cleanups`**).
- We adopt the following naming conventions: global variables start with character `_` (shell variables defined in the user environment start with a letter) and local variables (e.g. inside subroutines or  **`if/for`** constructs) start with `__` (two `_` characters).
</p>

<pre style="margin:0 0 1em 20px;font-size:80%;">
<b>@echo off</b>
<b>setlocal enabledelayedexpansion</b>

<i style="color:#66aa66;">@rem ##########################################################################
@rem ## Environment setup</i>

<b>set</b> _EXITCODE=0

<b>call <span style="color:#9966ff;">:env</span></b>
<b>if not</b> <span style="color:#3333ff;">%_EXITCODE%</span>==0 <b>goto <span style="color:#9966ff;">end</span></b>

<b>call <span style="color:#9966ff;">:props</span></b>
<b>if not</b> <span style="color:#3333ff;">%_EXITCODE%</span>==0 <b>goto <span style="color:#9966ff;">end</span></b>

<b>call <span style="color:#9966ff;">:args</span> %*</b>
<b>if not</b> <span style="color:#3333ff;">%_EXITCODE%</span>==0 <b>goto <span style="color:#9966ff;">end</span></b>

<i style="color:#66aa66;">@rem ##########################################################################
@rem ## Main</i>

<b>if</b> <span style="color:#3333ff;">%_CLEAN%</span>==1 (
    <b>call :clean</b>
    <b>if not</b> <span style="color:#3333ff;">!_EXITCODE!</span>==0 <b>goto end</b>
)
<b>if</b> <span style="color:#3333ff;">%_COMPILE%</span>==1 (
    <b>call <span style="color:#9966ff;">:compile</span></b>
    <b>if not</b> <span style="color:#3333ff;">!_EXITCODE!</span>==0 <b>goto end</b>
)
<b>if</b> <span style="color:#3333ff;">%_LINT%</span>==1 (
    <b>call <span style="color:#9966ff;">:lint</span></b>
    <b>if not</b> <span style="color:#3333ff;">!_EXITCODE!</span>==0 <b>goto end</b>
)
<b>if</b> <span style="color:#3333ff;">%_DOC%</span>==1 (
    <b>call <span style="color:#9966ff;">:doc</span></b>
    <b>if not</b> <span style="color:#3333ff;">!_EXITCODE!</span>==0 <b>goto end</b>
)
<b>if</b> <span style="color:#3333ff;">%_RUN%</span>==1 (
    <b>call <span style="color:#9966ff;">:run</span></b>
    <b>if not</b> <span style="color:#3333ff;">!_EXITCODE!</span>==0 <b>goto end</b>
)
<b>goto <span style="color:#9966ff;">end</span></b>

<i style="color:#66aa66;">@rem ##########################################################################
@rem ## Subroutines</i>

<span style="color:#9966ff;">:env</span>
...<i>(variable initialization, eg. directory paths)</i>...
<b>goto :eof</b>
<span style="color:#9966ff;">:props</span>
...<i>(read file build.properties if present)</i>...
<b>goto :eof</b>
<span style="color:#9966ff;">:args</span>
...<i>(command line options/subcommands)</i>...
<b>goto :eof</b>
<span style="color:#9966ff;">:clean</span>
...<i>(delete generated files/directories)</i>...
<b>goto :eof</b>
<span style="color:#9966ff;">:compile</span>
...
<b>goto :eof</b>
<span style="color:#9966ff;">:lint</span>
...
<b>goto :eof</b>
<span style="color:#9966ff;">:doc</span>
...
<b>goto :eof</b>
<span style="color:#9966ff;">:run</span>
...
<b>goto :eof</b>

<i style="color:#66aa66;">@rem ##########################################################################
@rem ## Cleanups</i>

<span style="color:#9966ff;">:end</span>
...
<b>exit</b> /b <span style="color:#3333ff;">%_EXITCODE%</span>
</pre>

***

*[mics](https://lampwww.epfl.ch/~michelou/)/February 2021* [**&#9650;**](#top)
<span id="bottom">&nbsp;</span>

<!-- link refs -->

[apache_ant_cli]: https://ant.apache.org/manual/running.html
[apache_ant_faq]: https://ant.apache.org/faq.html#ant-name
[apache_ant_ivy]: https://ant.apache.org/ivy/
[apache_ant_ivy_relnotes]: https://ant.apache.org/ivy/history/2.5.0/release-notes.html
[apache_foundation]: https://maven.apache.org/docs/history.html
[apache_history]: https://ant.apache.org/faq.html#history
[apache_maven_about]: https://maven.apache.org/what-is-maven.html
[apache_maven_cli]: https://maven.apache.org/ref/3.6.3/maven-embedder/cli.html
[bash]: https://en.wikipedia.org/wiki/Bash_(Unix_shell)
[bazel_cli]: https://docs.bazel.build/versions/master/command-line-reference.html
[cfr_releases]: https://www.benf.org/other/cfr/
[cygwin]: https://cygwin.com/install.html
[dotty]: https://dotty.epfl.ch/
[gmake_cli]: http://www.glue.umd.edu/lsf-docs/man/gmake.html
[gradle_groovy]: https://www.groovy-lang.org/
[gradle_app_plugin]: https://docs.gradle.org/current/userguide/application_plugin.html#header
[gradle_cli]: https://docs.gradle.org/current/userguide/command_line_interface.html
[gradle_java_plugin]: https://docs.gradle.org/current/userguide/java_plugin.html
[gradle_plugins]: https://docs.gradle.org/current/userguide/plugins.html
[gradle_wrapper]: https://docs.gradle.org/current/userguide/gradle_wrapper.html
[lightbend]: https://www.lightbend.com/
[microsoft_powershell]: https://docs.microsoft.com/en-us/powershell/scripting/getting-started/getting-started-with-windows-powershell?view=powershell-6
[make]: https://en.wikipedia.org/wiki/Make_(software)
[man1_diff]: https://www.linux.org/docs/man1/diff.html
[mill_cli]: https://www.lihaoyi.com/mill/#command-line-tools
[mvn_cli]: https://maven.apache.org/ref/3.6.3/maven-embedder/cli.html
[msys2]: https://www.msys2.org/
[sbt_cli]: https://www.scala-sbt.org/1.x/docs/Command-Line-Reference.html
[sbt_docs_defs]: https://www.scala-sbt.org/1.0/docs/Basic-Def.html
[scala]: https://www.scala-lang.org/
[windows_stderr]: https://support.microsoft.com/en-us/help/110930/redirecting-error-messages-from-command-prompt-stderr-stdout
[zip_archive]: https://www.howtogeek.com/178146/
