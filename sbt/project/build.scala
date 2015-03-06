import sbt._
import Keys._

object BuildSettings {
  val buildOrganization = "edu.berkeley.cs"
  val buildVersion = "1.0"
  val buildScalaVersion = "2.10.5"

  def apply(sourcePath: String) = {
    Defaults.defaultSettings ++ Seq (
      organization := buildOrganization,
      version := buildVersion,
      scalaVersion := buildScalaVersion,
      scalaSource in Compile := Path.absolute(file(sourcePath)),
      libraryDependencies += "edu.berkeley.cs" % "chisel_2.10" % "2.2.12"
    )
  }
}

object ChiselBuild extends Build {
   import BuildSettings._
   lazy val common = Project("common", file ("common"), settings = BuildSettings("../src/common"))
   lazy val Core = Project("Core", file("Core"), settings = BuildSettings("../src/Core")) dependsOn(common)
}
