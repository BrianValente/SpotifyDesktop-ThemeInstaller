#!/bin/sh

{
	cd "$(dirname "$0")"

	spotifyApp="/Applications/Spotify.app"
	spotifyApps="$spotifyApp/Contents/Resources/Apps/"

	# if [ $# -eq 0 ]
	#   then
	#     echo "Usage: install_theme.sh [-l] [theme]";
	#     exit;
	# fi

	# weird hack to get the last argument
	for last; do true; done

	themeName=$last
	workingDirectory=$(pwd)
	stockDirectory="$workingDirectory/.stock"
	themeDirectory="$workingDirectory/themes/$themeName"
	tempDirectory="$workingDirectory/.tmp"
	openSpotifyAfterInstall=false

	# Check if -l exists
	while getopts ":l:" o; do
	    case "${o}" in
	        l)
	            openSpotifyAfterInstall=true
	            ;;
	    esac
	done

	if [ "$themeName" == "stock" ]; then
		{
			if [ "$openSpotifyAfterInstall" == true ]; then
				echo "\nKilling Spotify..."
				killall Spotify 2> /dev/null
			fi

			echo "\nRestoring stock theme...\n"
			cd $stockDirectory
			for file in *.spa; do
				echo "Restoring $file..."
				cp $file $spotifyApps/
			done

			echo "\nTheme restored.\n"

			if [ "$openSpotifyAfterInstall" == true ]; then
				echo "Launching Spotify...\n"
				open $spotifyApp
			fi

			exit
		}
		
	fi

	if [ ! -d "$themeDirectory" ]; then
		echo "The specified theme does not exist!"
		exit
	fi

	if [ "$openSpotifyAfterInstall" == true ]; then
		echo "Killing Spotify..."
		killall Spotify 2> /dev/null
	fi

	echo "Installing $themeName..."
	echo ""

	rm -rf $tempDirectory
	mkdir $tempDirectory

	(
		cd $tempDirectory

		# Copy uncompressed stock theme
		cp -R $stockDirectory/* ./

		# Delete stock .spa
		for file in *.spa; do
			rm $file
		done

		# Prepare glue
		cp zlink/css/glue.css ./
		cat $(echo $themeDirectory/glue.css) >> glue.css

		# Insert style to each themed component
		for folder in $themeDirectory/*/; do
			componentName=$(basename $folder)
			if [ "$componentName" == "zlink" ]; then
				if [ -f $folder/main.css ]; then
					cat $(echo $folder/main.css) >> $componentName/css/main.css
				fi
				if [ -f $folder/main.bundle.js ]; then
				    cat $(echo $folder/main.bundle.js) >> $componentName/main.bundle.js
				fi
				if [ -f $folder/index.html ]; then
				    cp $(echo $folder/index.html) $componentName/index.html
				fi
			else
				if [ -f $folder/style.css ]; then
				    cat $(echo $folder/style.css) >> $componentName/css/style.css
				fi
				if [ -f $folder/script.js ]; then
				    cat $(echo $folder/script.js) >> $componentName/bundle.js
				fi
				if [ -f $folder/index.html ]; then
				    cp $(echo $folder/index.html) $componentName/index.html
				fi
			fi
		done
		
		for folder in */; do
			componentName=$(basename $folder)

			# Copy new glue to each component
			cp glue.css $componentName/css/glue.css

			# Compile (zip)
			(
				cd $tempDirectory/$folder
				zip -q -r -0 ../$componentName.spa .
			)
		done

		# Install spa files
		for file in *.spa; do
			cp $file $spotifyApps/
		done

		rm -rf $tempDirectory
	)

	echo "";
	echo "Theme installed!";

	if [ "$openSpotifyAfterInstall" == true ]; then
		echo "";
		echo "Launching Spotify..."
		echo "";
		open $spotifyApp
	fi
}
