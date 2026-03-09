local colors = require("colors")

local separator_count = 0

local function create_separator(position)
  separator_count = separator_count + 1
  return sbar.add("item", "separator." .. separator_count, {
    position = position or "left",
    icon = {
      string = "|",
      color = colors.overlay2,
      font = {
        size = 24.0,
      },
      y_offset = -2,
      padding_left = 6,
      padding_right = 6,
    },
    label = { drawing = false },
    background = { drawing = false },
  })
end

return create_separator
