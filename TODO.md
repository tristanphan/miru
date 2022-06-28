### Issues to Fix

- Save Frame does not work on m3u8 files
- Decentralize sources

## Planned Features

- Code Cleanup & Comments
- Video Player Tweaks
    - Picture-in-Picture?
    - Background play & hook into system (control center, notifications, etc.)
    - Work with media keys and headphone buttons
    - Add more keyboard shortcuts
    - Fix slider's tooltip's animation
- Handoff?
- Proper Downloads Page
- Polish Android support
- Add macOS support
  - Find a video player library for macOS
- MyAnimeList / AniList integration?
    - Use either to fetch show information, instead of GoGoAnime's summaries

## Migrating to Desktop
- Video Player
  - For macOS: https://github.com/cbenhagen/plugins/tree/video_player_macos_new/packages/video_player/video_player_macos
  - For Windows/Linux: https://pub.dev/packages/dart_vlc
- Replace share with download
- Find alternative to video_thumbnail
- Note: wakelock does not support linux, either find alternative or abandon feature for linux
