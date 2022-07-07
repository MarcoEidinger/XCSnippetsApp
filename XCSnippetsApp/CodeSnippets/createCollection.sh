#!/bin/bash

rm -r Collection
mkdir Collection
cp me.codesnippet/*.codesnippet ./Collection
cp ios-xcode-snippets/*.codesnippet ./Collection
cp SwiftSnippets/Snippets/*.codesnippet ./Collection
cp QMUI_iOS_CodeSnippets/*.codesnippet ./Collection
cp XcodeSwiftSnippets/*.codesnippet ./Collection
rm ./Collection/swift-createproperty.codesnippet

cd converter
swift run converter
cd ..
