local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local calendar = sbar.add("item", "calendar", {
  position = "right",
  update_freq = settings.update_freq.calendar,
  icon = {
    string = icons.calendar,
    font = {
      family = settings.font.text,
      style = settings.font.style.bold,
      size = 17.0,
    },
    color = colors.blue,
  },
  label = {
    font = {
      family = settings.font.numbers,
      style = settings.font.style.bold,
      size = settings.item_label_size,
    },
    color = colors.text,
  },
})

-- Popup items
local popup_font = {
  family = settings.font.text,
  style = settings.font.style.regular,
  size = 13.0,
}

local cal_full_date = sbar.add("item", "calendar.full_date", {
  position = "popup.calendar",
  icon = { string = "Date:", font = popup_font, color = colors.overlay1 },
  label = { string = "—", font = popup_font, color = colors.text },
})

local cal_week = sbar.add("item", "calendar.week", {
  position = "popup.calendar",
  icon = { string = "Week:", font = popup_font, color = colors.overlay1 },
  label = { string = "—", font = popup_font, color = colors.text },
})

local cal_day_of_year = sbar.add("item", "calendar.day_of_year", {
  position = "popup.calendar",
  icon = { string = "Day:", font = popup_font, color = colors.overlay1 },
  label = { string = "—", font = popup_font, color = colors.text },
})

calendar:subscribe({ "routine", "forced" }, function()
  local date = os.date("%a %d %b %H:%M")
  calendar:set({ label = date })
end)

local popup_visible = false

calendar:subscribe("mouse.clicked", function()
  popup_visible = not popup_visible
  if popup_visible then
    cal_full_date:set({ label = { string = os.date("%A, %B %d, %Y") } })
    cal_week:set({ label = { string = "Week " .. os.date("%W") } })
    cal_day_of_year:set({ label = { string = os.date("%j") .. " of 365" } })
  end
  calendar:set({ popup = { drawing = popup_visible } })
end)
