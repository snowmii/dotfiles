-- If LuaRocks is installed, make sure that packages installed through it are
-- found (e.g. lgi). If LuaRocks is not installed, do nothing.
pcall(require, "luarocks.loader")

-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
require("awful.autofocus")
-- Widget and layout library
local wibox = require("wibox")
-- Theme handling library
local beautiful = require("beautiful")
-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")
local hotkeys_popup = require("awful.hotkeys_popup")
local dpi = beautiful.xresources.apply_dpi
-- Enable hotkeys help widget for VIM and other apps
-- when client with a matching name is opened:
require("awful.hotkeys_popup.keys")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
beautiful.init(gears.filesystem.get_configuration_dir() ..
                   "themes/default/theme.lua")

-- This is used later as the default terminal and editor to run.
terminal = "alacritty"
editor = os.getenv("EDITOR") or "nano"
editor_cmd = terminal .. " -e " .. editor

-- Default modkey.
-- Usually, Mod4 is the key with a logo between Control and Alt.
-- If you do not like this or do not have such a key,
-- I suggest you to remap Mod4 to another key using xmodmap or other tools.
-- However, you can use another modifier like Mod1, but it may interact with others.
modkey = "Mod4"
alt = "Mod1"

-- Table of layouts to cover with awful.layout.inc, order matters.
awful.layout.layouts = {
    awful.layout.suit.tile, awful.layout.suit.tile.left,
    awful.layout.suit.spiral.dwindle, awful.layout.suit.floating,
    awful.layout.suit.max, awful.layout.suit.max.fullscreen,
    awful.layout.suit.magnifier
    -- awful.layout.suit.corner.nw
    -- awful.layout.suit.corner.ne,
    -- awful.layout.suit.corner.sw,
    -- awful.layout.suit.corner.se,
}
-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
myawesomemenu = {
    {
        "hotkeys",
        function() hotkeys_popup.show_help(nil, awful.screen.focused()) end
    }, {"manual", terminal .. " -e man awesome"},
    {"edit config", editor_cmd .. " " .. awesome.conffile},
    {"restart", awesome.restart}, {"quit", function() awesome.quit() end}
}

mymainmenu = awful.menu({
    items = {
        {"awesome", myawesomemenu, beautiful.awesome_icon},
        {"open terminal", terminal}
    }
})

mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu
})

local function colorizeText(txt, fg)
    if fg == "" then fg = "#ffffff" end

    return "<span foreground='" .. fg .. "'>" .. txt .. "</span>"
end

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
mykeyboardlayout = awful.widget.keyboardlayout()

