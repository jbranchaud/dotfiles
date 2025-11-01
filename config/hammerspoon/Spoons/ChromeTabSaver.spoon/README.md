# ChromeTabSaver.spoon

Save and close unpinned Chrome tabs to a JSON file organized by date, and restore them later.

## Features

- 💾 Save all unpinned tabs from your front Chrome window
- 🗂️ Organize saved tabs by date
- 🔄 Restore tabs from any date
- 👁️ View saved tabs for a specific date
- ⚙️ Configurable data directory location
- 🎯 Preserve pinned tabs (never saved or closed)
- 🛡️ URL allowlist to protect specific sites (like Gmail, Calendar, etc.)

## Installation

1. Clone or copy this Spoon to `~/.hammerspoon/Spoons/ChromeTabSaver.spoon/`
2. Add to your `~/.hammerspoon/init.lua`:

```lua
hs.loadSpoon("ChromeTabSaver")

spoon.ChromeTabSaver:bindHotkeys({
    save = {{"cmd", "alt", "ctrl"}, "S"},
    view = {{"cmd", "alt", "ctrl"}, "V"},
    restore = {{"cmd", "alt", "ctrl"}, "R"}
})
```

3. Reload Hammerspoon configuration

## Configuration

### Default Location

By default, saved tabs and configuration are stored in:
```
~/.local/share/hammerspoon/ChromeTabSaver/
├── saved_tabs.json
└── config.json
```

### Custom Location

You can configure a custom data directory:

```lua
hs.loadSpoon("ChromeTabSaver")

-- Option 1: Set a custom data directory
spoon.ChromeTabSaver:configure({
    dataDir = os.getenv('HOME') .. '/Documents/ChromeTabSaver'
})

-- Option 2: Set individual file paths
spoon.ChromeTabSaver:configure({
    savedTabsPath = os.getenv('HOME') .. '/custom/path/tabs.json',
    configPath = os.getenv('HOME') .. '/custom/path/config.json'
})

spoon.ChromeTabSaver:bindHotkeys({
    save = {{"cmd", "alt", "ctrl"}, "S"},
    view = {{"cmd", "alt", "ctrl"}, "V"},
    restore = {{"cmd", "alt", "ctrl"}, "R"}
})
```

## Pinned Tabs & URL Allowlist

### Pinned Tabs

On first run, you'll be prompted to enter the number of pinned tabs in your Chrome window. Pinned tabs are never saved or closed. You can change this later by deleting the `config.json` file and running the save command again.

### URL Allowlist

The allowlist lets you specify URL patterns for tabs that should never be saved or closed, regardless of whether they're pinned. This is perfect for sites like Gmail, Calendar, or any app you always want to keep open.

#### Managing the Allowlist

You can manage the allowlist programmatically or by editing `config.json`:

**Programmatic Management:**

```lua
-- Add a URL pattern to the allowlist
spoon.ChromeTabSaver:addToAllowlist("gmail.com")
spoon.ChromeTabSaver:addToAllowlist("calendar.google.com")
spoon.ChromeTabSaver:addToAllowlist("github.com")

-- Remove a pattern
spoon.ChromeTabSaver:removeFromAllowlist("github.com")

-- View current allowlist
local allowlist = spoon.ChromeTabSaver:getURLAllowlist()
for _, pattern in ipairs(allowlist) do
    print(pattern)
end
```

**Manual Configuration:**

Edit `~/.local/share/hammerspoon/ChromeTabSaver/config.json`:

```json
{
  "pinnedTabCount": 3,
  "urlAllowlist": [
    "gmail.com",
    "calendar.google.com",
    "github.com/notifications"
  ]
}
```

#### How URL Matching Works

The allowlist uses simple substring matching (case-insensitive):
- `gmail.com` matches `https://mail.google.com/mail/u/0/#inbox`
- `github.com` matches any GitHub URL
- `localhost` matches `http://localhost:3000`

When you save tabs, allowlisted tabs will:
- ✅ Stay open in Chrome
- ✅ Not be added to the saved tabs file
- ✅ Be counted in the confirmation message

## Usage

### Save Tabs (⌘⌃⌥S)
Saves all unpinned tabs from your front Chrome window and closes them. Pinned tabs and allowlisted URLs remain untouched.

### View Tabs (⌘⌃⌥V)
Shows a list of tabs saved today (or a specific date).

### Restore Tabs (⌘⌃⌥R)
Reopens all tabs saved today (or a specific date) in Chrome.

## Data Format

Tabs are saved in JSON format, organized by date:

```json
{
  "2025-11-01": [
    {
      "url": "https://example.com",
      "title": "Example Domain",
      "savedAt": "2025-11-01 14:30:00",
      "originalIndex": 3
    }
  ]
}
```

## License

MIT License - See LICENSE file for details
