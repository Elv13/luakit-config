--------------------------
-- Default luakit theme --
--------------------------

local theme = {}

-- Default settings
theme.font = "monospace normal 9"
theme.fg   = "#1577D3"
theme.bg   = "#0A1535"

-- Genaral colours
theme.success_fg = "#0f0"
theme.loaded_fg  = "#33AADD"
theme.error_fg = "#FFF"
theme.error_bg = "#F00"

-- Warning colours
theme.warning_fg = "#F00"
theme.warning_bg = "#FFF"

-- Notification colours
theme.notif_fg = "#444"
theme.notif_bg = "#FFF"

-- Menu colours
theme.menu_fg                   = "#1577D3"
theme.menu_bg                   = "#0A1535"
theme.menu_selected_fg          = "#000"
theme.menu_selected_bg          = "#FF0"
theme.menu_title_bg             = "#fff"
theme.menu_primary_title_fg     = "#f00"
theme.menu_secondary_title_fg   = "#666"

-- Proxy manager
theme.proxy_active_menu_fg      = '#000'
theme.proxy_active_menu_bg      = '#FFF'
theme.proxy_inactive_menu_fg    = '#888'
theme.proxy_inactive_menu_bg    = '#FFF'

-- Statusbar specific
theme.sbar_fg         = "#1577D3"
theme.sbar_bg         = "#0A1535"

-- Downloadbar specific
theme.dbar_fg         = "#1577D3"
theme.dbar_bg         = "#0A1535"
theme.dbar_error_fg   = "#F00"

-- Input bar specific
theme.ibar_fg           = "#000"
theme.ibar_bg           = "#fff"

-- Tab label
theme.tab_fg            = "#1577D3"
theme.tab_bg            = "#0A1535"
theme.tab_ntheme        = "#ddd"
theme.selected_fg       = "#0A1535"
theme.selected_bg       = "#1577D3"
theme.selected_ntheme   = "#ddd"
theme.loading_fg        = "#33AADD"
theme.loading_bg        = "#000"

-- Trusted/untrusted ssl colours
theme.trust_fg          = "#0F0"
theme.notrust_fg        = "#F00"

return theme
-- vim: et:sw=4:ts=8:sts=4:tw=80
