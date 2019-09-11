#!/bin/bash

set -ex

verPat="[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9-]+)?"
tagPat="^v$verPat(#$verPat)?$"
firstBuildPat="^[0-9]+\.1$"

if [[ "$TRAVIS_TAG" =~ $tagPat ]]; then
  if [[ "$RELEASE" != "true" ]]; then
    echo "Not releasing on Java $ADOPTOPENJDK with Scala $TRAVIS_SCALA_VERSION"
    exit 0
  else
    releaseTask="ci-release"
    tagScalaVer=$(echo $TRAVIS_TAG | sed s/[^#]*// | sed s/^#//)
    if [[ "$tagScalaVer" != "" ]]; then
      if [[ "$TRAVIS_JOB_NUMBER" =~ $firstBuildPat ]]; then
        setTagScalaVersion='set every scalaVersion := "'$tagScalaVer'"'
      else
        echo "The release for Scala $tagScalaVer is built by the first job in the travis job matrix"
        exit 0
      fi
    fi
  fi
fi

sbt "$setTagScalaVersion" publishLocal $releaseTask
