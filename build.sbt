name := "travis-test"
organization := "com.github.lrytz"
homepage := Some(url("https://github.com/lrytz/travis-test"))
licenses := List("Apache-2.0" -> url("http://www.apache.org/licenses/LICENSE-2.0"))
developers := List(
  Developer(
    "lrytz",
    "Lukas Rytz",
    "",
    url("https://github.com/lrytz")))

// drop # stuff after tag
dynverGitDescribeOutput in ThisBuild ~= (_.map(dv =>
  dv.copy(ref = sbtdynver.GitRef(dv.ref.value.split('#').head))))
