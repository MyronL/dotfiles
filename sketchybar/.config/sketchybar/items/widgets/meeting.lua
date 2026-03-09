local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local meeting = sbar.add("item", "widgets.meeting", {
  position = "right",
  update_freq = settings.update_freq.meeting,
  icon = {
    string = icons.meeting,
    font = {
      family = settings.font.text,
      style = settings.font.style.bold,
      size = 17.0,
    },
    color = colors.red,
  },
  label = { drawing = false },
  drawing = false,
})

local detected_app = nil

local function update_meeting()
  sbar.exec("pgrep -x zoom.us", function(zoom_result)
    if zoom_result and zoom_result:match("%d") then
      detected_app = "zoom.us"
      meeting:set({ drawing = true })
      return
    end
    sbar.exec("pgrep -x 'Microsoft Teams'", function(teams_result)
      if teams_result and teams_result:match("%d") then
        detected_app = "Microsoft Teams"
        meeting:set({ drawing = true })
      else
        detected_app = nil
        meeting:set({ drawing = false })
      end
    end)
  end)
end

meeting:subscribe({ "routine", "forced" }, update_meeting)

meeting:subscribe("mouse.clicked", function()
  if detected_app then
    sbar.exec('open -a "' .. detected_app .. '"')
  end
end)
