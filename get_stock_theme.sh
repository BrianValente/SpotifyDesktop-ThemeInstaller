#!/bin/sh

{
	cd "$(dirname "$0")"
	
	spotifyApp="/Applications/Spotify.app/"
	spotifyApps="$spotifyApp/Contents/Resources/Apps/"

	# if [ $# -eq 0 ]
	#   then
	#     echo "Usage: extract_theme.sh [name]";
	#     exit;
	# fi

	workingDirectory=$(pwd)
	themeFolder="$workingDirectory/.stock/"

	hashFile=$themeFolder".hash"
	currentThemeHash=$(md5 -q $spotifyApps"zlink.spa")

	rm -rf $themeFolder
	mkdir $themeFolder

	# if [ -f $hashFile ]; then
	# 	savedThemeHash=$(cat $hashFile)

	# 	echo "$currentThemeHash\n$savedThemeHash"

	# 	if [ "$currentThemeHash" == "$savedThemeHash" ]; then
	# 		echo "The saved Stock theme is up to date."
	# 		exit
	# 	fi

	# 	rm -rf $themeFolder
	# else
	# 	mkdir $themeFolder
	# fi

	echo "Saving a copy of the original Stock theme...\n"

	for file in $spotifyApps*.spa; do
		filename=$(basename $file)
		folder="${filename%%.*}/"
		cp -R $file $themeFolder
		echo "Copying and extracting $filename..."
		unzip -q $file -d $themeFolder$folder
		if [ "$filename" == "zlink.spa" ]; then
			cp -r $themeFolder$folder/css/glue.css $themeFolder/
		fi
	done

	touch "$hashFile"
	echo "$currentThemeHash" >> $hashFile

	printf "\nDone! Theme saved in $themeFolder\n"
}