ifeq ($(OS),Windows_NT)
JAVAC      = $(subst \,/,$(JAVA_HOME))/bin/javac.exe
JAVA       = $(subst \,/,$(JAVA_HOME))/bin/java.exe
SCALAC     = $(subst \,/,$(SCALA3_HOME))/bin/scalac.bat
SCALADOC   = $(subst \,/,$(SCALA3_HOME))/bin/scalad.bat
SCALA      = $(subst \,/,$(SCALA3_HOME))/bin/scala.bat
LOCAL_REPO = $(subst \,/,$(USERPROFILE))/.m2/repository
PSEP       = ;
else
JAVAC      = $(JAVA_HOME)/bin/javac
JAVA       = $(JAVA_HOME)/bin/java
SCALAC     = $(SCALA3_HOME)/bin/scalac
SCALADOC   = $(SCALA3_HOME)/bin/scalad
SCALA      = $(SCALA3_HOME)/bin/scala
LOCAL_REPO = $(HOME)/.m2/repository
PSEP       = :
endif

SCALA_LIB_JAR      = $(shell find "$(LOCAL_REPO)/org/scala-lang" -name scala-library-2.13.5.jar)
SCALA3_LIB_JAR     = $(shell find "$(LOCAL_REPO)/org/scala-lang" -name scala3-library_3.0.0-RC1-3.0.0-RC1.jar)
HAMCREST_JAR       = $(shell find "$(LOCAL_REPO)/org/hamcrest" -name hamcrest-2.2.jar)
JUNIT_JAR          = $(shell find "$(LOCAL_REPO)/junit/junit" -name junit-4.13.2.jar)
JUNIT_INTF_JAR     = $(shell find "$(LOCAL_REPO)/com/novocode" -name junit-interface-0.11.jar)
SCALATEST_JAR      = $(shell find "$(LOCAL_REPO)/org/scalatest" -name scalatest_2.13-3.2.5.jar)
SCALACTIC_JAR      = $(shell find "$(LOCAL_REPO)/org/scalactic" -name scalactic_2.13-3.2.5.jar)
SPECS2_CORE_JAR    = $(shell find "$(LOCAL_REPO)/org/specs2" -name specs2-core_2.13-4.10.6.jar)
SPECS2_JUNIT_JAR   = $(shell find "$(LOCAL_REPO)/org/specs2" -name specs2-junit_2.13-4.10.6.jar)
SPECS2_MATCHER_JAR = $(shell find "$(LOCAL_REPO)/org/specs2" -name specs2-matcher_2.13-4.10.6.jar)