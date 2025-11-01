--- === ChromeTabSaver ===
---
--- Save and close unpinned Chrome tabs to a JSON file organized by date
---
--- Download: https://github.com/jbranchaud/dotfiles
---
--- Usage:
--- ```
--- hs.loadSpoon("ChromeTabSaver")
---
--- -- Optional: Configure custom data directory (defaults to ~/.local/share/hammerspoon/ChromeTabSaver/)
--- -- spoon.ChromeTabSaver:configure({
--- --     dataDir = os.getenv('HOME') .. '/Documents/ChromeTabSaver'
--- -- })
---
--- spoon.ChromeTabSaver:bindHotkeys({
---     save = {{"cmd", "alt", "ctrl"}, "S"},
---     view = {{"cmd", "alt", "ctrl"}, "V"},
---     restore = {{"cmd", "alt", "ctrl"}, "R"}
--- })
--- ```

local obj = {}
obj.__index = obj

-- Metadata
obj.name = 'ChromeTabSaver'
obj.version = '0.6'
obj.author = 'Josh Branchaud'
obj.homepage = 'https://github.com/jbranchaud/dotfiles'
obj.license = 'MIT - https://opensource.org/licenses/MIT'

-- Default Configuration (XDG Base Directory standard)
local defaultDataDir = os.getenv 'HOME' .. '/.local/share/hammerspoon/ChromeTabSaver'
obj.savedTabsPath = defaultDataDir .. '/saved_tabs.json'
obj.configPath = defaultDataDir .. '/config.json'
obj.logger = hs.logger.new 'ChromeTabSaver'

--- ChromeTabSaver:init()
--- Method
--- Initializes the Spoon
function obj:init()
  self.logger.i 'Initializing ChromeTabSaver'
  return self
end

--- ChromeTabSaver:configure(config)
--- Method
--- Configures custom paths for saved tabs and config files
---
--- Parameters:
---  * config - A table with optional keys:
---   * savedTabsPath - Full path to saved tabs JSON file
---   * configPath - Full path to config JSON file
---   * dataDir - Directory path (will set both savedTabsPath and configPath within it)
---
--- Returns:
---  * The ChromeTabSaver object for method chaining
---
--- Example:
--- ```
--- spoon.ChromeTabSaver:configure({
---     dataDir = os.getenv('HOME') .. '/Documents/ChromeTabSaver'
--- })
--- ```
---
--- Or for full control:
--- ```
--- spoon.ChromeTabSaver:configure({
---     savedTabsPath = os.getenv('HOME') .. '/custom/path/tabs.json',
---     configPath = os.getenv('HOME') .. '/custom/path/config.json'
--- })
--- ```
function obj:configure(config)
  if not config then
    return self
  end

  if config.dataDir then
    self.savedTabsPath = config.dataDir .. '/saved_tabs.json'
    self.configPath = config.dataDir .. '/config.json'
    self.logger.i('Configured data directory: ' .. config.dataDir)
  end

  if config.savedTabsPath then
    self.savedTabsPath = config.savedTabsPath
    self.logger.i('Configured saved tabs path: ' .. config.savedTabsPath)
  end

  if config.configPath then
    self.configPath = config.configPath
    self.logger.i('Configured config path: ' .. config.configPath)
  end

  return self
end

--- ChromeTabSaver:ensureDataDirectoryExists()
--- Method
--- Creates the data directory if it doesn't exist
---
--- Returns:
---  * true if directory exists or was created, false otherwise
function obj:ensureDataDirectoryExists()
  -- Extract directory from savedTabsPath
  local dataDir = self.savedTabsPath:match '(.*/)'
  if not dataDir then
    self.logger.e('Could not determine data directory from path: ' .. self.savedTabsPath)
    return false
  end

  -- Remove trailing slash
  dataDir = dataDir:sub(1, -2)

  -- Check if directory exists using hs.execute
  -- hs.execute returns: output, status, type, rc
  local output, status, type, rc = hs.execute('test -d "' .. dataDir .. '"')

  if status then
    -- Directory exists
    return true
  end

  -- Directory doesn't exist, create it
  self.logger.i('Creating data directory: ' .. dataDir)
  local createOutput, createStatus, createType, createRc = hs.execute('mkdir -p "' .. dataDir .. '"')

  if createStatus then
    self.logger.i('Successfully created data directory: ' .. dataDir)
    return true
  else
    self.logger.e('Failed to create data directory: ' .. dataDir)
    self.logger.e('mkdir output: ' .. tostring(createOutput))
    self.logger.e('mkdir rc: ' .. tostring(createRc))
    return false
  end
