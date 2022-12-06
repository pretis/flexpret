
// scalaVersion := "2.12.13"
scalaVersion := "2.12.10"

scalacOptions ++= Seq(
  "-deprecation",
  "-feature",
  "-unchecked",
  "-language:reflectiveCalls",
// The following should go with a newer Chisel version
  "-Xsource:2.11"
)

// val chiselVersion = "3.5.5"
val chiselVersion = "3.4.4"
addCompilerPlugin("edu.berkeley.cs" %% "chisel3-plugin" % chiselVersion cross CrossVersion.full)
// We should drop this, needs source change
addCompilerPlugin("org.scalamacros" %% "paradise" % "2.1.0" cross CrossVersion.full)
libraryDependencies += "edu.berkeley.cs" %% "chisel3" % chiselVersion
libraryDependencies += "edu.berkeley.cs" %% "chiseltest" % "0.3.3"
// libraryDependencies += "org.scalamacros" %% "paradise" % "2.1.0"


// disable publishw ith scala version, otherwise artifact name will include scala version
// e.g cassper_2.11
crossPaths := false
