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

## Screenshots

_Coming soon_

## Getting started

1. Clone the repo
2. Open `Crumbs.xcodeproj` in Xcode
3. Pick a simulator (iPhone 16 Pro recommended)
4. Hit Run (Cmd+R)

No API keys or dependencies required — everything works out of the box.

## Project structure

```
Crumbs/
  CrumbsApp.swift           # App entry point
  ContentView.swift          # Tab bar
  Theme/
    Theme.swift              # Colors, gradients, GradientIcon, adaptive theming
  Models/
    DailyEntry.swift         # Daily win + song data model
    UserProfile.swift        # User profile model
  Store/
    EntryStore.swift         # Entry persistence + streak logic
    MusicService.swift       # iTunes search, trending, audio preview
    ProfileStore.swift       # Profile persistence + appearance
  Views/
    HomeView.swift           # Today's entry screen
    CalendarView.swift       # Calendar with hearts + stats
    RecapView.swift          # Monthly recap + shareable playlist
    SongSearchView.swift     # Song search with previews + trending
    ProfileView.swift        # Avatar, settings, appearance
```
