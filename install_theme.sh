#!/bin/sh

spotifyApp="/Applications/Spotify.app"
spotifyApps="$spotifyApp/Contents/Resources/Apps/"

# if [ $# -eq 0 ]
#   then
#     echo "Usage: install_theme.sh [theme]";
#     exit;
# fi

# weird hack to get the last argument
for last; do true; done

themeName=$last
workingDirectory=$(pwd)
themeDirectory="$workingDirectory/themes/$themeName/"
openSpotifyAfterInstall=false

# Check if -l exists
while getopts ":l:" o; do
    case "${o}" in
        l)
            openSpotifyAfterInstall=true
            ;;
    esac
done

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

cd "$themeDirectory"

for file in $spotifyApps*.spa; do
	filename=$(basename $file)
	foldername=${filename%%.*}
	echo "Patching $filename..."
	unzip -q $file -d $spotifyApps$foldername
	cp -r glue.css $spotifyApps$foldername/css/glue.css
	if [ ! "$filename" == "glue-resources.spa" ]; then
		cp -r $foldername/style.css $spotifyApps$foldername/css/style.css
	fi
	cd $spotifyApps$foldername
	zip -q -r -0 ../$filename .
	rm -rf $spotifyApps$foldername
	cd "$themeDirectory"
done

cd $workingDirectory

echo "";
echo "Theme installed!";

if [ "$openSpotifyAfterInstall" == true ]; then
	echo "";
	echo "Launching Spotify..."
	echo "";
	open $spotifyApp
fi