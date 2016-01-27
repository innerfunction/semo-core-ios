#/bin/bash
# Lint this project's podspec.
# Additional arguments, e.g. --verbose --no-clean, can be included on the command line.
pod lib lint --allow-warnings "$*" semo-core-ios.podspec
