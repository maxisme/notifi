# mac
mv Your_App_Icon-assets/mac.appiconset/* ../macos/Runner/Assets.xcassets/AppIcon.appiconset/
mv Your_App_Icon-assets/error_menu.png ../macos/Runner/Assets.xcassets/menu_error_icon.imageset/
mv Your_App_Icon-assets/menu.png ../macos/Runner/Assets.xcassets/menu_icon.imageset/
mv Your_App_Icon-assets/menu_red.png ../macos/Runner/Assets.xcassets/red_menu_icon.imageset/

# ios
# brew install imagemagick
mv Your_App_Icon-assets/AppIcon.appiconset/* ../ios/Runner/Assets.xcassets/AppIcon.appiconset/
(cd ../ios/Runner/Assets.xcassets/AppIcon.appiconset/ && for file in *.png; do convert -flatten -alpha deactivate $file $file; done)

# flutter
mv Your_App_Icon-assets/sad.png ../images/
cp Your_App_Icon-assets/logo.png ../images/bell.png
cp Your_App_Icon-assets/logo.png ../android/app/src/main/res/drawable/app_icon.png


# play store App Icon
convert -resize 512x ../ios/Runner/Assets.xcassets/AppIcon.appiconset/1024.png ../android/fastlane/metadata/android/en-GB/images/icon.png
# play store Feature Graphic
convert ../ios/Runner/Assets.xcassets/AppIcon.appiconset/1024.png -resize 40% -gravity center -background "#bc2122" -extent 1024x500 ../android/fastlane/metadata/android/en-GB/images/featureGraphic.jpeg

# TODO splash screen