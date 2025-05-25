#!/bin/bash

# Local build script for MultiTimeInMenuBar
# This script mimics the GitHub Actions build process for local testing

set -e  # Exit on any error

echo "🏗️  Building MultiTimeInMenuBar locally..."

# Clean any previous builds
rm -rf build/
mkdir -p build/

echo "📦 Building archive..."
xcodebuild -project MultiTimeInMenuBar.xcodeproj \
           -scheme MultiTimeInMenuBar \
           -configuration Release \
           -derivedDataPath build/ \
           -archivePath build/MultiTimeInMenuBar.xcarchive \
           archive

echo "📤 Exporting app..."
# Create export options plist for local development
cat > build/ExportOptions.plist << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>development</string>
    <key>signingStyle</key>
    <string>automatic</string>
    <key>stripSwiftSymbols</key>
    <true/>
</dict>
</plist>
EOF

# Export the archive
xcodebuild -exportArchive \
           -archivePath build/MultiTimeInMenuBar.xcarchive \
           -exportPath build/export \
           -exportOptionsPlist build/ExportOptions.plist

echo "✅ Build completed successfully!"
echo "📍 App location: build/export/MultiTimeInMenuBar.app"

# Optional: Open the build folder
if command -v open &> /dev/null; then
    echo "🔍 Opening build folder..."
    open build/export/
fi

echo ""
echo "💡 To test the app:"
echo "   1. Navigate to build/export/"
echo "   2. Double-click MultiTimeInMenuBar.app to run"
echo ""
echo "🚀 When ready for release, push a tag to trigger GitHub Actions:"
echo "   git tag v1.0.0"
echo "   git push origin v1.0.0" 