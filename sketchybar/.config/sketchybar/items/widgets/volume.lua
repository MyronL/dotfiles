local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local volume = sbar.add("item", "widgets.volume", {
  position = "right",
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style.bold,
      size = 19.0,
    },
  },
  label = {
    font = {
      family = settings.font.numbers,
      style = settings.font.style.bold,
      size = settings.item_label_size,
    },
    width = 36,
    align = "right",
  },
})

local function update_icon(vol)
  local icon = icons.volume._0
  local color = colors.overlay1
  if vol > 60 then
    icon = icons.volume._100
    color = colors.text
  elseif vol > 30 then
    icon = icons.volume._66
    color = colors.text
  elseif vol > 10 then
    icon = icons.volume._33
    color = colors.subtext1
  elseif vol > 0 then
    icon = icons.volume._10
    color = colors.subtext0
  end
  return icon, color
end

volume:subscribe("volume_change", function(env)
  local vol = tonumber(env.INFO) or 0
  local icon, color = update_icon(vol)
  volume:set({
    icon = { string = icon, color = color },
    label = { string = vol .. "%" },
  })
end)

volume:subscribe("mouse.clicked", function()
  sbar.exec('open "x-apple.systempreferences:com.apple.Sound-Settings.extension"')
end)

volume:subscribe("mouse.scrolled", function(env)
  local delta = tonumber(env.SCROLL_DELTA) or 0
  -- delta > 0 = scroll up = volume up, delta < 0 = scroll down = volume down
  local step = delta > 0 and 5 or -5
  sbar.exec("osascript -e 'set volume output volume ((output volume of (get volume settings)) + " .. step .. ")'", function()
    sbar.exec("osascript -e 'output volume of (get volume settings)'", function(result)
      local vol = tonumber(result) or 0
      if vol < 0 then vol = 0 end
      if vol > 100 then vol = 100 end
      local icon, color = update_icon(vol)
      volume:set({
        icon = { string = icon, color = color },
        label = { string = vol .. "%" },
      })
    end)
  end)
end)

-- Initial volume fetch
sbar.exec("osascript -e 'output volume of (get volume settings)'", function(result)
  local vol = tonumber(result) or 0
  local icon, color = update_icon(vol)
  volume:set({
    icon = { string = icon, color = color },
    label = { string = vol .. "%" },
  })
end)
