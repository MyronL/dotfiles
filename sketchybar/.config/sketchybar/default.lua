local colors = require("colors")
local settings = require("settings")

-- Default item properties applied to all items
sbar.default({
  updates = "when_shown",
  y_offset = 1,
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style.bold,
      size = settings.item_icon_size,
    },
    color = colors.text,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  label = {
    font = {
      family = settings.font.text,
      style = settings.font.style.bold,
      size = settings.item_label_size,
    },
    color = colors.text,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  padding_left = 3,
  padding_right = 3,
  background = {
    height = 26,
    corner_radius = 9,
    border_width = 0,
    color = colors.transparent,
    padding_left = settings.paddings,
    padding_right = settings.paddings,
  },
  popup = {
    background = {
      border_width = 2,
      corner_radius = 9,
      border_color = colors.surface1,
      color = colors.base,
    },
    blur_radius = 20,
  },
})
