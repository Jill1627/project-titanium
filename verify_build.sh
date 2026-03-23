#!/bin/bash

echo "🔍 Verifying Project Setup..."
echo ""

# Check if files exist
echo "📁 Checking if new files exist..."
if [ -f "ProjectTitanium/Core/Models/FigureSkatingElement.swift" ]; then
    echo "  ✅ FigureSkatingElement.swift exists"
else
    echo "  ❌ FigureSkatingElement.swift NOT FOUND"
    exit 1
fi

if [ -f "ProjectTitanium/Features/AthleteList/ElementPickerSheet.swift" ]; then
    echo "  ✅ ElementPickerSheet.swift exists"
else
    echo "  ❌ ElementPickerSheet.swift NOT FOUND"
    exit 1
fi

echo ""
echo "📋 Checking if files are in Xcode project..."

# Check if files are in pbxproj
if grep -q "FigureSkatingElement.swift" ProjectTitanium.xcodeproj/project.pbxproj; then
    echo "  ✅ FigureSkatingElement.swift is in project"
else
    echo "  ❌ FigureSkatingElement.swift NOT in project - please add it!"
    exit 1
fi

if grep -q "ElementPickerSheet.swift" ProjectTitanium.xcodeproj/project.pbxproj; then
    echo "  ✅ ElementPickerSheet.swift is in project"
else
    echo "  ❌ ElementPickerSheet.swift NOT in project - please add it!"
    exit 1
fi

echo ""
echo "🔨 Attempting to build..."
# Use -quiet to keep it brief if successful
xcodebuild -scheme ProjectTitanium -sdk iphonesimulator clean build 2>&1 | tee build.log

# Check for build errors
if grep -q "BUILD SUCCEEDED" build.log; then
    echo ""
    echo "✅ ✅ ✅ BUILD SUCCESSFUL! ✅ ✅ ✅"
    rm build.log
    exit 0
else
    echo ""
    echo "❌ BUILD FAILED"
    echo ""
    echo "Top 20 Errors found:"
    grep -E "error:|error :" build.log | sed 's/^[[:space:]]*//' | head -20
    echo ""
    echo "See build.log for full details"
    exit 1
fi