end

--- ChromeTabSaver:loadConfig()
--- Method
--- Loads or creates the configuration file
---
--- Returns:
---  * A table with configuration values
function obj:loadConfig()
  local config = {}
  local configFile = io.open(self.configPath, 'r')

  if configFile then
    local configContent = configFile:read '*all'
    configFile:close()
    if configContent and configContent ~= '' then
      local success, decoded = pcall(hs.json.decode, configContent)
      if success then
        config = decoded or {}
      end
    end
  end

  return config
end

--- ChromeTabSaver:saveConfig(config)
--- Method
--- Saves the configuration file
---
--- Parameters:
---  * config - A table with configuration values
function obj:saveConfig(config)
  if not self:ensureDataDirectoryExists() then
    self.logger.e 'Cannot save config: data directory does not exist'
    return
  end

  local configOut = io.open(self.configPath, 'w')
  if configOut then
    configOut:write(hs.json.encode(config, true))
    configOut:close()
    self.logger.i 'Configuration saved'
  else
    self.logger.e 'Failed to save configuration'
  end
end

--- ChromeTabSaver:isURLAllowlisted(url)
--- Method
--- Checks if a URL matches any pattern in the allowlist
---
--- Parameters:
---  * url - The URL to check
---
--- Returns:
---  * true if the URL is allowlisted, false otherwise
function obj:isURLAllowlisted(url)
  if not url then
    return false
  end

  local config = self:loadConfig()
  local allowlist = config.urlAllowlist or {}

  -- If allowlist is empty, nothing is allowlisted
  if #allowlist == 0 then
    return false
  end

  -- Check each pattern in the allowlist
  for _, pattern in ipairs(allowlist) do
    -- Simple substring match (case-insensitive)
    if url:lower():find(pattern:lower(), 1, true) then
      self.logger.d('URL matched allowlist pattern "' .. pattern .. '": ' .. url)
      return true
    end
  end

  return false
end

--- ChromeTabSaver:getURLAllowlist()
--- Method
--- Gets the current URL allowlist
---
--- Returns:
---  * Array of URL patterns
function obj:getURLAllowlist()
  local config = self:loadConfig()
  return config.urlAllowlist or {}
end

--- ChromeTabSaver:addToAllowlist(pattern)
--- Method
--- Adds a URL pattern to the allowlist
---
--- Parameters:
---  * pattern - URL pattern to add (e.g., "gmail.com", "github.com")
---
--- Returns:
---  * true if added successfully, false otherwise
function obj:addToAllowlist(pattern)
  if not pattern or pattern == '' then
    return false
  end

  local config = self:loadConfig()
  if not config.urlAllowlist then
    config.urlAllowlist = {}
  end

  -- Check if pattern already exists
  for _, existingPattern in ipairs(config.urlAllowlist) do
    if existingPattern == pattern then
      self.logger.i('Pattern already in allowlist: ' .. pattern)
      return false
    end
  end

  table.insert(config.urlAllowlist, pattern)
  self:saveConfig(config)
  self.logger.i('Added to allowlist: ' .. pattern)
  return true
end

--- ChromeTabSaver:removeFromAllowlist(pattern)
--- Method
--- Removes a URL pattern from the allowlist
---
--- Parameters:
---  * pattern - URL pattern to remove
---
--- Returns:
---  * true if removed successfully, false if not found
function obj:removeFromAllowlist(pattern)
  local config = self:loadConfig()
  if not config.urlAllowlist then
    return false
  end

  for i, existingPattern in ipairs(config.urlAllowlist) do
    if existingPattern == pattern then
      table.remove(config.urlAllowlist, i)
      self:saveConfig(config)
      self.logger.i('Removed from allowlist: ' .. pattern)
      return true
    end
  end

  return false
end

