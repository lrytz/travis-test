name := "sbt-scala-module-test"

ScalaModulePlugin.scalaModuleSettings

sonatypeProfileName := "org.scala-lang"

sonatypeSessionName := { s"${sonatypeSessionName.value} Scala ${scalaVersion.value}" }
