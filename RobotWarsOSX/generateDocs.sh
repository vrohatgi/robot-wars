#!/bin/sh
# You need Jazzy - https://github.com/realm/jazzy
jazzy \
  --objc \
  --author RobotWars \
  --author_url http://www.makeschool.com \
  --github_url https://github.com/MakeSchool-Tutorials/Robot-Wars-SpriteKit \
  --github-file-prefix https://github.com/MakeSchool-Tutorials/Robot-Wars-SpriteKit/tree/master/RobotWarsOSX \
  --module-version 1.0 \
  --umbrella-header Engine/Robot.h \
  --framework-root . \
  --module RobotWars