-- {{{ Wibar
-- Create a textclock widget
mytextclock = wibox.widget.textclock("%H:%M  ")

-- Create a wibox for each screen and add it
local taglist_buttons = gears.table.join(
                            awful.button({}, 1, function(t) t:view_only() end),
                            awful.button({modkey}, 1, function(t)
        if client.focus then client.focus:move_to_tag(t) end
    end), awful.button({}, 3, awful.tag.viewtoggle),
                            awful.button({modkey}, 3, function(t)
        if client.focus then client.focus:toggle_tag(t) end
    end), awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
                            awful.button({}, 5, function(t)
        awful.tag.viewprev(t.screen)
    end))

local function set_wallpaper(s)
    -- Wallpaper
    if beautiful.wallpaper then
        local wallpaper = beautiful.wallpaper
        -- If wallpaper is a function, call it with the screen
        if type(wallpaper) == "function" then wallpaper = wallpaper(s) end
        gears.wallpaper.maximized(wallpaper, s, true)
    end
end

local function rrect(radius)
    radius = radius or dpi(4)
    return function(cr, width, height)
        gears.shape.rounded_rect(cr, width, height, radius)
    end
end

local wifi = wibox.widget {
    font = beautiful.icofont .. " 14",
    markup = colorizeText("󰤨", beautiful.fg),
    widget = wibox.widget.textbox,
    valign = "center",
    align = "center"
}
local battery = wibox.widget {
    id = 'battery',
    widget = wibox.widget.progressbar,
    max_value = 100,
    value = 69,
    forced_width = 90,
    forced_height = 30,
    shape = rrect(5)
}
local battery_text = wibox.widget {
    font = beautiful.icofont .. " 13",
    markup = colorizeText("󱐋", beautiful.bg),
    widget = wibox.widget.textbox,
    valign = "center",
    align = "center"
}
local status = wibox.widget {
    {
        {
            {
                conditional_widget = batteryExists and {
                    battery, battery_text, layout = wibox.layout.stack
                } or nil,
                wifi,
                layout = wibox.layout.fixed.horizontal,
                spacing = dpi(15)
            },
            left = 10,
            right = 10,
            top = 4,
            bottom = 4,
            widget = wibox.container.margin
        },
        layout = wibox.layout.stack
    },
    buttons = {
        awful.button({}, 1,
                     function() awesome.emit_signal('toggle::control') end)
    },
    bg = beautiful.bg2,
    widget = wibox.container.background,
    shape = rrect(2)
}

-- Function to check if battery exists
function batteryExists()
    local batteryPath = "/sys/class/power_supply/BAT0"
    return file_exists(batteryPath)
end

-- Function to check if file exists
function file_exists(path)
    local file = io.open(path, "r")
    if file then
        file:close()
        return true
    else
        return false
    end
end

awesome.connect_signal("signal::network", function(value)
    if value then
        wifi.markup = "󰤨 "
    else
        wifi.markup = colorizeText("󰤮", beautiful.fg .. "99")
    end
end)

awesome.connect_signal("signal::battery", function(value, charging)
    local b = battery
    b.value = value

    if charging then
        battery_text.font = beautiful.icofont .. " 13"
        battery_text.markup = colorizeText("󱐋", beautiful.bg)
    else
        battery_text.font = beautiful.font
        battery_text.markup = colorizeText(tostring(value), beautiful.bg)
    end

    if value < 20 then
        b.color = beautiful.err
        b.background_color = beautiful.err .. '55'
    elseif value < 40 then
        b.color = beautiful.warn_two
        b.background_color = beautiful.warn_two .. '55'
    elseif value < 60 then
        b.color = beautiful.warn
        b.background_color = beautiful.warn .. '55'
    elseif value < 80 then
        b.color = beautiful.pri
        b.background_color = beautiful.pri .. '55'
    else
        b.color = beautiful.ok
        b.background_color = beautiful.ok .. '55'
    end
end)

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", set_wallpaper)

awful.screen.connect_for_each_screen(function(s)
    s.padding = {top = "-6"}
    -- Wallpaper
    set_wallpaper(s)

    -- Each screen has its own tag table.
    awful.tag({"1", "2", "3", "4", "5", "6", "7", "8", "9"}, s,
              awful.layout.layouts[1])

    -- Create a promptbox for each screen
    s.mypromptbox = awful.widget.prompt()
    -- Create an imagebox widget which will contain an icon indicating which layout we're using.
    -- We need one layoutbox per screen.
    s.mylayoutbox = awful.widget.layoutbox(s)
    s.mylayoutbox:buttons(gears.table.join(
                              awful.button({}, 1,
                                           function() awful.layout.inc(1) end),
                              awful.button({}, 3,
                                           function()
            awful.layout.inc(-1)
        end), awful.button({}, 4, function() awful.layout.inc(1) end),
                              awful.button({}, 5,
                                           function()
            awful.layout.inc(-1)
        end)))
    -- Create a taglist widget
    local update_tags = function(self, c3)
        local tagicon = self:get_children_by_id('icon_role')[1]
        if c3.selected then
            tagicon.text = " "
            self.fg = beautiful.fg_focus
        elseif #c3:clients() == 0 then
            tagicon.text = " "
            self.fg = beautiful.fg_normal
        else
            tagicon.text = " "
            if c3.urgent then
                self.fg = beautiful.fg_urgent
            else
                self.fg = beautiful.fg_normal
            end
        end
    end

    s.mytaglist = awful.widget.taglist {
        screen = s,
        filter = awful.widget.taglist.filter.all,
        layout = {spacing = dpi(8), layout = wibox.layout.fixed.horizontal},
        widget_template = {
            {
                {
                    id = 'icon_role',
                    font = "JetBrainsMono Nerd Font 14",
                    widget = wibox.widget.textbox,
                    valign = "center",
                    align = "center"
                },
                id = 'margin_role',
                top = 2,
                bottom = 4,
                left = 2,
                right = 2,
                widget = wibox.container.margin
            },
            id = 'background_role',
            widget = wibox.container.background,
            create_callback = function(self, c3, index, objects)
                update_tags(self, c3)
            end,

            update_callback = function(self, c3, index, objects)
                update_tags(self, c3)
            end
        },
        buttons = taglist_buttons
    }

    -- Create a tasklist widget
    s.mytasklist = awful.widget.tasklist {
        screen  = s,
        filter  = awful.widget.tasklist.filter.currenttags,
        buttons = tasklist_buttons
    }

    -- Create the wibox
    s.mywibox = awful.wibar({
        position = "top",
        screen = s,
        height = 27,
        border_width = 6,
        border_color = "00000000"
    })

    -- Add widgets to the wibox
    s.mywibox:setup{
        layout = wibox.layout.align.horizontal,
        expand = "none",
        { -- Left widgets
            layout = wibox.layout.fixed.horizontal,
            s.mylayoutbox,
            -- mylauncher,
            s.mytasklist,
            s.mypromptbox
        },
        s.mytaglist, -- Middle widget
        { -- Right widgets
            layout = wibox.layout.fixed.horizontal,
            mykeyboardlayout,
            -- wibox.widget.systray(),
            status,
            mytextclock
        }
    }
    -- TODO: wifi menu, volume widget, calender
end)
-- }}}

