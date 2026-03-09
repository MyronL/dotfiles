local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local apple = sbar.add("item", "apple", {
  position = "left",
  icon = {
    string = icons.apple,
    font = {
      family = settings.font.text,
      style = settings.font.style.bold,
      size = 18.0,
    },
    color = colors.text,
  },
  label = { drawing = false },
  click_script = "open x-apple.systempreferences:",
})
