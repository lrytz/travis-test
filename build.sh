#!/bin/bash

set -ex

# Builds of tagged revisions are published to sonatype staging.

# Travis runs a build on new revisions and on new tags, so a tagged revision is built twice.
# Builds for a tag have TRAVIS_TAG defined, which we use for identifying tagged builds.

# sbt-dynver sets the version number from the tag
# sbt-travisci sets the Scala version from the travis job matrix

# When a new binary incompatible Scala version becomes available, a previously released version
# can be released using that new Scala version by creating a new tag containing the Scala version
# after a hash, e.g., v1.2.3#2.13.0-M3. In this situation, the first job of the travis job
# matrix builds the release. All other jobs are stopped. Make sure that the first job uses
# the desired JVM version.

if [[ "$TRAVIS_TAG" =~ ^.*#.*$ && "$ADOPTOPENJDK" == "8" && "$TRAVIS_SCALA_VERSION" = ^2\.13\.[0-9]+$ ]]; then
  # tag defines a Scala version. We pick the jobs of one Scala version (2.13.x) to do the releases.
  export RELEASE_JOB=true;
elif [[ "$ADOPTOPENJDK" == "8" && "$TRAVIS_SCALA_VERSION" =~ ^2\.1[123]\..*$ ]]; then
  # tag that needs to be cross-built. We release on JDK 8 for Scala 2.x
  export RELEASE_JOB=true;
fi

if [[ "$SCALAJS_VERSION" == "" ]]; then
  projectPrefix="moduleTest"
else
  projectPrefix="moduleTestJS"
fi

verPat="[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9-]+)?"
tagPat="^v$verPat(#$verPat)?$"

if [[ "$TRAVIS_TAG" =~ $tagPat ]]; then
  if [[ "$RELEASE_JOB" != "true" ]]; then
    echo "Not releasing on Java $ADOPTOPENJDK with Scala $TRAVIS_SCALA_VERSION"
    exit 0
  else
    releaseTask="ci-release"
    tagScalaVer=$(echo $TRAVIS_TAG | sed s/[^#]*// | sed s/^#//)
    if [[ "$tagScalaVer" != "" ]]; then
      setTagScalaVersion='set every scalaVersion := "'$tagScalaVer'"'
    fi
  fi
fi

# default is +publishSigned; we cross-build with travis jobs, not sbt's crossScalaVersions
# re-define pgp files to work around https://github.com/olafurpg/sbt-ci-release/issues/64
export CI_RELEASE="; set pgpSecretRing := pgpSecretRing.value; set pgpPublicRing := pgpPublicRing.value; $projectPrefix/publishSigned"
export CI_SNAPSHOT_RELEASE="$projectPrefix/publish"

# default is sonatypeBundleRelease, which closes and releases the staging repo
# see https://github.com/xerial/sbt-sonatype#commands
# for now, until we're confident in the new release scripts, just close the staging repo.
export CI_SONATYPE_RELEASE="; sonatypePrepare; sonatypeBundleUpload; sonatypeClose"

sbt "$setTagScalaVersion" clean $projectPrefix/headerCheck $projectPrefix/publishLocal $releaseTask
