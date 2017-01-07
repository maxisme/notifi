#!/bin/bash
app_path="/Users/maxmitch/Documents/notifi/OSX App/"
zip_output="/Users/maxmitch/Documents/notifi/notifi.it/notifi.zip"
project=$app_path"notifi.xcodeproj"
plist=$app_path"buildOptions.plist"
output=$app_path"tmp.xcarchive" 
dev_team="3H49MXS325"

#build
xcodebuild -project "$project" -scheme notify -configuration Release clean archive -archivePath "$output" DEVELOPMENT_TEAM=$dev_team
xcodebuild -exportArchive -archivePath "$output" -exportOptionsPlist "$plist" -exportPath "$app_path"

#zip app
cd "$app_path"
zip -r -y "$zip_output" notifi.app

#remove temp files
rm -rf "notifi.app"
rm -rf "$output"

#commit
git commit $zip_output -m "Update OSX App - via build script"
git push origin master

#upload to website
scp $zip_output root@185.117.22.245:/var/www/notifi.it/public_html/

#analyze results
secs=$((20))
while [ $secs -gt 0 ]; do
   echo -ne "Will close in $secs\033[0K\r"
   sleep 1
   : $((secs--))
done