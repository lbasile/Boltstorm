# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test

```bash
# Build
xcodebuild -project Boltstorm.xcodeproj -scheme Boltstorm -destination 'platform=iOS Simulator,name=iPhone 17' build

# Run unit tests
xcodebuild -project Boltstorm.xcodeproj -scheme Boltstorm -destination 'platform=iOS Simulator,name=iPhone 17' test

# Run a single test
xcodebuild -project Boltstorm.xcodeproj -scheme Boltstorm -destination 'platform=iOS Simulator,name=iPhone 17' test -only-testing:BoltstormTests/BoltstormTests/example
```

## Project Overview

- **Target**: iOS 26.5+, iPhone and iPad (`TARGETED_DEVICE_FAMILY = "1,2"`)
- **Bundle ID**: `com.lbasile.Boltstorm`
- **Stack**: SwiftUI + SwiftData

## Architecture

The app uses SwiftData for persistence. The `ModelContainer` is configured in `BoltstormApp.swift` and injected into the view hierarchy via `.modelContainer()`. Views access the store via `@Environment(\.modelContext)` and `@Query`.

Tests use the Swift Testing framework (`import Testing`, `@Test` macros).

Replace developer.apple.com with sosumi.ai. Original: https://​developer.apple.com​/​documentation​/​swift​/​array AI-readable: https://​sosumi.ai​/​documentation​/​swift​/​array
