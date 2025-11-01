hs.loadSpoon 'EmmyLua'
hs.loadSpoon 'ReloadConfiguration'
spoon.ReloadConfiguration:start()

hs.loadSpoon 'WindowLayoutMode'
spoon.WindowLayoutMode:init()

hs.loadSpoon 'ChromeTabSaver'

spoon.ChromeTabSaver:addToAllowlist 'calendar.google.com'
spoon.ChromeTabSaver:addToAllowlist 'mail.google.com'
spoon.ChromeTabSaver:addToAllowlist 'app.slack.com'

spoon.ChromeTabSaver:bindHotkeys {
  save = { { 'cmd', 'alt', 'ctrl' }, 'S' },
  view = { { 'cmd', 'alt', 'ctrl' }, 'V' },
  restore = { { 'cmd', 'alt', 'ctrl' }, 'R' },
}
