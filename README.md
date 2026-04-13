# Crumbs

A daily journaling app for tracking small wins and the songs that match your mood.

## What it does

- **Drop a crumb** every day: write 1-2 sentences about your small win and pick a mood song
- **Calendar view** with hearts on days you showed up, streak tracking to keep you going
- **Monthly recap** that compiles all your wins and builds a mood mix playlist you can share
- **Song search** powered by iTunes with album art, 30-second previews, and top 10 trending songs
- **Profile** with cute avatar picker, dark/light/system theme toggle

## Tech

- SwiftUI + iOS 17+
- `@Observable` for state management
- iTunes Search API for music (no API key needed)
- Apple RSS feed for trending charts
- `AVPlayer` for song previews
- `UserDefaults` for local persistence
- Fully adaptive light/dark mode with ambient gradient backgrounds
