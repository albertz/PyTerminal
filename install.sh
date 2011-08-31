#!/bin/zsh

cd "$(dirname "$0")"

# for some reason, this fails...
#xcodebuild

fr=""
for f in ~/Library/Developer/Xcode/DerivedData/PyTerminal-*/Build/Products/Debug/PyTerminal.framework; do
	echo "found framework: $f"
	[ "$fr" != "" ] && echo "had already another framework, FAIL" && exit 1
	fr=f
done

[ \! -d $f ] && echo "FAIL" && exit 1

#install_name_tool -change  ...

echo "copying .."
sudo rm -rf "/Library/Frameworks/PyTerminal.framework"
sudo cp -a $f "/Library/Frameworks/"
