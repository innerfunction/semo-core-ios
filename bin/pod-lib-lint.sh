#/bin/bash
# Lint this project's podspec.
# Additional arguments, e.g. --verbose --no-clean, can be included on the command line.
ARGS="$*"
pod lib lint --allow-warnings $ARGS semo-core-ios.podspec
