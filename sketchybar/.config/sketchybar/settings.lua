return {
  -- Fonts
  font = {
    text = "MesloLGS Nerd Font Mono",
    numbers = "MesloLGS Nerd Font Mono",
    icons = "MesloLGS Nerd Font Mono",
    app_font = "sketchybar-app-font",
    style = {
      regular = "Regular",
      semibold = "Bold",
      bold = "Bold",
      medium = "Bold",
    },
  },

  -- Paddings
  paddings = 3,
  group_paddings = 5,

  -- Item sizes
  item_icon_size = 20.0,
  item_label_size = 15.0,

  -- Bar
  bar_height = 35,

  -- Update intervals (seconds)
  update_freq = {
    battery = 120,
    cpu = 5,
    wifi = 30,
    media = 3,
    calendar = 30,
    mic = 2,
    meeting = 5,
    dnd = 10,
    weather = 600,
    notifications = 10,
  },
}
