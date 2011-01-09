-----------------------------------------------------------------------
-- luakit configuration file, more information at http://luakit.org/ --
-----------------------------------------------------------------------

-- Load library of useful functions for luakit
require "lousy"

-- Small util functions to print output (info prints only when luakit.verbose is true)
function warn(...) io.stderr:write(string.format(...) .. "\n") end
function info(...) if luakit.verbose then io.stderr:write(string.format(...) .. "\n") end end

-- Load users global config
-- ("$XDG_CONFIG_HOME/luakit/globals.lua" or "/etc/xdg/luakit/globals.lua")
require "globals"

-- Load users theme
-- ("$XDG_CONFIG_HOME/luakit/theme.lua" or "/etc/xdg/luakit/theme.lua")
lousy.theme.init(lousy.util.find_config("theme.lua"))
theme = assert(lousy.theme.get(), "failed to load theme")

-- Load users window class
-- ("$XDG_CONFIG_HOME/luakit/window.lua" or "/etc/xdg/luakit/window.lua")
require "window"

-- Load users webview class
-- ("$XDG_CONFIG_HOME/luakit/webview.lua" or "/etc/xdg/luakit/webview.lua")
require "webview"

-- Load users mode configuration
-- ("$XDG_CONFIG_HOME/luakit/modes.lua" or "/etc/xdg/luakit/modes.lua")
require "modes"

-- Load users keybindings
-- ("$XDG_CONFIG_HOME/luakit/binds.lua" or "/etc/xdg/luakit/binds.lua")
require "binds"

----------------------------------
-- Optional user script loading --
----------------------------------

-- Add vimperator-like link hinting & following
require "follow"

-- Add uzbl-like form filling
require "formfiller"

-- Add proxy support & manager
require "proxy"

-- Add quickmarks support & manager
require "quickmarks"

-- Add session saving/loading support
require "session"

-- Add command to list closed tabs & bind to open closed tabs
require "undoclose"

-- Add greasemonkey-like javascript userscript support
require "userscripts"

-- Add bookmarks support
require "bookmarks"

-- Add download support
require "downloads"
require "downloads_chrome"

-- Add command completion
require "completion"

-- Add command history
require "cmdhist"

-- Add search mode & binds
require "search"

-- Add ordering of new tabs
require "taborder"

require "follow_selected"
require "go_input"
require "go_next_prev"
require "go_up"

--
--Autopager
--

local ready_views = setmetatable({}, { mode = "_k" })

local go_next = [=[
(function() {
  alert("found");
  var el = document.querySelector("[rel='next']");
  if (el) { // Wow a developer that knows what he's doing!
    location = el.href;
  }
  else { // Search from the bottom of the page up for a next link.
    var els = document.getElementsByTagName("a");
    var i = els.length;
    while ((el = els[--i])) {
      if (el.text.search(/(\bnext\b|\bSuivant\b|^>$|^(>>|»)$|^(>|»)|(>|»)$|\bmore\b)/i) > -1) {
        alert("found");
        location = el.href;
        break;
      }
    }
  }
})();
]=]

webview.init_funcs.autopager = function (view, w)
    view:add_signal("load-status", function (v, status)
        print("Status", status)
        ready_views[v] = (status == "finished")
    end)
    view:add_signal("expose", function (v)
        local cur, max = view:get_scroll_vert()
        if ready_views[v] and cur == max then
            ready_views[v] = false
            v:eval_js(go_next, "(autopager.lua)")
        end
    end)
end

--
-- Opera like default page
--
-- vim: et:sw=4:ts=8:sts=4:tw=80

local chrome = require "chrome" 
local capi = { luakit = luakit }

local page    = "chrome://favs/" 
local pattern = page.."?" 

local cutycapt_bin = "~/.bin/CutyCapt" 
local cutycapt_opt = "--min-width=1024 --min-height=768" 
local mogrify_bin  = "/usr/bin/mogrify" 
local mogrify_opt  = "-extent 1024x768 -size 240x180 -resize 240x180" 

local html_template = [====[
<html>
<head>
    <title>Speed Dial</title>
    <style type="text/css">
    {style}
    </style>
</head>
<body>
{favs}
</body>
</html>
]====]

local html_style = [====[
body {
    background: #0A1535;
    text-align: center;
}
a.fav {
    background: #1577D3;
    display:inline-block;
    width: 280;
    border: 1px solid black;
    border-radius: 5px;
    padding-top: 10px;
    margin:8px;
    text-align: center;

    text-decoration: none;
    font-weight: bold;
    color: #173758;
}
a.fav:hover {
    background: #00BBD7;
    border-width:1px;
}
a.fav img {
    border: 1px solid #909090;
}
]====]

local fav_template = [====[
    <a class="fav" href={url}>
        <img src="{thumb}" width="240" height="180" border="0" />
        {title}
    </a>
]====]

local function favs()
    local favs = {}
    local updated = {}

    local f = io.open(capi.luakit.data_dir .. "/favs")
    for line in f:lines() do
        local url, thumb, refresh, title = line:match("(%S+)%s+(%S+)%s+(%S+)%s+(.+)")
        if thumb == "none" or refresh == "yes" then
            thumb = string.format("%s/thumb-%s.png", capi.luakit.data_dir, url:gsub("%W",""))
            local cmd = string.format('%s %s --url="%s" --out="%s" && %s %s %s', cutycapt_bin, cutycapt_opt, url, thumb, mogrify_bin, mogrify_opt, thumb)
            capi.luakit.spawn(string.format("/bin/sh -c '%s'", cmd))
        end
        updated[#updated+1] = string.format("%s %s %s %s", url, thumb, refresh, title)

        local subs = {
            url   = url,
            thumb = "file://"..thumb,
            title = title,
        }
        favs[#favs+1] = fav_template:gsub("{(%w+)}", subs)
    end
    f:close()

    local f = io.open(capi.luakit.data_dir .. "/favs", "w")
    f:write(table.concat(updated, "\n"))
    f:close()

    return table.concat(favs, "\n")
end

local function html()
    local subs = {
        style = html_style,
        favs  = favs(),
    }
    return html_template:gsub("{(%w+)}", subs)
end

local function show(view)
    -- the file:// is neccessary so that the thumbnails will be shown.
    -- disables reload though.
    view:load_string(html(), "file://favs")
end

chrome.add(pattern, show)


-----------------------------
-- End user script loading --
-----------------------------

-- Restore last saved session
local w = (session and session.restore())
if w then
    for i, uri in ipairs(uris) do
        w:new_tab(uri, i == 1)
    end
else
    -- Or open new window
    window.new(uris)
end


