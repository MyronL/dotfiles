local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local wifi = sbar.add("item", "widgets.wifi", {
  position = "right",
  update_freq = settings.update_freq.wifi,
  icon = {
    font = {
      family = settings.font.text,
      style = settings.font.style.bold,
      size = 17.0,
    },
  },
  label = {
    font = {
      family = settings.font.text,
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

local wifi_ssid = sbar.add("item", "widgets.wifi.ssid", {
  position = "popup.widgets.wifi",
  icon = { string = "SSID:", font = popup_font, color = colors.overlay1 },
  label = { string = "—", font = popup_font, color = colors.text },
})

local wifi_ip = sbar.add("item", "widgets.wifi.ip", {
  position = "popup.widgets.wifi",
  icon = { string = "IP:", font = popup_font, color = colors.overlay1 },
  label = { string = "—", font = popup_font, color = colors.text },
})

local wifi_interface = sbar.add("item", "widgets.wifi.interface", {
  position = "popup.widgets.wifi",
  icon = { string = "Interface:", font = popup_font, color = colors.overlay1 },
  label = { string = "—", font = popup_font, color = colors.text },
})

local popup_visible = false
local current_ssid = ""

local function update_wifi()
  sbar.exec("~/Applications/wifi-unredactor.app/Contents/MacOS/wifi-unredactor | /opt/homebrew/bin/jq -r .ssid", function(result)
    local ssid = result:match("^%s*(.-)%s*$")
    if ssid and ssid ~= "" then
      current_ssid = ssid
      wifi:set({
        icon = { string = icons.wifi.connected, color = colors.text },
        label = { string = ssid },
      })
    else
      current_ssid = ""
      wifi:set({
        icon = { string = icons.wifi.disconnected, color = colors.overlay1 },
        label = { string = "N/A" },
      })
    end
  end)
end

local function update_popup()
  wifi_ssid:set({ label = { string = current_ssid ~= "" and current_ssid or "N/A" } })

  sbar.exec("ipconfig getifaddr en0 2>/dev/null || echo 'N/A'", function(result)
    wifi_ip:set({ label = { string = result:match("^%s*(.-)%s*$") or "N/A" } })
  end)

  sbar.exec("networksetup -listallhardwareports | awk '/Wi-Fi/{getline; print $2}'", function(result)
    wifi_interface:set({ label = { string = result:match("^%s*(.-)%s*$") or "en0" } })
  end)
end

wifi:subscribe({ "routine", "wifi_change", "system_woke" }, update_wifi)

wifi:subscribe("mouse.clicked", function()
  popup_visible = not popup_visible
  if popup_visible then
    update_popup()
  end
  wifi:set({ popup = { drawing = popup_visible } })
end)
