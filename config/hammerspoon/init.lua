hs.loadSpoon 'EmmyLua'
hs.loadSpoon 'ReloadConfiguration'
spoon.ReloadConfiguration:start()

hs.loadSpoon 'WindowLayoutMode'
spoon.WindowLayoutMode:init()

hs.loadSpoon 'ChromeTabSaver'

spoon.ChromeTabSaver:bindHotkeys {
  save = { { 'cmd', 'alt', 'ctrl' }, 'S' },
  view = { { 'cmd', 'alt', 'ctrl' }, 'V' },
  restore = { { 'cmd', 'alt', 'ctrl' }, 'R' },
}
