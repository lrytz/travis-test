import sbtcrossproject.CrossPlugin.autoImport.{CrossType, crossProject}

// With CrossType.Pure, the root project also picks up the sources in `src`
Compile/sources := Nil
Test/sources := Nil

lazy val moduleTest = (file(".") / crossProject(JVMPlatform, JSPlatform, NativePlatform)
  .withoutSuffixFor(JVMPlatform)
  .crossType(CrossType.Full))
  .settings(ScalaModulePlugin.scalaModuleSettings)
  .jvmSettings(ScalaModulePlugin.scalaModuleOsgiSettings)
  .settings(
    name := "sbt-scala-module-test",
  )
  .jvmSettings(
    OsgiKeys.exportPackage := Seq(s"scala.moduletest.*;version=${version.value}"),
  )
  .jsSettings(
    (Test / fork) := false // Scala.js cannot run forked tests
  )
