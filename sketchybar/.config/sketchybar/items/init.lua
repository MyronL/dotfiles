local colors = require("colors")
local settings = require("settings")

local function pad(position)
  sbar.add("item", {
    position = position or "left",
    width = settings.group_paddings,
    background = { drawing = false },
    icon = { drawing = false },
    label = { drawing = false },
  })
end

-- Left side
require("items.apple")
pad("left")
pad("left")
require("items.aerospace")
pad("left")
pad("left")
require("items.front_app")

-- Right side (loaded rightmost first)
pad("right")
require("items.calendar")
pad("right")
require("items.widgets")
pad("right")
require("items.widgets.notifications")
require("items.widgets.weather")
require("items.widgets.dnd")
require("items.widgets.meeting")
require("items.widgets.mic")
pad("right")
-- require("items.media")
-- pad("right")

-- Brackets (pill backgrounds behind groups)
local bracket_bg = {
  background = {
    color = colors.with_alpha(colors.blue, 0x28),
    corner_radius = 10,
    height = 26,
  },
}

sbar.add("bracket", { "apple" }, bracket_bg)
sbar.add("bracket", { "/aerospace\\..*/" }, bracket_bg)
sbar.add("bracket", { "front_app" }, bracket_bg)
sbar.add("bracket", { "calendar" }, bracket_bg)
sbar.add("bracket", { "widgets.wifi", "widgets.volume", "widgets.cpu", "widgets.battery" }, bracket_bg)
sbar.add("bracket", { "widgets.notifications", "widgets.weather", "widgets.dnd", "widgets.meeting", "widgets.mic" }, bracket_bg)
-- sbar.add("bracket", { "media" }, bracket_bg)
