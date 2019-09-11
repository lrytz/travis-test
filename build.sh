#!/bin/bash

set -ex

verPat="[0-9]+\.[0-9]+\.[0-9]+(-[A-Za-z0-9-]+)?"
tagPat="^v$verPat(#$verPat#[0-9]+)?$"

if [[ "$RELEASE" == "true" && "$TRAVIS_TAG" =~ $tagPat ]]; then
  releaseTask="ci-release"

  tagScalaVer=$(echo $TRAVIS_TAG | sed s/[^#]*// | sed s/^#//)
  if [[ "$tagScalaVer" != "" ]]; then
    if [[ "$TRAVIS_JOB_NUMBER" =~ "[0-9]+\.1" ]]; then
      setTagScalaVersion='set every scalaVersion := "'$tagScalaVer'"'
    else
      echo "The release for Scala $tagScalaVer is built by the job in the travis job matrix"
      exit 0
    fi
  fi
fi

sbt "$setTagScalaVersion" publishLocal "$releaseTask"