-- {{{ Key bindings
globalkeys = gears.table.join(awful.key({modkey}, "s", hotkeys_popup.show_help,
                                        {
    description = "show help",
    group = "awesome"
}), awful.key({modkey}, "Tab", awful.tag.viewnext,
              {description = "view next", group = "tag"}),
                              awful.key({modkey, "Shift"}, "Tab",
                                        awful.tag.viewprev, {
    description = "view prev",
    group = "tag"
}), awful.key({alt}, "Tab", function() awful.client.focus.byidx(1) end,
              {description = "focus next by index", group = "client"}),
                              awful.key({alt, "Shift"}, "Tab", function()
    awful.client.focus.byidx(-1)
end, {description = "focus previous by index", group = "client"}),
-- awful.key({ modkey,           }, "w", function () mymainmenu:show() end,
--          {description = "show main menu", group = "awesome"}),

-- Layout manipulation
                              awful.key({modkey, "Shift"}, "j", function()
    awful.client.swap.byidx(1)
end, {description = "swap with next client by index", group = "client"}),
                              awful.key({modkey, "Shift"}, "k", function()
    awful.client.swap.byidx(-1)
end, {description = "swap with previous client by index", group = "client"}),
                              awful.key({modkey, "Control"}, "j", function()
    awful.screen.focus_relative(1)
end, {description = "focus the next screen", group = "screen"}),
                              awful.key({modkey, "Control"}, "k", function()
    awful.screen.focus_relative(-1)
end, {description = "focus the previous screen", group = "screen"}),
                              awful.key({modkey}, "u",
                                        awful.client.urgent.jumpto, {
    description = "jump to urgent client",
    group = "client"
}), awful.key({modkey}, "Tab", function()
    awful.client.focus.history.previous()
    if client.focus then client.focus:raise() end
end, {description = "go back", group = "client"}), -- Standard program
awful.key({modkey}, "Return", function() awful.spawn(terminal) end,
          {description = "open a terminal", group = "launcher"}),
                              awful.key({modkey, "Shift"}, "r", awesome.restart,
                                        {
    description = "reload awesome",
    group = "awesome"
}), awful.key({modkey, "Shift"}, "q", awesome.quit,
              {description = "quit awesome", group = "awesome"}),

                              awful.key({modkey}, "l", function()
    awful.tag.incmwfact(0.05)
end, {description = "increase master width factor", group = "layout"}),
                              awful.key({modkey}, "h", function()
    awful.tag.incmwfact(-0.05)
end, {description = "decrease master width factor", group = "layout"}),
                              awful.key({modkey, "Shift"}, "h", function()
    awful.tag.incnmaster(1, nil, true)
end, {description = "increase the number of master clients", group = "layout"}),
                              awful.key({modkey, "Shift"}, "l", function()
    awful.tag.incnmaster(-1, nil, true)
end, {description = "decrease the number of master clients", group = "layout"}),
                              awful.key({modkey, "Control"}, "h", function()
    awful.tag.incncol(1, nil, true)
end, {description = "increase the number of columns", group = "layout"}),
                              awful.key({modkey, "Control"}, "l", function()
    awful.tag.incncol(-1, nil, true)
end, {description = "decrease the number of columns", group = "layout"}),
                              awful.key({modkey}, "space",
                                        function() awful.layout.inc(1) end, {
    description = "select next",
    group = "layout"
}), awful.key({modkey, "Shift"}, "space", function() awful.layout.inc(-1) end,
              {description = "select previous", group = "layout"}),

                              awful.key({modkey, "Control"}, "n", function()
    local c = awful.client.restore()
    -- Focus restored client
    if c then
        c:emit_signal("request::activate", "key.unminimize", {raise = true})
    end
end, {description = "restore minimized", group = "client"}), -- Prompt
awful.key({modkey}, "r", function() awful.util.spawn("rofi -show run") end,
          {description = "run prompt", group = "launcher"}), -- TODO: replace with rofi

                              awful.key({modkey}, "x", function()
    awful.prompt.run {
        prompt = "Run Lua code: ",
        textbox = awful.screen.focused().mypromptbox.widget,
        exe_callback = awful.util.eval,
        history_path = awful.util.get_cache_dir() .. "/history_eval"
    }
end, {description = "lua execute prompt", group = "awesome"}),
                              awful.key({modkey}, "w", function()
    awful.util.spawn("rofi -show drun")
end, {description = "show the menubar", group = "launcher"}))

clientkeys = gears.table.join(awful.key({modkey}, "f", function(c)
    c.fullscreen = not c.fullscreen
    c:raise()
end, {description = "toggle fullscreen", group = "client"}),
                              awful.key({modkey}, "q", function(c) c:kill() end,
                                        {
    description = "close",
    group = "client"
}), awful.key({modkey, "Control"}, "space", awful.client.floating.toggle,
              {description = "toggle floating", group = "client"}),
                              awful.key({modkey}, "t",
                                        function(c) c.ontop = not c.ontop end, {
    description = "toggle keep on top",
    group = "client"
}), awful.key({modkey}, "n", function(c)
    -- The client currently has the input focus, so it cannot be
    -- minimized, since minimized clients can't have the focus.
    c.minimized = true
end, {description = "minimize", group = "client"}),
                              awful.key({modkey}, "Up", function(c)
    c.maximized = not c.maximized
    c:raise()
end, {description = "(un)maximize", group = "client"}),
                              awful.key({modkey, "Control"}, "m", function(c)
    c.maximized_vertical = not c.maximized_vertical
    c:raise()
end, {description = "(un)maximize vertically", group = "client"}),
                              awful.key({modkey, "Shift"}, "m", function(c)
    c.maximized_horizontal = not c.maximized_horizontal
    c:raise()
end, {description = "(un)maximize horizontally", group = "client"}))

-- Bind all key numbers to tags
-- Be careful: we use keycodes to make it work on any keyboard layout.
-- This should map on the top row of your keyboard, usually 1 to 9.
for i = 1, 9 do
    globalkeys = gears.table.join(globalkeys, -- View tag only.
    awful.key({modkey}, "#" .. i + 9, function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then tag:view_only() end
    end, {description = "view tag #" .. i, group = "tag"}),
    -- Toggle tag display.
    awful.key({modkey, "Control"}, "#" .. i + 9, function()
        local screen = awful.screen.focused()
        local tag = screen.tags[i]
        if tag then awful.tag.viewtoggle(tag) end
    end, {description = "toggle tag #" .. i, group = "tag"}),
    -- Move client to tag.
    awful.key({modkey, "Shift"}, "#" .. i + 9, function()
        if client.focus then
            local tag = client.focus.screen.tags[i]
            if tag then client.focus:move_to_tag(tag) end
        end
    end, {description = "move focused client to tag #" .. i, group = "tag"}),
    -- Toggle tag on focused client.
    awful.key({modkey, "Control", "Shift"}, "#" .. i + 9, function()
        if client.focus then
            local tag = client.focus.screen.tags[i]
            if tag then client.focus:toggle_tag(tag) end
        end
    end, {description = "toggle focused client on tag #" .. i, group = "tag"}))
end

clientbuttons = gears.table.join(awful.button({}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
end), awful.button({modkey}, 1, function(c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
    awful.mouse.client.move(c)
end), awful.button({modkey}, 3, function(c)
    c:emit_signal("request::activate", "mouse_click", {raise = true})
    awful.mouse.client.resize(c)
end))

-- Set keys
root.keys(globalkeys)
-- }}}

-- {{{ Rules
-- Rules to apply to new clients (through the "manage" signal).
awful.rules.rules = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = 0,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = clientkeys,
            buttons = clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap +
                awful.placement.no_offscreen
        }
    }, -- Floating clients.
    {
        rule_any = {
            instance = {
                "DTA", -- Firefox addon DownThemAll.
                "copyq", -- Includes session name in class.
                "pinentry"
            },
            class = {
                "Arandr", "Blueman-manager", "Gpick", "Kruler", "MessageWin", -- kalarm.
                "Sxiv", "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
                "Wpa_gui", "veromix", "xtightvncviewer"
            },

            -- Note that the name property shown in xprop might be set slightly after creation of the client
            -- and the name shown there might not match defined rules here.
            name = {
                "Event Tester" -- xev.
            },
            role = {
                "AlarmWindow", -- Thunderbird's calendar.
                "ConfigManager", -- Thunderbird's about:config.
                "pop-up" -- e.g. Google Chrome's (detached) Developer Tools.
            }
        },
        properties = {floating = true}
    }, -- Add titlebars to normal clients and dialogs
    {
        rule_any = {type = {"normal", "dialog"}},
        properties = {titlebars_enabled = false}
    }, -- App rules
    {
        rule = {class = "Google-chrome"},
        properties = {
            screen = awful.screen.focused(),
            tag = "2",
            fullscreen = true
        }
    }
}
-- }}}

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup and not c.size_hints.user_position and
        not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    -- buttons for the titlebar
    local buttons = gears.table.join(awful.button({}, 1, function()
        c:emit_signal("request::activate", "titlebar", {raise = true})
        awful.mouse.client.move(c)
    end), awful.button({}, 3, function()
        c:emit_signal("request::activate", "titlebar", {raise = true})
        awful.mouse.client.resize(c)
    end))

    awful.titlebar(c):setup{
        { -- Left
            awful.titlebar.widget.iconwidget(c),
            buttons = buttons,
            layout = wibox.layout.fixed.horizontal
        },
        { -- Middle
            { -- Title
                align = "center",
                widget = awful.titlebar.widget.titlewidget(c)
            },
            buttons = buttons,
            layout = wibox.layout.flex.horizontal
        },
        { -- Right
            awful.titlebar.widget.floatingbutton(c),
            awful.titlebar.widget.maximizedbutton(c),
            awful.titlebar.widget.stickybutton(c),
            awful.titlebar.widget.ontopbutton(c),
            awful.titlebar.widget.closebutton(c),
            layout = wibox.layout.fixed.horizontal()
        },
        layout = wibox.layout.align.horizontal
    }
