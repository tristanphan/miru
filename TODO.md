## To Do

- Improve UI
    - Make more appealing
    - Tweak UI scaling
    - Separate pages
- Code Cleanup & Comments
- Video Player Tweaks
    - Make buffer indicator more consistent
    - Action when video ends
    - Picture-in-Picture?
    - Background play & hook into system (control center, notifications, etc.)
    - Work with media keys and headphone buttons
    - Add more keyboard shortcuts
    - Fix slider tooltip animation
- Handoff?
- Add more sources
- Proper Downloads Page
- Work on Android support
- Add support for Windows, Linux, and macOS (Intel / Universal)
    - Find an alternative to InAppWebView for scraping with JS
- MyAnimeList / AniList integration?
    - Use either to fetch show information, instead of GoGoAnime's summaries
- Improve or remove the need for Fallback Mode

### Issues to Fix

- Save Frame saves a frame near, but not exactly where the playhead is
- Seeking video does not update the current frame until play
