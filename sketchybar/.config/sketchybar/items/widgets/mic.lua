local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local mic = sbar.add("item", "widgets.mic", {
  position = "right",
  update_freq = settings.update_freq.mic,
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style.bold,
      size = 17.0,
    },
  },
  label = { drawing = false },
})

local function update_mic()
  sbar.exec("osascript -e 'input volume of (get volume settings)'", function(result)
    local vol = tonumber(result)
    if vol and vol == 0 then
      mic:set({
        icon = { string = icons.mic.muted, color = colors.red },
      })
    else
      mic:set({
        icon = { string = icons.mic.unmuted, color = colors.green },
      })
    end
  end)
end

mic:subscribe({ "routine", "forced" }, update_mic)

mic:subscribe("mouse.clicked", function()
  sbar.exec("osascript -e 'input volume of (get volume settings)'", function(result)
    local vol = tonumber(result)
    if vol and vol == 0 then
      sbar.exec("osascript -e 'set volume input volume 100'")
    else
      sbar.exec("osascript -e 'set volume input volume 0'")
    end
    update_mic()
  end)
end)
