local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local media = sbar.add("item", "media", {
  position = "right",
  update_freq = settings.update_freq.media,
  icon = {
    string = icons.media.paused,
    font = {
      family = settings.font.text,
      style = settings.font.style.bold,
      size = 17.0,
    },
    color = colors.green,
  },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style.bold,
      size = settings.item_label_size,
    },
    max_chars = 30,
    scroll_duration = 500,
  },
  drawing = false,
  updates = "on",
  scroll_texts = true,
})

-- Popup: playback controls
local popup_font = {
  family = settings.font.text,
  style = settings.font.style.bold,
  size = 18.0,
}

local media_prev = sbar.add("item", "media.prev", {
  position = "popup.media",
  icon = { string = icons.media.back, font = popup_font, color = colors.text },
  label = { drawing = false },
  background = { color = colors.transparent },
})

local media_playpause = sbar.add("item", "media.playpause", {
  position = "popup.media",
  icon = { string = icons.media.playing, font = popup_font, color = colors.green },
  label = { drawing = false },
  background = { color = colors.transparent },
})

local media_next = sbar.add("item", "media.next", {
  position = "popup.media",
  icon = { string = icons.media.forward, font = popup_font, color = colors.text },
  label = { drawing = false },
  background = { color = colors.transparent },
})

-- Detect which player is active
local active_player = "Spotify"

local function get_player_cmd(action)
  if active_player == "Music" then
    return 'osascript -e \'tell application "Music" to ' .. action .. "'"
  end
  return 'osascript -e \'tell application "Spotify" to ' .. action .. "'"
end

media_prev:subscribe("mouse.clicked", function()
  sbar.exec(get_player_cmd("previous track"))
end)

media_playpause:subscribe("mouse.clicked", function()
  sbar.exec(get_player_cmd("playpause"))
end)

media_next:subscribe("mouse.clicked", function()
  sbar.exec(get_player_cmd("next track"))
end)

local prev_track = ""
local popup_visible = false

local media_cmd = [[osascript <<'APPLESCRIPT'
tell application "System Events"
  set spotifyRunning to (name of processes) contains "Spotify"
  set musicRunning to (name of processes) contains "Music"
end tell

if spotifyRunning then
  tell application "Spotify"
    if player state is playing then
      return "playing" & "|" & artist of current track & " - " & name of current track & "|Spotify"
    else if player state is paused then
      return "paused" & "|" & artist of current track & " - " & name of current track & "|Spotify"
    end if
  end tell
else if musicRunning then
  tell application "Music"
    if player state is playing then
      return "playing" & "|" & artist of current track & " - " & name of current track & "|Music"
    else if player state is paused then
      return "paused" & "|" & artist of current track & " - " & name of current track & "|Music"
    end if
  end tell
end if
return "stopped||"
APPLESCRIPT]]

media:subscribe({ "routine" }, function()
  sbar.exec(media_cmd, function(result)
    local state, info, player = result:match("^(%w+)|(.-)|(.*)")
    if player and player ~= "" then
      active_player = player:match("^%s*(.-)%s*$")
    end
    if state == "playing" then
      media:set({
        drawing = true,
        icon = { string = icons.media.playing, color = colors.green },
        label = { string = info },
      })
      media_playpause:set({ icon = { string = icons.media.paused, color = colors.green } })
      -- Slide in animation on track change
      if info ~= prev_track then
        sbar.animate("tanh", 15, function()
          media:set({ label = { y_offset = 5 } })
        end)
        sbar.animate("tanh", 15, function()
          media:set({ label = { y_offset = 0 } })
        end)
        prev_track = info
      end
    elseif state == "paused" and info and info ~= "" then
      media:set({
        drawing = true,
        icon = { string = icons.media.paused, color = colors.overlay1 },
        label = { string = info },
      })
      media_playpause:set({ icon = { string = icons.media.playing, color = colors.overlay1 } })
      prev_track = info
    else
      media:set({ drawing = false, popup = { drawing = false } })
      popup_visible = false
    end
  end)
end)

media:subscribe("mouse.clicked", function()
  popup_visible = not popup_visible
  media:set({ popup = { drawing = popup_visible } })
end)
