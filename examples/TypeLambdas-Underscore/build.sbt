val dottyVersion = "0.15.0-RC1"

lazy val root = project
  .in(file("."))
  .settings(
    name := "Type Lambdas Underscore",
    description := "Example sbt project that compiles using Dotty",
    version := "0.1.0",

    scalaVersion := dottyVersion,
    scalacOptions ++= Seq(
      "-deprecation",
	  "-feature",
      "-encoding", "UTF-8"
    )
  )
