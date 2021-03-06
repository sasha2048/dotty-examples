val dottyVersion = "3.0.0-M4"

lazy val root = project
  .in(file("."))
  .settings(
    name := "Interpolators",
    description := "sbt example project to build/run Scala 3 applications",
    version := "0.1.0",

    scalaVersion := dottyVersion,
    scalacOptions ++= Seq(
      "-deprecation",
      "-encoding", "UTF-8"
    ),

    mainClass in Compile := Some("Main"),
    logLevel := Level.Warn,

    libraryDependencies ++= Seq(
      // https://mvnrepository.com/artifact/org.scala-lang.modules/scala-xml_2.13
      "org.scala-lang.modules" %% "scala-xml" % "1.2.0").withDottyCompat(scalaVersion.value
    )
  )
