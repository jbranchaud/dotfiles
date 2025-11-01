# ChromeTabSaver.spoon

A Hammerspoon Spoon to save and close unpinned Chrome tabs to a JSON file organized by date.

## Features

- 📁 Saves unpinned Chrome tabs to a JSON file organized by date
- 🔒 Preserves pinned tabs (never saves or closes them)
- 📅 Appends to existing dates if tabs were already saved today
- ✅ Automatically closes unpinned tabs after saving
- 👀 View saved tabs for any date
- ♻️ Restore saved tabs from any date
- 📝 Lists all dates that have saved tabs

## Installation

### Method 1: Manual Installation

1. Download `ChromeTabSaver.spoon`
2. Copy to `~/.config/hammerspoon/Spoons/` (or `~/.hammerspoon/Spoons/`)
3. Add to your `init.lua`:

```lua
hs.loadSpoon("ChromeTabSaver")

-- Bind hotkeys
spoon.ChromeTabSaver:bindHotkeys({
    save = {{"cmd", "alt", "ctrl"}, "S"},      -- Save and close unpinned tabs
    view = {{"cmd", "alt", "ctrl"}, "V"},      -- View today's saved tabs
    restore = {{"cmd", "alt", "ctrl"}, "R"}    -- Restore today's saved tabs
})
```

### Method 2: Direct install to Spoons directory

```bash
# If using ~/.config/hammerspoon
cp -r ChromeTabSaver.spoon ~/.config/hammerspoon/Spoons/

# Or if using ~/.hammerspoon
cp -r ChromeTabSaver.spoon ~/.hammerspoon/Spoons/
```

## Configuration

On first use, the Spoon will ask you how many pinned tabs you have. This ensures pinned tabs are never saved or closed.

To reconfigure later, delete the config file:
```bash
rm ~/.config/hammerspoon/chrome_tab_saver_config.json
```

## Usage

### Hotkeys (after binding)

- **Save and Close**: `Cmd + Alt + Ctrl + S` - Saves all unpinned tabs and closes them
- **View Today's Tabs**: `Cmd + Alt + Ctrl + V` - Shows tabs saved today
- **Restore Today's Tabs**: `Cmd + Alt + Ctrl + R` - Reopens tabs saved today

### Programmatic Usage

```lua
-- Save and close unpinned tabs
spoon.ChromeTabSaver:saveAndCloseUnpinnedTabs()

-- View tabs for a specific date
spoon.ChromeTabSaver:viewSavedTabs("2025-10-28")

-- Restore tabs from a specific date
spoon.ChromeTabSaver:restoreSavedTabs("2025-10-28")

-- List all dates with saved tabs
local dates = spoon.ChromeTabSaver:listSavedDates()
for _, date in ipairs(dates) do
    print(date)
end
```

### Custom Storage Path

```lua
hs.loadSpoon("ChromeTabSaver")

-- Change where tabs are saved
spoon.ChromeTabSaver.savedTabsPath = os.getenv("HOME") .. "/Documents/chrome_tabs.json"

spoon.ChromeTabSaver:bindHotkeys({...})
```

## Data Format

Tabs are saved to `~/.config/hammerspoon/saved_tabs.json` in this format:

```json
{
  "2025-10-28": [
    {
      "url": "https://example.com/article",
      "title": "Example Article - Example Site",
      "savedAt": "2025-10-28 14:30:15",
      "originalIndex": 3
    },
    {
      "url": "https://github.com/trending",
      "title": "Trending - GitHub",
      "savedAt": "2025-10-28 14:30:15",
      "originalIndex": 4
    }
  ],
  "2025-10-29": [
    ...
  ]
}
```

## How It Works

1. **Detection**: Gets all tabs from the front Chrome window using AppleScript
2. **Filtering**: Skips the first N tabs (where N is your configured pinned tab count)
3. **Saving**: Saves unpinned tab URLs and titles to JSON, appending to today's date
4. **Closing**: Closes all unpinned tabs (in reverse order to maintain indices)

## Limitations

- Only works with Google Chrome (not Chromium, Brave, etc.)
- Requires Chrome to be the frontmost application
- AppleScript doesn't expose Chrome's pinned tab status directly, so you must configure the count manually
- Pinned tabs must be at the start of the tab bar (Chrome's default behavior)

## Troubleshooting

**"Error accessing Chrome"**: Make sure Chrome is running and has at least one window open.

**Wrong tabs being closed**: Check your pinned tab count is correct. Delete the config file to reconfigure:
```bash
rm ~/.config/hammerspoon/chrome_tab_saver_config.json
```

**Tabs not saving**: Check the Hammerspoon console for errors: `Cmd + Option + Ctrl + Shift + C`

**Permission denied**: Grant Hammerspoon accessibility permissions in System Preferences → Security & Privacy → Accessibility

## License

MIT

## Author

Created with assistance from Claude (Anthropic)
