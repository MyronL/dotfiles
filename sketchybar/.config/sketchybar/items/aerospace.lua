local colors = require("colors")
local settings = require("settings")
local icons = require("icons")
local app_icons = require("helpers.app_icons")

-- Color mapping for known workspaces
local workspace_colors = {
  ["T"] = colors.green,    -- Terminal
  ["W"] = colors.blue,     -- Web browser
  ["S"] = colors.mauve,    -- Slack
  ["M"] = colors.green,    -- Music
  ["C"] = colors.yellow,   -- Chrome
  ["O"] = colors.blue,     -- Outlook
  ["P"] = colors.peach,    -- Postman
}

local spaces = {}
local service_mode = sbar.add("item", "aerospace.mode", {
  position = "left",
  drawing = false,
  icon = {
    string = icons.aerospace.mode_service,
    color = colors.red,
    font = {
      family = settings.font.text,
      style = settings.font.style.bold,
      size = 15.0,
    },
  },
  label = {
    string = "SERVICE",
    color = colors.red,
    font = {
      family = settings.font.text,
      style = settings.font.style.bold,
      size = settings.item_label_size,
    },
  },
  background = {
    color = colors.with_alpha(colors.red, 0x33),
    corner_radius = 6,
    height = 22,
  },
})

service_mode:subscribe("aerospace_mode", function(env)
  local mode = env.MODE or "main"
  service_mode:set({ drawing = (mode == "service") })
end)

-- Get app icons string for a workspace
local function get_workspace_icons(ws, callback)
  sbar.exec('aerospace list-windows --workspace "' .. ws .. '" --format "%{app-name}"', function(result)
    if not result or result == "" then
      callback("")
      return
    end

    local seen = {}
    local icon_str = ""
    for line in result:gmatch("[^\r\n]+") do
      local app = line:match("^%s*(.-)%s*$")
      if app ~= "" and not seen[app] then
        seen[app] = true
        local icon = app_icons[app] or ":default:"
        icon_str = icon_str .. icon
      end
    end
    callback(icon_str)
  end)
end

-- Refresh which workspaces are visible (have windows or are focused)
local function refresh_visibility()
  sbar.exec("aerospace list-workspaces --monitor all --empty no", function(occupied)
    sbar.exec("aerospace list-workspaces --focused", function(raw_focused)
      local focused = raw_focused:match("^%s*(.-)%s*$")

      -- Build set of occupied workspaces
      local occupied_set = {}
      for ws_line in occupied:gmatch("[^\r\n]+") do
        local ws = ws_line:match("^%s*(.-)%s*$")
        occupied_set[ws] = true
      end

      -- Show only occupied + focused
      for ws, item in pairs(spaces) do
        local visible = occupied_set[ws] or ws == focused
        local is_focused = ws == focused
        local accent = workspace_colors[ws] or colors.lavender

        item:set({
          drawing = visible,
          icon = { highlight = is_focused },
        })

        -- Animate background color change
        sbar.animate("tanh", 15, function()
          item:set({
            background = {
              color = is_focused and colors.with_alpha(accent, 0x33) or colors.transparent,
            },
          })
        end)

        -- Bounce the focused workspace icon
        if is_focused then
          sbar.animate("tanh", 15, function()
            item:set({ icon = { y_offset = 4 } })
          end)
          sbar.animate("tanh", 15, function()
            item:set({ icon = { y_offset = 0 } })
          end)
        end

        -- Update app icons for visible workspaces
        if visible then
          get_workspace_icons(ws, function(icon_str)
            item:set({
              label = {
                string = icon_str,
                drawing = icon_str ~= "",
              },
            })
          end)
        end
      end
    end)
  end)
end

-- Discover workspaces synchronously so items are created in correct position
local handle = io.popen("aerospace list-workspaces --all")
local result = handle:read("*a")
handle:close()

for ws_line in result:gmatch("[^\r\n]+") do
  local workspace = ws_line:match("^%s*(.-)%s*$") -- trim whitespace

  local accent = workspace_colors[workspace] or colors.lavender
  local space = sbar.add("item", "aerospace." .. workspace, {
    position = "left",
    drawing = false, -- hidden by default, refresh_visibility will show occupied ones
    icon = {
      string = workspace,
      color = colors.overlay1,
      highlight_color = accent,
      font = {
        family = settings.font.numbers,
        style = settings.font.style.bold,
        size = 13.0,
      },
      padding_left = 6,
      padding_right = 4,
    },
    label = {
      drawing = false,
      font = {
        family = settings.font.app_font,
        style = settings.font.style.regular,
        size = 14.0,
      },
      color = colors.text,
      padding_left = 0,
      padding_right = 6,
    },
    background = {
      color = colors.transparent,
      corner_radius = 6,
      height = 22,
    },
    click_script = "aerospace workspace " .. workspace,
  })

  spaces[workspace] = space

  space:subscribe("aerospace_workspace_change", function()
    refresh_visibility()
  end)
end

-- Set initial state
refresh_visibility()
