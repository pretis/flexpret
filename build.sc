import mill._, scalalib._
import coursier.maven.MavenRepository

/**
 * Scala 2.12 module that is source-compatible with 2.11.
 * This is due to Chisel's use of structural types. See
 * https://github.com/freechipsproject/chisel3/issues/606
 */
trait HasXsource211 extends ScalaModule {
  override def scalacOptions = T {
    super.scalacOptions() ++ Seq(
      "-deprecation",
      "-unchecked",
      "-Xsource:2.11"
    )
  }
}

trait HasChisel3 extends ScalaModule {
  override def ivyDeps = Agg(
    ivy"edu.berkeley.cs::chisel3:3.5.5"
 )
}

trait HasChiselTests extends CrossSbtModule  {
   def repositories() = super.repositories ++ Seq(
    MavenRepository("https://oss.sonatype.org/content/repositories/snapshots"),
    MavenRepository("https://oss.sonatype.org/content/repositories/releases")
  )
  object test extends Tests {
    override def ivyDeps = Agg(
      // ivy"org.scalatest::scalatest:3.0.4",
      ivy"edu.berkeley.cs::chiseltest:0.5.+"
    )
    def testFrameworks = Seq("org.scalatest.tools.Framework")

    // sbt-like testOnly command
    def testOnly(args: String*) = T.command {
      super.runMain("org.scalatest.run", args: _*)
    }
  }
}

trait HasMacroParadise extends ScalaModule {
  // Enable macro paradise for @chiselName et al
  val macroPlugins = Agg(ivy"org.scalamacros:::paradise:2.1.0")
  def scalacPluginIvyDeps = macroPlugins
  def compileIvyDeps = macroPlugins
}

trait HasCompilerPLugin extends ScalaModule {
  // Enable macro paradise for @chiselName et al
  val compilerPlugins = Agg(ivy"edu.berkeley.cs::chisel3-pluginorg:3.5.+")
  def scalacPluginIvyDeps = compilerPlugins
  def compileIvyDeps = compilerPlugins
}

object flexpret extends CrossSbtModule with HasCompilerPLugin with HasChisel3 with HasChiselTests with HasXsource211 with HasMacroParadise {
  def crossScalaVersion = "2.12.10"
  def mainClass = Some("Core.CoreMain")
}
