# App Icon Setup Guide

Your app currently has no icon configured. Here's how to add one:

## Required Icon Sizes for macOS

You need to create icons in these sizes and add them to `MultiTimeInMenuBar/Assets.xcassets/AppIcon.appiconset/`:

- **16x16** pixels (icon_16x16.png)
- **32x32** pixels (icon_16x16@2x.png)
- **32x32** pixels (icon_32x32.png)
- **64x64** pixels (icon_32x32@2x.png)
- **128x128** pixels (icon_128x128.png)
- **256x256** pixels (icon_128x128@2x.png)
- **256x256** pixels (icon_256x256.png)
- **512x512** pixels (icon_256x256@2x.png)
- **512x512** pixels (icon_512x512.png)
- **1024x1024** pixels (icon_512x512@2x.png)

## Easy Way: Use an Icon Generator

1. **Create or find a 1024x1024 PNG icon** for your app
2. **Use an online icon generator** like:
   - [AppIcon.co](https://appicon.co/)
   - [IconGenerator](https://icongenerator.net/)
   - [MakeAppIcon](https://makeappicon.com/)

3. **Upload your 1024x1024 icon** and download the macOS icon set
4. **Copy the generated files** to `MultiTimeInMenuBar/Assets.xcassets/AppIcon.appiconset/`

## Manual Way: Using Xcode

1. **Open your project in Xcode**
2. **Navigate to** `MultiTimeInMenuBar/Assets.xcassets/AppIcon`
3. **Drag and drop** your icon files into the appropriate slots
4. **Xcode will automatically** update the Contents.json file

## Icon Design Tips

- **Use a simple, recognizable design** that works at small sizes
- **Avoid text** in the icon (it becomes unreadable at small sizes)
- **Use high contrast** and bold shapes
- **Consider the menu bar context** - your app will appear as a small icon in the menu bar
- **Clock/time theme** would be appropriate for your timezone app

## For Menu Bar Apps Specifically

Since this is a menu bar app, you might also want to create:
- **Menu bar icons** (typically 16x16 and 32x32, black and white)
- **Template images** for the menu bar status item

These would go in separate image sets in Assets.xcassets.

## Quick Test

After adding icons:
1. **Build your app locally** using `./scripts/build-local.sh`
2. **Check if the icon appears** in Finder and when you run the app
3. **The GitHub Actions will automatically** use the 512x512 icon for the DMG

## Current Status

✅ **FIXED**: Your app icon is now properly configured! 
- Icon file: `MultiTimeInMenuBar/Assets.xcassets/AppIcon.appiconset/AppIcon.icns`
- Contents.json: Properly configured for macOS
- GitHub Actions: Updated to use the correct icon path for DMG creation

Your app icon should now appear correctly in the DMG and when the app is installed. 