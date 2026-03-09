local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local dnd = sbar.add("item", "widgets.dnd", {
  position = "right",
  update_freq = settings.update_freq.dnd,
  icon = {
    string = icons.dnd.off,
    font = {
      family = settings.font.text,
      style = settings.font.style.bold,
      size = 17.0,
    },
    color = colors.overlay1,
  },
  label = { drawing = false },
})

local function update_dnd()
  sbar.exec("cat ~/Library/DoNotDisturb/DB/Assertions.json 2>/dev/null", function(result)
    if result and result:match('"storeAssertionRecords"%s*:%s*%[%s*%{') then
      dnd:set({
        icon = { string = icons.dnd.on, color = colors.mauve },
      })
    else
      dnd:set({
        icon = { string = icons.dnd.off, color = colors.overlay1 },
      })
    end
  end)
end

dnd:subscribe({ "routine", "forced" }, update_dnd)

dnd:subscribe("mouse.clicked", function()
  sbar.exec('open "x-apple.systempreferences:com.apple.Focus"')
end)
