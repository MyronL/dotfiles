local colors = require("colors")
local settings = require("settings")

local weather = sbar.add("item", "widgets.weather", {
  position = "right",
  update_freq = settings.update_freq.weather,
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style.bold,
      size = 19.0,
    },
    color = colors.yellow,
  },
  label = {
    font = {
      family = settings.font.text,
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

local weather_condition = sbar.add("item", "widgets.weather.condition", {
  position = "popup.widgets.weather",
  icon = { string = "Condition:", font = popup_font, color = colors.overlay1 },
  label = { string = "—", font = popup_font, color = colors.text },
})

local weather_feels_like = sbar.add("item", "widgets.weather.feels_like", {
  position = "popup.widgets.weather",
  icon = { string = "Feels Like:", font = popup_font, color = colors.overlay1 },
  label = { string = "—", font = popup_font, color = colors.text },
})

local weather_highlow = sbar.add("item", "widgets.weather.highlow", {
  position = "popup.widgets.weather",
  icon = { string = "High / Low:", font = popup_font, color = colors.overlay1 },
  label = { string = "—", font = popup_font, color = colors.text },
})

local weather_humidity = sbar.add("item", "widgets.weather.humidity", {
  position = "popup.widgets.weather",
  icon = { string = "Humidity:", font = popup_font, color = colors.overlay1 },
  label = { string = "—", font = popup_font, color = colors.text },
})

local color_map = {
  yellow = colors.yellow,
  peach = colors.peach,
  blue = colors.blue,
  sapphire = colors.sapphire,
  sky = colors.sky,
  mauve = colors.mauve,
  teal = colors.teal,
  overlay1 = colors.overlay1,
  overlay2 = colors.overlay2,
  text = colors.text,
}

local weather_cmd = "swift ~/.config/sketchybar/helpers/weather.swift 2>/dev/null"

local cached = {}

local function update_weather()
  sbar.exec(weather_cmd, function(result)
    if result and result ~= "" then
      local icon, temp, color_name, condition, humidity, feels_like, high, low =
        result:match("^(.+)|(.+)|(%w+)|(.+)|(.+)|(.+)|(.+)|(.+)")
      if icon and temp then
        local icon_color = color_map[color_name] or colors.text
        weather:set({
          icon = { string = icon, color = icon_color },
          label = { string = temp },
        })
        cached.condition = condition
        cached.humidity = humidity
        cached.feels_like = feels_like
        cached.high = high
        cached.low = low
        return
      end
    end
    weather:set({
      icon = { string = "󰔏" },
      label = { string = "N/A" },
    })
  end)
end

weather:subscribe({ "routine", "forced" }, update_weather)

local popup_visible = false

weather:subscribe("mouse.clicked", function()
  popup_visible = not popup_visible
  if popup_visible then
    weather_condition:set({ label = { string = cached.condition or "N/A" } })
    weather_feels_like:set({ label = { string = cached.feels_like or "N/A" } })
    weather_highlow:set({ label = { string = (cached.high or "—") .. " / " .. (cached.low or "—") } })
    weather_humidity:set({ label = { string = cached.humidity or "N/A" } })
  end
  weather:set({ popup = { drawing = popup_visible } })
end)