--- ChromeTabSaver:getPinnedCount()
--- Method
--- Gets the number of pinned tabs, asking user if not configured
---
--- Returns:
---  * Number of pinned tabs, or nil if cancelled
function obj:getPinnedCount()
  local config = self:loadConfig()

  if config.pinnedTabCount then
    return config.pinnedTabCount
  end

  -- First run: ask user for pinned tab count
  local button, count = hs.dialog.textPrompt(
    'Chrome Tab Saver Setup',
    'How many pinned tabs do you have in your front Chrome window?\n\n'
      .. '(Pinned tabs will not be saved or closed)\n\n'
      .. 'You can change this later by deleting:\n'
      .. self.configPath,
    '0',
    'OK',
    'Cancel'
  )

  if button == 'OK' and count then
    local pinnedCount = tonumber(count) or 0
    config.pinnedTabCount = pinnedCount
    self:saveConfig(config)
    return pinnedCount
  end

  return nil
end

--- ChromeTabSaver:loadSavedTabs()
--- Method
--- Loads saved tabs from JSON file
---
--- Returns:
---  * A table with saved tabs organized by date
function obj:loadSavedTabs()
  local savedTabs = {}
  local file = io.open(self.savedTabsPath, 'r')

  if file then
    local content = file:read '*all'
    file:close()
    if content and content ~= '' then
      local success, decoded = pcall(hs.json.decode, content)
      if success and decoded then
        savedTabs = decoded
      end
    end
  end

  return savedTabs
end

--- ChromeTabSaver:saveTabs(savedTabs)
--- Method
--- Saves tabs to JSON file
---
--- Parameters:
---  * savedTabs - A table with saved tabs organized by date
---
--- Returns:
---  * true if successful, false otherwise
function obj:saveTabs(savedTabs)
  if not self:ensureDataDirectoryExists() then
    self.logger.e 'Cannot save tabs: data directory does not exist'
    return false
  end

  local outFile = io.open(self.savedTabsPath, 'w')
  if outFile then
    outFile:write(hs.json.encode(savedTabs, true))
    outFile:close()
    return true
  else
    self.logger.e 'Failed to write saved tabs to file'
    return false
  end
end

