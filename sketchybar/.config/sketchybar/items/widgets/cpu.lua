local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local cpu = sbar.add("item", "widgets.cpu", {
  position = "right",
  update_freq = settings.update_freq.cpu,
  icon = {
    string = icons.cpu,
    font = {
      family = settings.font.text,
      style = settings.font.style.bold,
      size = 17.0,
    },
    color = colors.sapphire,
  },
  label = {
    font = {
      family = settings.font.numbers,
      style = settings.font.style.bold,
      size = settings.item_label_size,
    },
  },
})

-- Popup: top 5 processes
local popup_font = {
  family = settings.font.text,
  style = settings.font.style.regular,
  size = 13.0,
}

local popup_items = {}
for i = 1, 5 do
  popup_items[i] = sbar.add("item", "widgets.cpu.proc" .. i, {
    position = "popup.widgets.cpu",
    icon = { string = "", font = popup_font, color = colors.overlay1 },
    label = { string = "", font = popup_font, color = colors.text },
  })
end

cpu:subscribe({ "routine" }, function()
  sbar.exec("top -l 1 -n 0 | grep 'CPU usage'", function(result)
    local user = result:match("(%d+%.?%d*)%%%s*user")
    local sys = result:match("(%d+%.?%d*)%%%s*sys")
    local total = (tonumber(user) or 0) + (tonumber(sys) or 0)
    local pct = string.format("%.0f%%", total)

    local color = colors.text
    if total > 80 then
      color = colors.red
    elseif total > 50 then
      color = colors.peach
    end

    cpu:set({
      label = { string = pct, color = color },
    })
  end)
end)

local popup_visible = false

local function update_popup()
  sbar.exec("ps -Arco %cpu,comm | head -6 | tail -5", function(result)
    local i = 1
    for line in result:gmatch("[^\n]+") do
      if i > 5 then break end
      local pct, name = line:match("^%s*(%S+)%s+(.+)$")
      if pct and name then
        popup_items[i]:set({
          icon = { string = pct .. "%" },
          label = { string = name:match("^%s*(.-)%s*$") },
        })
        i = i + 1
      end
    end
    -- Clear remaining slots
    for j = i, 5 do
      popup_items[j]:set({ icon = { string = "" }, label = { string = "" } })
    end
  end)
end

cpu:subscribe("mouse.clicked", function()
  popup_visible = not popup_visible
  if popup_visible then
    update_popup()
  end
  cpu:set({ popup = { drawing = popup_visible } })
end)
