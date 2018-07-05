import sbt._
import Keys._

object BuildSettings {
  val buildOrganization = "edu.berkeley.cs"
  val buildVersion = "1.0"
  val buildScalaVersion = "2.11.2"

  def apply(sourcePath: String) = {
    Defaults.defaultSettings ++ Seq (
      organization := buildOrganization,
      version := buildVersion,
      scalaVersion := buildScalaVersion,
      scalaSource in Compile := Path.absolute(file(sourcePath)),
      libraryDependencies += "edu.berkeley.cs" %% "chisel3" % "3.1.+"
    )
  }
}

object ChiselBuild extends Build {
   import BuildSettings._
   lazy val Core = Project("Core", file("Core"), settings = BuildSettings("../src/Core"))
}