--- ChromeTabSaver:saveAndCloseUnpinnedTabs()
--- Method
--- Saves unpinned Chrome tabs to JSON file and closes them
---
--- Returns:
---  * Number of tabs saved, or nil if error
function obj:saveAndCloseUnpinnedTabs()
  local currentDate = os.date '%Y-%m-%d'

  -- Get pinned tab count
  local pinnedCount = self:getPinnedCount()
  if not pinnedCount then
    return nil
  end

  -- Load existing saved tabs
  local savedTabs = self:loadSavedTabs()

  -- Initialize array for current date if it doesn't exist
  if not savedTabs[currentDate] then
    savedTabs[currentDate] = {}
  end

  -- Get all tabs from Chrome
  local script = [[
        tell application "Google Chrome"
            if (count of windows) = 0 then
                return "NO_WINDOWS"
            end if

            set frontWindow to front window
            set tabsList to {}

            repeat with i from 1 to count of tabs of frontWindow
                set currentTab to tab i of frontWindow
                set tabRecord to {|tabURL|:(URL of currentTab), |tabTitle|:(title of currentTab), |tabIndex|:i}
                set end of tabsList to tabRecord
            end repeat

            return {|tabs|:tabsList, |tabCount|:(count of tabs of frontWindow)}
        end tell
    ]]

  local ok, result = hs.osascript.applescript(script)

  if not ok then
    hs.notify
      .new({
        title = 'Chrome Tab Saver',
        informativeText = 'Error accessing Chrome: ' .. tostring(result),
      })
      :send()
    self.logger.e('Error accessing Chrome: ' .. tostring(result))
    return nil
  end

  if result == 'NO_WINDOWS' then
    hs.notify
      .new({
        title = 'Chrome Tab Saver',
        informativeText = 'No Chrome windows open',
      })
      :send()
    return nil
  end

  -- AppleScript returns native data structures (converted to Lua tables by hs.osascript)
  -- Validate result structure
  if type(result) ~= 'table' or not result.tabs or not result.tabCount then
    hs.notify
      .new({
        title = 'Chrome Tab Saver',
        informativeText = 'Error: Unexpected data format from Chrome',
      })
      :send()
    self.logger.e('Unexpected result format: ' .. hs.inspect(result))
    return nil
  end

  local tabsData = result.tabs
  local totalTabs = result.tabCount

  -- Process unpinned tabs and filter out allowlisted URLs
  local currentTimestamp = os.date '%Y-%m-%d %H:%M:%S'
  local tabsToSave = {}
  local tabsToClose = {} -- Track tab indices to close
  local savedCount = 0
  local allowlistedCount = 0

  for i, tabInfo in ipairs(tabsData) do
    if i > pinnedCount then
      -- Check if URL is allowlisted
      if self:isURLAllowlisted(tabInfo.tabURL) then
        allowlistedCount = allowlistedCount + 1
        self.logger.i('Skipping allowlisted tab: ' .. tabInfo.tabTitle)
      else
        -- Not allowlisted, so save and mark for closing
        table.insert(tabsToSave, {
          url = tabInfo.tabURL,
          title = tabInfo.tabTitle,
          originalIndex = i,
        })
        table.insert(tabsToClose, i)
        savedCount = savedCount + 1
      end
    end
  end

  if savedCount == 0 then
    local message = 'No tabs to save'
    if allowlistedCount > 0 then
      message = message
        .. string.format('\n(%d allowlisted tab%s kept open)', allowlistedCount, allowlistedCount == 1 and '' or 's')
    end
    hs.notify
      .new({
        title = 'Chrome Tab Saver',
        informativeText = message,
      })
      :send()
    return 0
  end

  -- Confirm with user before saving and closing
  local confirmMessage = string.format(
    'Save and close %d tab%s?\n\n' .. 'Pinned tabs (%d) will be kept open.\n',
    savedCount,
    savedCount == 1 and '' or 's',
    pinnedCount
  )

  if allowlistedCount > 0 then
    confirmMessage = confirmMessage .. string.format('Allowlisted tabs (%d) will be kept open.\n', allowlistedCount)
  end

  confirmMessage = confirmMessage .. string.format('Tabs will be saved to: %s', self.savedTabsPath)

  local button = hs.dialog.blockAlert('Chrome Tab Saver - Confirm', confirmMessage, 'Save & Close', 'Cancel')

  if button == 'Cancel' then
    self.logger.i 'User cancelled save operation'
    return 0
  end

  -- Add the timestamped group to the date's array
  table.insert(savedTabs[currentDate], {
    timestamp = currentTimestamp,
    tabs = tabsToSave,
  })

  -- Save to file
  if not self:saveTabs(savedTabs) then
    hs.notify
      .new({
        title = 'Chrome Tab Saver',
        informativeText = 'Error: Could not write to file',
      })
      :send()
    return nil
  end

  -- Close the tabs (in reverse order to maintain indices)
  -- Build AppleScript to close specific tab indices
  local closeScript = [[
        tell application "Google Chrome"
            set frontWindow to front window
            set indicesToClose to {]]

  -- Sort indices in reverse order
  table.sort(tabsToClose, function(a, b)
    return a > b
  end)

  -- Build the list of indices
  for i, idx in ipairs(tabsToClose) do
    if i > 1 then
      closeScript = closeScript .. ', '
    end
    closeScript = closeScript .. tostring(idx)
  end

  closeScript = closeScript
    .. [[}

            -- Close in reverse order to maintain correct indices
            repeat with i in indicesToClose
                try
                    close tab i of frontWindow
                end try
            end repeat
        end tell
    ]]

  local closeOk, closeResult = hs.osascript.applescript(closeScript)

  if closeOk then
    hs.notify
      .new({
        title = 'Chrome Tab Saver',
        informativeText = string.format('✓ Saved and closed %d tabs', savedCount),
        subTitle = string.format('Saved to: %s', self.savedTabsPath),
      })
      :send()
    self.logger.i(string.format('Saved and closed %d tabs', savedCount))
  else
    hs.notify
      .new({
        title = 'Chrome Tab Saver',
        informativeText = string.format('Saved %d tabs but error closing them', savedCount),
      })
      :send()
    self.logger.e('Error closing tabs: ' .. tostring(closeResult))
  end

  return savedCount
end

