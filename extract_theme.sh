#!/bin/sh

spotifyApp="/Applications/Spotify.app/"
spotifyApps="$spotifyApp/Contents/Resources/Apps/"

if [ $# -eq 0 ]
  then
    echo "Usage: extract_theme.sh [name]";
    exit;
fi

workingDirectory=$(pwd)
themeName=$1;
themeFolder="$workingDirectory/$themeName/"
tempFolder="$workingDirectory/tmp/"

rm -rf $tempFolder
mkdir $themeFolder
mkdir $tempFolder

for file in $spotifyApps*.spa; do
	filename=$(basename $file)
	folder="${filename%%.*}/"
	echo "Extractiong $filename..."
	unzip -q $file -d $tempFolder$folder
	mkdir $themeFolder$folder
	cp -r $tempFolder$folder/css/style.css $themeFolder$folder
	if [ "$filename" == "zlink.spa" ]; then
		cp -r $tempFolder$folder/css/glue.css $themeFolder/
	fi
done

rm -rf $tempFolder

printf "\nDone! Theme saved in $themeFolder\n"