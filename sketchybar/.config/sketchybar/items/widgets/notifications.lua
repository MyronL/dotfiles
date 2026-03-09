local colors = require("colors")
local settings = require("settings")

local notifications = sbar.add("item", "widgets.notifications", {
  position = "right",
  update_freq = settings.update_freq.notifications,
  icon = {
    string = "󰂚",
    font = {
      family = settings.font.text,
      style = settings.font.style.bold,
      size = 17.0,
    },
    color = colors.overlay1,
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

local prev_count = 0

local apps = {
  "Microsoft Outlook",
  "Microsoft Teams",
  "Slack",
}

local function get_badge(app_name)
  return string.format(
    'lsappinfo info -only StatusLabel "%s" | sed -n \'s/"StatusLabel"={ "label"="\\(.*\\)" }$/\\1/p\'',
    app_name
  )
end

local function update_notifications()
  local total = 0
  local remaining = #apps

  for _, app in ipairs(apps) do
    sbar.exec(get_badge(app), function(result)
      if result then
        local badge = result:match("^%s*(.-)%s*$")
        local num = tonumber(badge)
        if num then
          total = total + num
        elseif badge and badge ~= "" then
          -- Dot indicator (e.g. Slack) counts as 1
          total = total + 1
        end
      end

      remaining = remaining - 1
      if remaining == 0 then
        if total > 0 then
          notifications:set({
            icon = { string = "󰂚", color = colors.yellow },
            label = { string = tostring(total) },
          })
          -- Bounce when count increases
          if total > prev_count then
            sbar.animate("tanh", 15, function()
              notifications:set({ label = { y_offset = 5 } })
            end)
            sbar.animate("tanh", 15, function()
              notifications:set({ label = { y_offset = 0 } })
            end)
          end
        else
          notifications:set({
            icon = { string = "󰂚", color = colors.overlay1 },
            label = { string = "0" },
          })
        end
        prev_count = total
      end
    end)
  end
end

notifications:subscribe({ "routine", "forced" }, update_notifications)

notifications:subscribe("mouse.clicked", function()
  sbar.exec('open -a "Microsoft Outlook"')
end)
