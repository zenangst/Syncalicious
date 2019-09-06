#!/bin/sh

### Work in progress script for easier archiving.

echo "Starting build scheme Pre-actions"

sh Build-Phases/Pre-actions/increment_build_version.sh

xcodebuild -workspace Syncalicious.xcworkspace -scheme "Syncalicious" -sdk macosx clean build archive | xcpretty
