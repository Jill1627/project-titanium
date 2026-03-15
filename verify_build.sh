#!/bin/bash

echo "🔍 Verifying Project Setup..."
echo ""

# Check if files exist
echo "📁 Checking if new files exist..."
if [ -f "ProjectTitanium/Models/FigureSkatingElement.swift" ]; then
    echo "  ✅ FigureSkatingElement.swift exists"
else
    echo "  ❌ FigureSkatingElement.swift NOT FOUND"
    exit 1
fi

if [ -f "ProjectTitanium/Views/AthleteList/ElementPickerSheet.swift" ]; then
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
    echo "     See BUILD_FIX_GUIDE.md for instructions"
    exit 1
fi

if grep -q "ElementPickerSheet.swift" ProjectTitanium.xcodeproj/project.pbxproj; then
    echo "  ✅ ElementPickerSheet.swift is in project"
else
    echo "  ❌ ElementPickerSheet.swift NOT in project - please add it!"
    echo "     See BUILD_FIX_GUIDE.md for instructions"
    exit 1
fi

echo ""
echo "🔨 Attempting to build..."
xcodebuild -scheme ProjectTitanium -sdk iphonesimulator clean build 2>&1 | tee build.log

# Check for build errors
if grep -q "BUILD SUCCEEDED" build.log; then
    echo ""
    echo "✅ ✅ ✅ BUILD SUCCESSFUL! ✅ ✅ ✅"
    echo ""

    # Count warnings
    WARNING_COUNT=$(grep -c "warning:" build.log || echo "0")
    if [ "$WARNING_COUNT" -gt 0 ]; then
        echo "⚠️  Found $WARNING_COUNT warnings (expected ~4 deprecation warnings)"
        echo ""
        echo "Expected warnings:"
        echo "  - 'baseValueMultiplier' is deprecated (4x) - this is intentional"
        echo ""
    fi

    echo "🎉 Your project is ready to run!"
    echo ""
    echo "Next steps:"
    echo "  1. Open ProjectTitanium.xcodeproj in Xcode"
    echo "  2. Select a simulator (iPhone 15 or similar)"
    echo "  3. Press Cmd+R to run"
    echo "  4. Create a figure skating runthrough"
    echo "  5. Tap 'Select Element' to see the new picker!"

    rm build.log
    exit 0
else
    echo ""
    echo "❌ BUILD FAILED"
    echo ""
    echo "Errors found:"
    grep "error:" build.log | head -20
    echo ""
    echo "See build.log for full details"
    echo "See BUILD_FIX_GUIDE.md for help"
    exit 1
fi
