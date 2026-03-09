-- Load SbarLua C module
require("helpers")
sbar = require("sketchybar")

-- Register custom events from Aerospace
sbar.add("event", "aerospace_workspace_change")
sbar.add("event", "aerospace_mode")

-- Load bar appearance, defaults, and items
require("bar")
require("default")
require("items")

-- Start the event loop
sbar.event_loop()
