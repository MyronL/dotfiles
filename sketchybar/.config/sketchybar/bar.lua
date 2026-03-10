local colors = require("colors")
local settings = require("settings")

-- Bar appearance
sbar.bar({
  topmost = "window",
  height = settings.bar_height + 3,
  color = colors.bar_bg,
  padding_right = 17,
  padding_left = 17,
  margin = 0,
  corner_radius = 0,
  notch_width = 200,
  display = "all",
  blur_radius = 30,
  shadow = false,
  sticky = true,
  y_offset = 0,
})
