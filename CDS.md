# <span id="top">Data Sharing and Dotty on Windows</span> (*work-in-progress*)

<table style="font-family:Helvetica,Arial;font-size:14px;line-height:1.6;">
  <tr>
  <td style="border:0;padding:0 10px 0 0;max-width:120px;">
    <a href="http://dotty.epfl.ch/"><img src="https://www.cakesolutions.net/hubfs/dotty.png" width="120"/></a>
  </td>
  <td style="border:0;padding:0;vertical-align:text-top;">
    This page presents findings from my experiments with <a href="https://docs.oracle.com/javase/8/docs/technotes/guides/vm/class-data-sharing.html">Java class data sharing</a> (CDS) and <a href="http://dotty.epfl.ch/">Dotty</a> on the Windows platform. Introduced in <a href="https://openjdk.java.net/groups/hotspot/docs/RuntimeOverview.html#Class%20Data%20Sharing|outline">J2SE 5.0</a>, CDS helps reduce the startup time for Java applications as well as reduce their memory footprint.
  </td>
  </tr>
</table>

This page is part of a series of topics related to [Dotty](http://dotty.epfl.ch/) on Windows:

- [Running Dotty on Windows](README.md)
- [Building Dotty on Windows](DRONE.md)
- Data Sharing and Dotty on Windows


## Project dependencies

This project depends on two external software for the **Microsoft Windows** platform:

- [Oracle Java 11 SDK](https://docs.oracle.com/en/java/javase/11/) ([*release notes*](https://www.oracle.com/technetwork/java/javase/11-0-1-relnotes-5032023.html))
- [Dotty 0.11](https://github.com/lampepfl/dotty/releases) (Java 9+ supported since 0.10)
- [Git 2.20](https://git-scm.com/download/win) ([*release notes*](https://raw.githubusercontent.com/git/git/master/Documentation/RelNotes/2.20.1.txt))

> **:mag_right:** [Scala 2.12](https://www.scala-lang.org/download/) is a software product announced to require Java 8; in contrast [Dotty](http://dotty.epfl.ch/) (aka [Scala 3](https://www.scala-lang.org/blog/2018/04/19/scala-3.html)) is still in development and also supports Java 9+. In the following we choose to work with [Java 11](https://www.oracle.com/technetwork/java/javase/downloads/jdk11-downloads-5066655.html), the 2<sup>nd</sup> [LTS](https://www.oracle.com/technetwork/java/java-se-support-roadmap.html) version after Java 8.

For instance our development environment looks as follows (*December 2018*):

<pre style="font-size:80%;">
C:\opt\jdk-11.0.1\
C:\opt\dotty-0-11.0-RC1\
C:\opt\Git-2.20.1\
</pre>

> **:mag_right:** Git for Windows provides a BASH emulation used to run [**`git`**](https://git-scm.com/docs/git) from the command line (as well as over 250 Unix commands like [**`awk`**](https://www.linux.org/docs/man1/awk.html), [**`diff`**](https://www.linux.org/docs/man1/diff.html), [**`file`**](https://www.linux.org/docs/man1/file.html), [**`grep`**](https://www.linux.org/docs/man1/grep.html), [**`more`**](https://www.linux.org/docs/man1/more.html), [**`mv`**](https://www.linux.org/docs/man1/mv.html), [**`rmdir`**](https://www.linux.org/docs/man1/rmdir.html), [**`sed`**](https://www.linux.org/docs/man1/sed.html) and [**`wc`**](https://www.linux.org/docs/man1/wc.html)).


## Overview

- Section **Java Example** presents a Java code example using data sharing.
- In section **Dotty Example** we move to [Dotty](http://dotty.epfl.ch/) with the same example written in [Dotty](http://dotty.epfl.ch/).
- Finally we describe the batch command **`sharedata.bat`**.

> **:warning:** We have submitted a bug report related to the usage of option **`-Xlog`** on Windows (see [JDK-8215398](https://bugs.java.com/bugdatabase/view_bug.do?bug_id=JDK-8215398)): 

## Java Example

Source file [**`src\main\java\Main.java`**](cdsexamples/JavaExample/src/main/java/Main.java) is the main program of our Java code example:

<pre style="font-size:80%;">
<b>package</b> cdsexamples;
<b>public class</b> Main {
    <b>public static void</b> main(String[] args) {
        System.out.println("Hello from Java !");
        <b>if</b> (args.length > 0) {
            System.out.println(VMOptions.asString());
            <i>//ScriptEngineTest.run();  // .jsa file size: 9 Mb -> 24 Mb !</i>
        }
    }
}</pre>

Batch command  [**`build`**](cdsexamples/JavaExample/build.bat) has two new options working with the **`run`** subcommand:

- Option **`-iter:<n>`** specifies the number of run iterations (for calculating meaningful average load times).
- Option **`-share`** enables/disables data sharing.

<pre style="font-size:80%;">
&gt; build help
Usage: build { options | subcommands }
  Options:
    -iter:1..99        set number of run iterations
    -share[:(on|off)]  enable/disable data sharing (default:off)
    -verbose           display progress messages
  Subcommands:
    clean              delete generated files
    compile            compile Java source files
    help               display this help message
    run[:arg]          execute main class with 1 optional argument
</pre>

> **:mag_right:** Internally the **`compile`** subcommand generates a Java archive and a Java shared archive as a last step of the compilation phase.

We first execute command **`build clean compile`**; the same command with option **`-verbose`** prints out the progress messages:

<pre style="font-size:80%;">
&gt; build clean compile
&nbsp;
&gt; build -verbose clean compile
Create Java archive target\JavaExample.jar
Create class list file target\JavaExample.classlist
Create Java shared archive target\JavaExample.jsa
</pre>

We can now execute our Java example ***without data sharing***; the same command with option **`-verbose`** prints out the CDS status:

<pre style="font-size:80%;">
&gt; build run
Hello from Java !
&nbsp;
&gt; build run -verbose
Hello from Java !
Statistics (see details in target\logs\log_share_off.log):
   Share flag       : off
   Shared classes   : 0
   File classes     : 1
   jrt images       : 595
   Load time        : 0.109
   #iteration(s)    : 1
Classes per package (596):
   java.io.* (38), java.lang.* (168), java.math.* (0), java.net.* (9)
   java.nio.* (38), java.security.* (24), java.util.* (137)
   jdk.* (107), scala.* (0), sun.* (74)
   [APP] cdsexamples.* (1)
</pre>

> **:mag_right:** Subcommand **`run`** accepts 1 optional argument for testing purposes; for instance **`build run:1`** produces the following output (see [**`src\main\java\VMOptions.java`**](cdsexamples/JavaExample/src/main/java/VMOptions.java)):
> <pre style="font-size:80%;">
> &gt; build run:1
> Hello from Java !
> VM Options:
>    -Xshare:off
>    -XX:SharedArchiveFile=C:\&lt;project_path&gt;\target\JavaExample.jsa
>    -Xlog:disable
> </pre>
> Value for **`-Xlog`** is different with **`build run:1 -verbose`**:<br/>
> <pre style="font-size:80%;">
>    -Xlog:class+load:file=&lt;project_path&gt;\target\logs\log_share_on.log
> </pre>


For comparison here is the console output ***with data sharing***; option **`-verbose`** prints out the CDS status:

<pre style="font-size:80%;">
&gt; build run -share
Hello from Java !
&nbsp;
&gt; build run -verbose -share
Hello from Java !
Statistics (see details in target\logs\log_share_on.log):
   Share flag       : on
   Shared classes   : 585
   File classes     : 0
   jrt images       : 1 (sun.nio.fs.WindowsLinkSupport source: jrt:/java.base)
   Load time        : 0.082
   #iteration(s)    : 1
Classes per package (586):
   java.io.* (38), java.lang.* (168), java.math.* (0), java.net.* (9)
   java.nio.* (38), java.security.* (23), java.util.* (137)
   jdk.* (99), scala.* (0), sun.* (73)
   [APP] cdsexamples.* (1)
</pre>

Subcommand **`run`** with option **`-iter:<n>`** (where **`n=1..99`**) executes the Java program **`n`** times:

<pre style="font-size:80%;">
&gt; build run -verbose -share -iter:4
Hello from Java !
Hello from Java !
Hello from Java !
Hello from Java !
Statistics (see details in target\logs\log_share_on.log):
   Share flag       : on
   Shared classes   : 585
   File classes     : 0
   jrt images       : 1 (sun.nio.fs.WindowsLinkSupport source: jrt:/java.base)
   Average load time: 0.084s
   #iteration(s)    : 4
Classes per package (586):
   java.io.* (38), java.lang.* (168), java.math.* (0), java.net.* (9)
   java.nio.* (38), java.security.* (23), java.util.* (137)
   jdk.* (99), scala.* (0), sun.* (73)
   [APP] cdsexamples.* (1)
</pre>

Let's check the contents of the output directory **`target\`**:

<pre style="font-size:80%;">
&gt; tree /a /f target | findstr /v "^[A-Z]"
|   JavaExample.classlist
|   JavaExample.jar
|   JavaExample.jsa
|   MANIFEST.MF
|
+---classes
|   |   .latest-build
|   |
|   \---cdsexamples
|           JavaExample.classs
|           ScriptEngineTest.class
|           VMOptions.class
|
\---logs
        log_classlist.log
        log_dump.log
        log_share_off.log
        log_share_on.log
</pre>

Note the following about the generated files:

- File **`MANIFEST.MF`** is added to **`JavaExample.jar`** as usual. 
- Files **`logs\log_classlist.log`** and **`logs\log_dump.log`** are generated when option **`-verbose`** is passed to the **`compile`** subcommand; they contain the execution logs for the generation of **`JavaExample.classlist`** resp. **`JavaExample.jsa`**.
- File **`logs\log_share_off.log`** is generated when option **`-share:on`** is passed to the **`run`** subcommand.
- File **`logs\log_share_on.log`** is generated when option **`-share:off`** is passed to the **`run`** subcommand.

For instance we can read from file **`logs\log_share_off.log`** that  source of **`cdsexamples.Main`** is **`file:/`** and that the total load time on the last line is **`0.124s`**:

<pre style="font-size:80%;">
[0.008s][info][class,load] opened: c:\opt\jdk-11.0.1\lib\modules
[0.018s][info][class,load] java.lang.Object source: jrt:/java.base
[...]
[0.121s][info][class,load] cdsexamples.Main source: file:/&lt;project_path&gt;/target/JavaExample.jar
[...]
[0.124s][info][class,load] java.lang.Shutdown$Lock source: jrt:/java.base
</pre>

We can also execute the [**`java`**](https://docs.oracle.com/en/java/javase/11/tools/java.html) command (*from Java 9+*) directly to check if data sharing is effectively used:

<pre style="font-size:80%;">
&gt; java -verbose:class -Xshare:on -XX:SharedArchiveFile=target\JavaExample.jsa ^
 -jar W:\DOTTY-~1\CDSEXA~1\JAVAEX~1\target\JavaExample.jar | findstr cdsexamples
[0.089s][info][class,load] cdsexamples.Main source: shared objects file

&gt; java -verbose:class -Xshare:off -XX:SharedArchiveFile=target\JavaExample.jsa ^
 -jar W:\DOTTY-~1\CDSEXA~1\JAVAEX~1\target\JavaExample.jar | findstr cdsexamples
[0.112s][info][class,load] cdsexamples.Main source: file:/W:/dotty-examples/cdsexamples/JavaExample/target/Main.jar
</pre>

> **:warning:** The ***crucial point*** here is to use the correct path of **`JavaExample.jar`** together with the specified Java shared archive. Command [**`grep -a`**](https://www.linux.org/docs/man1/grep.html) (**`-a`** means "*Process a binary file as if it were text*") helps us to extract that path from **`JavaExample.jsa`**.<br/>
> <pre style="font-size:80%;">
> &gt; grep -aPo '.{0,40}JavaExample.jar{0,40}' target\JavaExample.jsa
>   W:\DOTTY-~1\CDSEXA~1\JAVAEX~1\target\JavaExample.jar
>   W:\DOTTY-~1\CDSEXA~1\JAVAEX~1\target\JavaExample.jar
> </pre>

## Dotty Example

Source file [**`src\main\scala\Main.scala`**](cdsexamples/DottyExample/src/main/scala/Main.scala) is the main program of our [Dotty](http://dotty.epfl.ch/) code example:

<pre style="font-size:80%;">
<b>package</b> cdsexamples
<b>object</b> Main {
  <b>def</b> main(args: Array[String]): Unit = {
    println("Hello from Dotty !")
    <b>if</b> (args.length > 0) {
      println(VMOptions.asString)
      <i>//TastyTest.run()</i>
    }
  }
}</pre>

Batch command [**`build`**](cdsexamples/DottyExample/build.bat) has two new options working with the **`run`** subcommand:

- Option **`-iter:<n>`** specifies the number of run iterations (for calculating meaningful average load times).
- Option **`-share`** enables/disables data sharing.

<pre style="font-size:80%;">
&gt; build help
Usage: build { options | subcommands }
  Options:
    -iter:1..99        set number of run iterations
    -share[:(on|off)]  enable/disable data sharing (default:off)
    -verbose           display progress messages
  Subcommands:
    clean              delete generated files
    compile            compile Scala source files
    help               display this help message
    run[:arg]          execute main class with 1 optional argument
</pre>

> **:mag_right:** Internally the **`compile`** subcommand generates a Java archive and a Java shared archive as a last step of the compilation phase.

Similarly to the previous section we execute the following command; option **`-verbose`** prints out the progress messages:

<pre style="font-size:80%;">
&gt; build clean compile
&nbsp;
&gt; build -verbose clean compile
Create Java archive target\DottyExample.jar
Create class list file target\DottyExample.classlist
Create Java shared archive target\DottyExample.jsa
</pre>

We can now execute our [Dotty](http://dotty.epfl.ch/) example ***without data sharing*** (default settings: **`-share:off`**); option **`-verbose`** prints out the CDS status:

<pre style="font-size:80%;">
&gt; build run
Hello from Dotty !
&nbsp;
&gt; build run -verbose
Execute Java archive target\DottyExample.jar
Hello from Dotty !
Statistics (see details in target\logs\log_share_off.log):
   Share flag       : off
   Shared classes   : 0
   File classes     : 265
   jrt images       : 671
   Load time        : 0.349
   #iteration(s)    : 1
Classes per package (941):
   java.io.* (39), java.lang.* (216), java.math.* (3), java.net.* (9)
   java.nio.* (38), java.security.* (24), java.util.* (142)
   jdk.* (121), sun.* (80)
   [APP] cdsexamples.* (2)
   scala.* (28), scala.collection.* (161), scala.io.* (1), scala.math.* (19)
   scala.reflect.* (25), scala.runtime.* (5), scala.sys.* (14), scala.util.* (14)
</pre>

For comparison here is the output ***with data sharing***; option **`-verbose`** prints out the CDS status:

<pre style="font-size:80%;">
&gt; build run -share
Hello from Dotty !
&nbsp;
&gt; build run -verbose -share
Execute Java archive target\DottyExample.jar
Hello from Dotty !
Statistics (see details in target\logs\log_share_on.log):
   Share flag       : on
   Shared classes   : 869
   File classes     : 0
   jrt images       : 1 (sun.nio.fs.WindowsLinkSupport source: jrt:/java.base)
   Load time        : 0.125
   #iteration(s)    : 1
Classes per package (875):
   java.io.* (34), java.lang.* (208), java.math.* (3), java.net.* (9)
   java.nio.* (27), java.security.* (23), java.util.* (122)
   jdk.* (106), sun.* (74)
   [APP] cdsexamples.* (2)
   scala.* (28), scala.collection.* (161), scala.io.* (1), scala.math.* (19)
   scala.reflect.* (25), scala.runtime.* (5), scala.sys.* (14), scala.util.* (14)
</pre>

Subcommand **`run`** with option **`-iter:<n>`** (**`n=1..99`**) executes **`n`** times the [Dotty](http://dotty.epfl.ch/) example:

<pre style="font-size:80%;">
&gt; build run -verbose -share -iter:4
Execute Java archive target\DottyExample.jar
Hello from Dotty !
Execute Java archive target\DottyExample.jar
Hello from Dotty !
Execute Java archive target\DottyExample.jar
Hello from Dotty !
Execute Java archive target\DottyExample.jar
Hello from Dotty !
Statistics (see details in target\logs\log_share_on.log):
   Share flag       : on
   Shared classes   : 869
   File classes     : 0
   jrt images       : 1 (sun.nio.fs.WindowsLinkSupport source: jrt:/java.base)
   Average load time: 0.128s
   #iteration(s)    : 4
Classes per package (875):
   java.io.* (34), java.lang.* (208), java.math.* (3), java.net.* (9)
   java.nio.* (27), java.security.* (23), java.util.* (122)
   jdk.* (106), sun.* (74)
   [APP] cdsexamples.* (2)
   scala.* (28), scala.collection.* (161), scala.io.* (1), scala.math.* (19)
   scala.reflect.* (25), scala.runtime.* (5), scala.sys.* (14), scala.util.* (14)
</pre>

Finally we check the contents of the output directory **`target\`**:

<pre style="font-size:80%;">
> tree /a /f target | findstr /v "^[A-Z]"
|   DottyExample.classlist
|   DottyExample.jar
|   DottyExample.jsa
|   MANIFEST.MF
|
+---classes
|   |   .latest-build
|   |
|   \---cdsexamples
|           Main$.class
|           Main.class
|           Main.tasty
|           TastyTest$.class
|           TastyTest.class
|           TastyTest.tasty
|           VMOptions$.class
|           VMOptions.class
|           VMOptions.tasty
|
\---logs
        log_classlist.log
        log_dump.log
        log_share_off.log
        log_share_on.log
</pre>

Note the following about the generated files:

- File **`MANIFEST.MF`** is added to **`DottyExample.jar`** as usual.
- Files **`classes\Main$.class`** and **`classes\Main.tasty`** (typed AST) are specific to the [Dotty](http://dotty.epfl.ch/) compiler.
- Files **`logs\log_classlist.log`** and **`logs\log_dump.log`** are generated when option **`-verbose`** is passed to the **`compile`** subcommand; they contain the execution logs for the generation of **`DottyExample.classlist`** resp. **`DottyExample.jsa`**. 
- File **`logs\log_share_off.log`** is generated when option **`-share:on`** is passed to the **`run`** subcommand.
- File **`logs\log_share_on.log`** is generated when option **`-share:off`** is passed to the **`run`** subcommand.

## Batch command

The [**`sharedata`**](bin/sharedata.bat) batch command:

<pre style="font-size:80%;">
&gt; sharedata help
Usage: sharedata { options | subcommands }
  Options:
    -share[:(on|off)]  set the share flag (default:off)
    -verbose           display generation progress
  Subcommands:
    activate           install the Java shared archive
    dump               create the Java shared archive
    help               display this help message
    reset              uninstall the Java shared archive
    test               execute test application (depends on dump)
</pre>

<pre style="font-size:80%;">
&gt; sharedata activate
Create class list file for Scala compiler
Create Java shared archive for Scala compiler
[...]
Number of classes 3609
[...]
Create class list file for Scala REPL
[...]
Create Java shared archive for Scala REPL
[...]
Number of classes 1586
[...]
Execute test application with Scala REPL WITHOUT Java shared archive
Support files for Java class sharing:
   dotty-cds-compiler.classlist (158 Kb)
   dotty-cds-compiler.jsa (60864 Kb)
   dotty-cds-repl.classlist (70 Kb)
   dotty-cds-repl.jsa (23872 Kb)
   dotty-cds.jar (3 Kb)
   dotty-cds_0.11-0.11.0-RC1.jar (3 Kb)
</pre>

<pre style="font-size:80%;">
&gt; dir /b c:\opt\dotty-0.11.0-RC1\lib\dotty-cds*
dotty-cds-compiler.classlist
dotty-cds-compiler.jsa
dotty-cds-repl.classlist
dotty-cds-repl.jsa
dotty-cds_0.11-0.11.0-RC1.jar
</pre>

<pre style="font-size:80%;">
<b>object</b> Main {
  <b>def</b> main(args: Array[String]): Unit = {
    println("Support files for Java class sharing:")
    <b>val</b> jarUrl = getClass().getProtectionDomain().getCodeSource().getLocation()
    <b>val</b> libDir = java.nio.file.Paths.get(jarUrl.toURI()).getParent().toFile()
    <b>val</b> files = libDir.listFiles.filter(_.getName.startsWith("dotty-cds"))
    files.foreach(f => println("   "+f.getName()+" ("+(f.length()/1024)+" Kb)"))
  }
}
</pre>

Subcommand **`test`** ...tbd...; option **`-verbose`** prints out the CDS status:
<pre style="font-size:80%;">
&gt; sharedata test
Support files for Java class sharing:
   dotty-cds-compiler.classlist (158 Kb)
   dotty-cds-compiler.jsa (60864 Kb)
   dotty-cds-repl.classlist (70 Kb)
   dotty-cds-repl.jsa (23872 Kb)
   dotty-cds_0.11-0.11.0-RC1.jar (3 Kb)
&nbsp;
&gt; sharedata -verbose test
Execute test application with Scala REPL WITHOUT Java shared archive
Support files for Java class sharing:
   dotty-cds-compiler.classlist (119 Kb)
   dotty-cds-compiler.jsa (55488 Kb)
   dotty-cds-repl.classlist (31 Kb)
   dotty-cds-repl.jsa (16640 Kb)
   dotty-cds.jar (3 Kb)
   dotty-cds_0.11-0.11.0-RC1.jar (3 Kb)
Statistics (see data-sharing\logs\dotty-cds-repl-share.log)
   Share flag      : off
   Shared classes  : 0
   File/jrt classes: 951
   Load time       : 0.383s
Classes per package (955):
   java.io.* (39), java.lang.* (222), java.net.* (9), java.nio.* (39)
   java.security.* (24), java.util.* (142), jdk.* (121) sun.* (82)

   scala.* (30), scala.collection.* (166), scala.io.* (1), scala.math.* (19)
   scala.reflect.* (27), scala.runtime.* (6), scala.sys.* (14), scala.util.* (14)
</pre>

<pre style="font-size:80%;">
&gt; sharedata -verbose -share test
Execute test application with Scala REPL WITH Java shared archive
Support files for Java class sharing:
   dotty-cds-compiler.classlist (119 Kb)
   dotty-cds-compiler.jsa (55488 Kb)
   dotty-cds-repl.classlist (31 Kb)
   dotty-cds-repl.jsa (16640 Kb)
   dotty-cds.jar (3 Kb)
   dotty-cds_0.11-0.11.0-RC1.jar (3 Kb)
Statistics (see data-sharing\logs\dotty-cds-repl-share.log)
   Share flag      : on
   Shared classes  : 884
   File/jrt classes: 1
   Load time       : 0.140s
Classes per package (889):
   java.io.* (34), java.lang.* (214), java.net.* (9), java.nio.* (28)
   java.security.* (23), java.util.* (122), jdk.* (106) sun.* (76)

   scala.* (30), scala.collection.* (166), scala.io.* (1), scala.math.* (19)
   scala.reflect.* (27), scala.runtime.* (6), scala.sys.* (14), scala.util.* (14)
</pre>


> **&#9755;** ***Data Sharing and Oracle JDK 11*** <br/>
> The [Oracle JDK 11](https://www.oracle.com/technetwork/java/javase/downloads/jdk11-downloads-5066655.html) installation contains the file **`<install_dir>\lib\classlist`**. Let's check if data sharing is enabled:
> 
> 1. Command **`java.exe -version`** displays the OpenJDK version amongst other information; in particular, last displayed line ends with  **`(build 11.0.1+13, mixed mode, sharing)`** if data sharing is enabled, with **`(build 11.0.1+13, mixed mode)`** otherwise.
> 2. Command **`java.exe -Xshare:dump`** generates the 17.3 Mb Java shared archive **`<install_dir>\bin\server\classes.jsa`** from file **`<install_dir>\lib\classlist`**.
> 3. Repeat command from point 1. 
> 
> <pre style="font-size:80%;">
> &gt; c:\opt\jdk-11.0.1\bin\java -version
> openjdk version "11.0.1" 2018-10-16
> OpenJDK Runtime Environment 18.9 (build 11.0.1+13)
> OpenJDK 64-Bit Server VM 18.9 (build 11.0.1+13, mixed mode)
> &nbsp;
> &gt; java -Xshare:dump
> [...]
> Number of classes 1272
> [...]
> mc  space:      8416 [  0.0% of total] [...]
> rw  space:   4022728 [ 22.2% of total] [...]
> ro  space:   7304712 [ 40.4% of total] [...]
> md  space:      2560 [  0.0% of total] [...]
> od  space:   6534368 [ 36.1% of total] [...]
> total    :  17872784 [100.0% of total] [...]
> &nbsp;
> &gt; dir /b c:\opt\jdk-11.0.1\bin\server
> classes.jsa
> jvm.dll
> &nbsp;
> &gt; c:\opt\jdk-11.0.1\bin\java -version
> openjdk version "11.0.1" 2018-10-16
> OpenJDK Runtime Environment 18.9 (build 11.0.1+13)
> OpenJDK 64-Bit Server VM 18.9 (build 11.0.1+13, mixed mode, sharing)
> </pre>


## Related Reading

#### 2006
<dl>
  <dt><a href="https://www.ibm.com/developerworks/java/library/j-ibmjava4/index.html">IBM Developer</a>:<a name="ref_01">&nbsp;</a>Class sharing</dt>
  <dd><i>by Ben Corrie (2006-05-30)</i><br/>The IBM implementation of the 5.0 JVM allows all system and application classes to be stored in a persistent dynamic class cache in shared memory.</dd>
</dl>

#### 2014
<dl>
<!--
  <dt><a href="https://patents.google.com/patent/US9336018"><b>US9336018</b></a>: <a name="ref_02">&nbsp;</a>Mechanism for class data sharing using extension and application class-loaders (2014-05-02)</dt>
  <dd> </dd>
-->
  <dt><a href="http://openjdk.java.net/jeps/250"><b>JEP 250</b></a>:<a name="ref_03">&nbsp;</a>Store Interned Strings in CDS Archives)</dt>
  <dd><i>by Jiangli Zhou (2014-09-24)</i><br/>Interned strings are now stored in CDS archives.</dd>
</dl>

#### 2017
<dl>
  <dt><a href="https://openjdk.java.net/jeps/310"><b>JEP 310</b></a>:<a name="ref_04">&nbsp;</a>Application Class-Data Sharing</dt>
  <dd><i>by Ioi Lam (2017-08-08)</i></br>To improve startup and footprint, AppCDS extends the existing CDS feature to allow application classes to be placed in the shared archive.</dd>
</dl>

#### 2018
<dl>
  <dt><a href="https://bugs.openjdk.java.net/browse/JDK-8198565"><b>JDK-8198565</b></a>:<a name="ref_05">&nbsp;</a>Extend CDS to Support the Module Path</dt>
  <dd><i>by Calvin Cheung (2018-02-22)</i><br/>In JDK 11, CDS has been improved to support archiving classes from the module path.</dd>

  <dt><a href="https://openjdk.java.net/jeps/341"><b>JEP 341</b></a>:<a name="ref_06">&nbsp;</a>Default CDS Archives</dt>
  <dd><i>by Jiangli Zhou, Calvin Cheung, Ioi Lam (2018-06-01)</i><br/>The JDK build process now generates a CDS archive, using the default class list, on 64-bit platforms.</dd>

  <dt><a href="https://www.youtube.com/watch?v=b8GzWd--RXg"><sub><img src="https://upload.wikimedia.org/wikipedia/commons/0/09/YouTube_full-color_icon_%282017%29.svg" alt="Youtube" width="20px"/></sub> JEEConf 2018</a>:<a name="ref07">&nbsp;</a>Class Data Sharing in the HotSpot VM</dt>
  <dd><i>by <a href="https://jeeconf.com/speaker/volker-simonis-2/">Volker Simonis</a> (2018-06-05)</i><br/>In his talk he introduces CDS and AppCDS and demonstrates how it can be used (<a href="https://simonis.github.io/JEEConf2018/CDS/cds.xhtml#/">web slides</a>).</dd>

  <dt><a href="https://developer.ibm.com/tutorials/j-class-sharing-openj9/"><b>IBM Developer</b></a>:<a name="ref_08">&nbsp;</a>Class sharing in Eclipse OpenJ9</dt>
  <dd><i>by Ben Corrie and Hang Shao (2018-06-06)</i><br/>In the <a href="https://www.eclipse.org/openj9/">OpenJ9</a> implementation, all systems, application classes and ahead-of-time (<a href="https://www.eclipse.org/openj9/docs/aot/">AOT</a>) compiled code can be stored in a dynamic class cache in shared memory.</dd>

  <dt><a href="https://www.youtube.com/watch?v=nniYSR4GAH4"><sub><img src="https://upload.wikimedia.org/wikipedia/commons/0/09/YouTube_full-color_icon_%282017%29.svg" alt="Youtube" width="20px"/></sub> Oracle Code 2018</a>:<a name="ref09">&nbsp;</a>Application Class Data Sharing</dt>
  <dd><i>by Ioi Lam and Jiangli Zhou (2018-10-23)</i><br/>Archiving and Sharing Class Metadata and Java Objects in HotSpot VM to Improve Startup Performance and Reduce Footprint (<a href="docs/20181023_Application_Class_Data_Sharing.pdf" title="">PDF</a>).</dd>
</dl>

<!--
## Footnotes

<a name="footnote_01">[1]</a> ***2018-08-17*** [↩](#anchor_01)

<div style="margin:0 0 1em 20px;">
</div>
-->
***

*[mics](http://lampwww.epfl.ch/~michelou/)/December 2018* [**&#9650;**](#top)