--- ChromeTabSaver:viewSavedTabs([date])
--- Method
--- View saved tabs for a specific date
---
--- Parameters:
---  * date - Optional date string (YYYY-MM-DD), defaults to today
function obj:viewSavedTabs(date)
  local savedTabs = self:loadSavedTabs()
  date = date or os.date '%Y-%m-%d'

  local groupsForDate = savedTabs[date]

  if not groupsForDate or #groupsForDate == 0 then
    hs.notify
      .new({
        title = 'Chrome Tab Saver',
        informativeText = 'No tabs saved for ' .. date,
      })
      :send()
    return
  end

  -- Build message showing all timestamped groups
  local totalTabs = 0
  for _, group in ipairs(groupsForDate) do
    if group.tabs then
      totalTabs = totalTabs + #group.tabs
    end
  end

  local message = string.format('Found %d save group(s) with %d total tabs on %s:\n\n', #groupsForDate, totalTabs, date)

  for groupIdx, group in ipairs(groupsForDate) do
    -- Handle both old format (flat tabs) and new format (timestamped groups)
    local timestamp = group.timestamp or 'Unknown time'
    local tabs = group.tabs or { group } -- Backward compatibility

    message = message .. string.format('═══ Group %d: %s (%d tabs) ═══\n', groupIdx, timestamp, #tabs)

    for i, tab in ipairs(tabs) do
      local title = tab.title or 'Untitled'
      if #title > 50 then
        title = title:sub(1, 47) .. '...'
      end
      message = message .. string.format('  %d. %s\n     %s\n', i, title, tab.url)

      -- Limit display per group
      if i >= 10 and #tabs > 10 then
        message = message .. string.format('     ... and %d more tabs in this group\n', #tabs - 10)
        break
      end
    end
    message = message .. '\n'
  end

  hs.dialog.blockAlert('Saved Tabs - ' .. date, message, 'OK')
end

--- ChromeTabSaver:restoreSavedTabs([date])
--- Method
--- Restore saved tabs from a specific date, or show a picker of recent saves
---
--- Parameters:
---  * date - Optional date string (YYYY-MM-DD). If not provided, shows a picker
---           of the last 20 save sessions across all dates
---
--- Returns:
---  * Number of tabs restored
function obj:restoreSavedTabs(date)
  local savedTabs = self:loadSavedTabs()

  -- If date is specified, use the old behavior for that specific date
  if date then
    local groupsForDate = savedTabs[date]

    if not groupsForDate or #groupsForDate == 0 then
      hs.notify
        .new({
          title = 'Chrome Tab Saver',
          informativeText = 'No tabs saved for ' .. date,
        })
        :send()
      return 0
    end

    return self:restoreGroupsFromDate(groupsForDate, date)
  end

  -- No date specified: show picker of recent save sessions across all dates
  local allGroups = {}

  -- Collect all groups with their metadata
  for dateKey, groups in pairs(savedTabs) do
    for _, group in ipairs(groups) do
      local timestamp = group.timestamp or 'Unknown time'
      local tabCount = group.tabs and #group.tabs or 1

      table.insert(allGroups, {
        date = dateKey,
        timestamp = timestamp,
        tabCount = tabCount,
        group = group,
      })
    end
  end

  if #allGroups == 0 then
    hs.notify
      .new({
        title = 'Chrome Tab Saver',
        informativeText = 'No saved tabs found',
      })
      :send()
    return 0
  end

  -- Sort by timestamp (most recent first)
  table.sort(allGroups, function(a, b)
    -- Compare timestamps as strings (YYYY-MM-DD HH:MM:SS format sorts correctly)
    return a.timestamp > b.timestamp
  end)

  -- Limit to last 20 entries
  local maxEntries = 20
  local displayGroups = {}
  for i = 1, math.min(maxEntries, #allGroups) do
    table.insert(displayGroups, allGroups[i])
  end

  -- Build choices for the picker
  local choices = {}
  for i, item in ipairs(displayGroups) do
    -- Format: "timestamp (N tabs)"
    table.insert(choices, {
      text = string.format('%s (%d tabs)', item.timestamp, item.tabCount),
      subText = string.format('Date: %s', item.date),
      index = i,
    })
  end

  -- Create a chooser with callback
  local self_ref = self
  local chooser = hs.chooser.new(function(choice)
    if choice then
      local item = displayGroups[choice.index]
      self_ref:restoreGroup(item.group, item.timestamp)
    end
  end)

  -- Configure and show the chooser
  chooser:choices(choices)
  chooser:placeholderText(string.format('Select a save session to restore (showing last %d)', #displayGroups))
  chooser:rows(math.min(10, #choices))
  chooser:width(30)
  chooser:show()

  -- Return 0 immediately since restoration happens in callback
  return 0
end

--- ChromeTabSaver:restoreGroupsFromDate(groupsForDate, date)
--- Method
--- Restore groups from a specific date (helper method for backward compatibility)
---
--- Parameters:
---  * groupsForDate - Array of groups for a specific date
---  * date - The date string
---
--- Returns:
---  * Number of tabs restored
function obj:restoreGroupsFromDate(groupsForDate, date)
  -- If multiple groups, let user choose which one to restore
  if #groupsForDate == 1 then
    -- Only one group, restore it directly
    return self:restoreGroup(groupsForDate[1], date)
  end

  -- Multiple groups - show chooser
  local choices = {}
  for i, group in ipairs(groupsForDate) do
    local timestamp = group.timestamp or 'Unknown time'
    local tabCount = group.tabs and #group.tabs or 1
    table.insert(choices, {
      text = string.format('%s (%d tabs)', timestamp, tabCount),
      subText = string.format('Group %d', i),
      index = i,
      isAllGroups = false,
    })
  end

  -- Add "All groups" option
  table.insert(choices, {
    text = 'All groups',
    subText = string.format('Restore all %d groups', #groupsForDate),
    index = nil,
    isAllGroups = true,
  })

  -- Create chooser with callback
  local self_ref = self
  local chooser = hs.chooser.new(function(choice)
    if choice then
      if choice.isAllGroups then
        -- Restore all groups
        local restoredCount = 0
        for _, group in ipairs(groupsForDate) do
          restoredCount = restoredCount + self_ref:restoreGroup(group, date)
        end
      else
        -- Restore selected group
        self_ref:restoreGroup(groupsForDate[choice.index], date)
      end
    end
  end)

  chooser:choices(choices)
  chooser:placeholderText 'Select which group to restore'
  chooser:rows(math.min(10, #choices))
  chooser:width(30)
  chooser:show()

  return 0
end

--- ChromeTabSaver:restoreGroup(group, context)
--- Method
--- Restore tabs from a single group
---
--- Parameters:
---  * group - The group containing tabs to restore
---  * context - A string describing the context (timestamp or date) for notification
---
--- Returns:
---  * Number of tabs restored
function obj:restoreGroup(group, context)
  -- Handle both old format (flat tabs) and new format (timestamped groups)
  local tabs = group.tabs or { group }
  local restoredCount = 0

  for _, tab in ipairs(tabs) do
    -- Escape quotes in URL
    local escapedURL = tab.url:gsub('"', '\\"')

    local openScript = string.format(
      [[
          tell application "Google Chrome"
              if (count of windows) = 0 then
                  make new window
              end if
              tell front window
                  make new tab with properties {URL:"%s"}
              end tell
          end tell
      ]],
      escapedURL
    )

    local ok, result = hs.osascript.applescript(openScript)
    if ok then
      restoredCount = restoredCount + 1
    else
      self.logger.e('Error opening tab: ' .. tab.url)
    end
  end

  hs.notify
    .new({
      title = 'Chrome Tab Saver',
      informativeText = string.format('Restored %d tabs from %s', restoredCount, context),
    })
    :send()

  return restoredCount
end

--- ChromeTabSaver:listSavedDates()
--- Method
--- List all dates that have saved tabs
---
--- Returns:
---  * Array of date strings
function obj:listSavedDates()
  local savedTabs = self:loadSavedTabs()
  local dates = {}

  for date, tabs in pairs(savedTabs) do
    if tabs and #tabs > 0 then
      table.insert(dates, date)
    end
  end

  table.sort(dates)
  return dates
end

--- ChromeTabSaver:bindHotkeys(mapping)
--- Method
--- Binds hotkeys for ChromeTabSaver
---
--- Parameters:
---  * mapping - A table containing hotkey modifier/key details for the following items:
---   * save - Save and close unpinned tabs
---   * view - View today's saved tabs
---   * restore - Restore today's saved tabs
---
--- Example:
--- ```
--- spoon.ChromeTabSaver:bindHotkeys({
---     save = {{"cmd", "alt", "ctrl"}, "S"},
---     view = {{"cmd", "alt", "ctrl"}, "V"},
---     restore = {{"cmd", "alt", "ctrl"}, "R"}
--- })
--- ```
function obj:bindHotkeys(mapping)
  local spec = {
    save = hs.fnutils.partial(self.saveAndCloseUnpinnedTabs, self),
    view = hs.fnutils.partial(self.viewSavedTabs, self),
    restore = hs.fnutils.partial(self.restoreSavedTabs, self),
  }
  hs.spoons.bindHotkeysToSpec(spec, mapping)

  return self
end

return obj
