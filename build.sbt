import sbtcrossproject.CrossPlugin.autoImport.{crossProject, CrossType}

lazy val moduleTest = crossProject(JSPlatform, JVMPlatform)
  .withoutSuffixFor(JVMPlatform)
  .crossType(CrossType.Full)
  .in(file("."))
  .settings(ScalaModulePlugin.scalaModuleSettings)
  .jvmSettings(ScalaModulePlugin.scalaModuleSettingsJVM)
  .settings(
    name := "sbt-scala-module-test",
  )
  .jvmSettings(
    OsgiKeys.exportPackage := Seq(s"scala.moduletest.*;version=${version.value}"),
  )
  .jsSettings(
    fork in Test := false // Scala.js cannot run forked tests
  )
