## To Do

- Code Cleanup & Comments
- Video Player Tweaks
    - Picture-in-Picture?
    - Background play & hook into system (control center, notifications, etc.)
    - Work with media keys and headphone buttons
    - Add more keyboard shortcuts
    - Fix slider's tooltip's animation
- Handoff?
- Add more sources
- Proper Downloads Page
- Work on Android support
- Add support for Windows, Linux, and macOS (Intel / Universal)
  - Wait for VideoPlayer to support desktop OR find alternative video player
- MyAnimeList / AniList integration?
    - Use either to fetch show information, instead of GoGoAnime's summaries

### Issues to Fix

- Save Frame saves a frame near, but not exactly where the playhead is
- Seeking video does not update the current frame until play

## Migrating to Desktop
- Video Player
  - For macOS: https://github.com/cbenhagen/plugins/tree/video_player_macos_new/packages/video_player/video_player_macos
  - For Windows/Linux: https://pub.dev/packages/dart_vlc
- Replace share with download
- Find alternative to video_thumbnail
- Note: wakelock does not support linux, either find alternative or abandon feature for linux
