local colors = require("colors")
local settings = require("settings")
local app_icons = require("icon_map")

local front_app = sbar.add("item", "front_app", {
  position = "left",
  icon = {
    font = {
      family = settings.font.app_font,
      style = settings.font.style.regular,
      size = 16.0,
    },
    color = colors.text,
  },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style.semibold,
      size = settings.item_label_size,
    },
    color = colors.text,
    y_offset = -1,
  },
  updates = true,
})

front_app:subscribe("front_app_switched", function(env)
  local app_name = env.INFO or ""
  local icon = app_icons[app_name] or ":default:"
  front_app:set({
    icon = { string = icon },
    label = { string = app_name },
  })
  -- Bounce animation on app switch
  sbar.animate("tanh", 15, function()
    front_app:set({ label = { y_offset = 4 } })
  end)
  sbar.animate("tanh", 15, function()
    front_app:set({ label = { y_offset = 0 } })
  end)
end)
