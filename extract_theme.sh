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
mkdir $themeFolder

for file in $spotifyApps*.spa; do
	filename=$(basename $file)
	folder="${filename%%.*}/"
	cp -R $file $themeFolder
	echo "Extracting $filename..."
	unzip -q $file -d $themeFolder$folder
	if [ "$filename" == "zlink.spa" ]; then
		cp -r $themeFolder$folder/css/glue.css $themeFolder/
	fi
done

printf "\nDone! Theme saved in $themeFolder\n"