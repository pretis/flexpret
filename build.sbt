
// scalaVersion := "2.12.13"
scalaVersion := "2.12.10" // Issue on scalamacros:paradise

scalacOptions ++= Seq(
  "-deprecation",
  "-feature",
  "-unchecked",
  "-language:reflectiveCalls",
)

val chiselVersion = "3.5.5"
addCompilerPlugin("edu.berkeley.cs" %% "chisel3-plugin" % chiselVersion cross CrossVersion.full)
// We should drop this, needs source change
addCompilerPlugin("org.scalamacros" %% "paradise" % "2.1.0" cross CrossVersion.full)
libraryDependencies += "edu.berkeley.cs" %% "chisel3" % chiselVersion
libraryDependencies += "edu.berkeley.cs" %% "chiseltest" % "0.5.5"
libraryDependencies += "io.github.t-crest" % "soc-comm" % "0.1.4"


// disable publish scala version, otherwise artifact name will include scala version
// e.g cassper_2.11
crossPaths := false

lazy val flexpret = (project in file("."))