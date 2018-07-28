import sbt._
import Keys._

object BuildSettings {
  val buildOrganization = "edu.berkeley.cs"
  val buildVersion = "1.0"
  val buildScalaVersion = "2.11.2"

  def apply(sourcePath: String, testPath: String) = {
    Defaults.defaultSettings ++ Seq (
      organization := buildOrganization,
      version := buildVersion,
      scalaVersion := buildScalaVersion,
      scalaSource in Compile := Path.absolute(file(sourcePath)),
      scalaSource in Test := Path.absolute(file(testPath)),
      libraryDependencies ++= Seq(
        "edu.berkeley.cs" %% "chisel3" % "3.1.+",
        "edu.berkeley.cs" %% "chisel-iotesters" % "1.2.+"
      )
    )
  }
}

object ChiselBuild extends Build {
  import BuildSettings._
  lazy val Core = Project(id = "Core",
    base = file("Core"),
    settings = BuildSettings(
      sourcePath = "../src/Core",
      testPath = "../src/test"
    )
  )
}
