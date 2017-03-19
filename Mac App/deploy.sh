#!/bin/bash

#INITIAL VARIABLES THAT NEED TO BE CUSTOMISED
project_name="notifi"
project_type=".xcworkspace"
project_path="/Users/maxmitch/Documents/notifi/Mac App/"
dev_team="3H49MXS325"
dmg_project_output="/Users/maxmitch/Documents/notifi/notifi.it/public_html/notifi.dmg"

#NOT IMPORTANT INITIAL VARIABLES
xcode_project=$project_path$project_name$project_type
plist=$project_path"buildOptions.plist"
xcarchive=$project_path"tmp.xcarchive"

#countdown function
function countDown {
	secs=$((20))
	while [ $secs -gt 0 ]; do
	   echo -ne "Will exit in $secs\033[0K\r"
	   sleep 1
	   : $((secs--))
	done
	exit
}

#create temp .plist file
echo "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\"><plist version=\"1.0\"><dict><key>method</key><string>developer-id</string><key>teamID</key><string>$dev_team</string></dict></plist>" > "$plist"

#build project
type="-project"
#Change '-project' to '-workspace'. Depending on if $project_type is '.xcodeproj' or '.xcworkspace'.
if [[ $project_type == ".xcworkspace" ]]; then
	type="-workspace"
fi
xcodebuild $type "$xcode_project" -scheme "$project_name" -configuration Release clean archive -archivePath "$xcarchive" DEVELOPMENT_TEAM=$dev_team

#check if last command succeeded
if [ $? -ne 0 ]; then
	countDown
fi

xcodebuild -exportArchive -archivePath "$xcarchive" -exportOptionsPlist "$plist" -exportPath "$project_path"

#check if last command succeeded
if [ $? -ne 0 ]; then
	countDown
fi

cd "$project_path" || exit

bash ~/createdmg "$dmg_project_output" "$project_name.app/"

#remove temp files used in build
echo "cleaning up..."
rm -rf "$project_path$project_name.app" "$xcarchive" "$plist"

#commit
git commit "$dmg_project_output" -m "Update Mac App - via build script"
git push origin master

#upload to website
server_path=$(cat "/Users/maxmitch/Documents/notifi/server.path")
scp "$dmg_project_output" $server_path

countDown
