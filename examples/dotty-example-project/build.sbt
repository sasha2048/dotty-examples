val dottyVersion = "3.0.0-M4"

lazy val root = project
  .in(file("."))
  .settings(
    name := "dotty-example-project",
    description := "sbt example project to build/run Scala 3 applications",
    version := "0.1.0",

    scalaVersion := dottyVersion,
    scalacOptions ++= Seq(
      "-deprecation",
      "-encoding", "UTF-8",
      "-feature"
    ),

    libraryDependencies ++= Seq(
      // https://mvnrepository.com/artifact/com.novocode/junit-interface
      "com.novocode" % "junit-interface" % "0.11" % "test"
    )
  )