end)

-- Enable sloppy focus, so that focus follows mouse.
client.connect_signal("mouse::enter", function(c)
    c:emit_signal("request::activate", "mouse_enter", {raise = false})
end)

client.connect_signal("focus",
                      function(c) c.border_color = beautiful.border_focus end)
client.connect_signal("unfocus",
                      function(c) c.border_color = beautiful.border_normal end)
-- }}}
-- Emitting Signals --
local function emit_network_status()
    awful.spawn.easy_async_with_shell(
        "bash -c 'nmcli networking connectivity check'", function(stdout)
            local status = not stdout:match("none") -- boolean
            awesome.emit_signal('signal::network', status)
        end)
end
-- Battery information script
local battery_script =
    "bash -c 'echo $(cat /sys/class/power_supply/BAT1/capacity) echo $(cat /sys/class/power_supply/BAT1/status)'"

local function battery_emit()
    awful.spawn.easy_async_with_shell(battery_script, function(stdout)
        -- The battery level and status are saved as a string. Then the level
        -- is stored separately as a string, then converted to int. The status
        -- is stored as a bool, and also as an int for registering changes in
        -- battery status.
        local level = string.match(stdout:match('(%d+)'), '(%d+)')
        local level_int = tonumber(level) -- integer
        local power = not stdout:match('Discharging') -- boolean
        awesome.emit_signal('signal::battery', level_int, power)
    end)
end
-- Refreshing
-------------
gears.timer {
    timeout = 20,
    call_now = true,
    autostart = true,
    callback = function() emit_network_status() end
}
gears.timer {
    timeout = 2,
    call_now = true,
    autostart = true,
    callback = function()
        --if #"/sys/class/power_supply":GetChildren() != 0 then
          --  battery_emit()
        --end
    end
}
-- Gaps --
-- awful.screen.padding = { top = "-8" }
beautiful.useless_gap = 4
-- Start Up --
awful.spawn.with_shell("picom --config $HOME/.config/picom/picom.conf")
awful.spawn.with_shell("systemctl --user enable opentabletdriver.service --now")
awful.spawn.with_shell(
    'xinput set-prop "ELAN0501:00 04F3:3019 Touchpad" "libinput Tapping Enabled" 1')
awful.spawn.with_shell("set EDITOR vim")
awful.spawn.with_shell("xrandr --output DP-4 --mode 2560x1440 --rate 165")
awful.spawn("google-chrome-stable")
