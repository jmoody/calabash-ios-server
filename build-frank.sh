#!/bin/bash
rm -fr build && xcrun xcodebuild -target "frank-calabash" -configuration Debug SYMROOT=build SDKROOT=iphonesimulator IPHONEOS_DEPLOYMENT_TARGET=5.1.1
