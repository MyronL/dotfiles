local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local battery = sbar.add("item", "widgets.battery", {
  position = "right",
  update_freq = settings.update_freq.battery,
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
  },
})

-- Popup items
local popup_font = {
  family = settings.font.text,
  style = settings.font.style.regular,
  size = 13.0,
}

local batt_source = sbar.add("item", "widgets.battery.source", {
  position = "popup.widgets.battery",
  icon = { string = "Source:", font = popup_font, color = colors.overlay1 },
  label = { string = "—", font = popup_font, color = colors.text },
})

local batt_remaining = sbar.add("item", "widgets.battery.remaining", {
  position = "popup.widgets.battery",
  icon = { string = "Remaining:", font = popup_font, color = colors.overlay1 },
  label = { string = "—", font = popup_font, color = colors.text },
})

local batt_condition = sbar.add("item", "widgets.battery.condition", {
  position = "popup.widgets.battery",
  icon = { string = "Health:", font = popup_font, color = colors.overlay1 },
  label = { string = "—", font = popup_font, color = colors.text },
})

local batt_cycles = sbar.add("item", "widgets.battery.cycles", {
  position = "popup.widgets.battery",
  icon = { string = "Cycles:", font = popup_font, color = colors.overlay1 },
  label = { string = "—", font = popup_font, color = colors.text },
})

local popup_visible = false

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
  sbar.exec("pmset -g batt", function(result)
    local found, _, charge = result:find("(%d+)%%")
    local charging = result:find("AC Power") ~= nil

    local charge_num = tonumber(charge) or 0
    local icon = icons.battery._0
    local icon_color = colors.red

    if charging then
      icon = icons.battery.charging
      icon_color = colors.green
    elseif charge_num > 80 then
      icon = icons.battery._100
      icon_color = colors.green
    elseif charge_num > 60 then
      icon = icons.battery._75
      icon_color = colors.yellow
    elseif charge_num > 40 then
      icon = icons.battery._50
      icon_color = colors.peach
    elseif charge_num > 20 then
      icon = icons.battery._25
      icon_color = colors.maroon
    end

    battery:set({
      icon = {
        string = icon,
        color = icon_color,
      },
      label = { string = charge .. "%" },
    })
  end)
end)

local function update_popup()
  sbar.exec("pmset -g batt", function(result)
    local source = result:find("AC Power") and "AC Power" or "Battery"
    batt_source:set({ label = { string = source } })

    local remaining = result:match("(%d+:%d+) remaining")
    if remaining then
      batt_remaining:set({ label = { string = remaining } })
    elseif result:find("charged") then
      batt_remaining:set({ label = { string = "Fully Charged" } })
    elseif result:find("finishing charge") then
      batt_remaining:set({ label = { string = "Finishing Charge" } })
    elseif result:find("not charging") then
      batt_remaining:set({ label = { string = "Not Charging" } })
    else
      batt_remaining:set({ label = { string = "Calculating…" } })
    end
  end)

  sbar.exec("system_profiler SPPowerDataType 2>/dev/null", function(result)
    local condition = result:match("Condition:%s*(%w+)")
    batt_condition:set({ label = { string = condition or "N/A" } })

    local cycles = result:match("Cycle Count:%s*(%d+)")
    batt_cycles:set({ label = { string = cycles or "N/A" } })
  end)
end

battery:subscribe("mouse.clicked", function()
  popup_visible = not popup_visible
  if popup_visible then
    update_popup()
  end
  battery:set({ popup = { drawing = popup_visible } })
end)
