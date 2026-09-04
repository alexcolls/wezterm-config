local wezterm = require 'wezterm'
local config = wezterm.config_builder()

-- ---------------------------------------------------------------------------
-- Shared ANSI palette (used by all themes unless overridden)
-- ---------------------------------------------------------------------------
local ansi = {
  '#1B1D27',
  '#FF2E63',
  '#08F7BE',
  '#F9ED69',
  '#05D9E8',
  '#F70A8D',
  '#01FFC3',
  '#E0E5EC',
}

local brights = {
  '#31354A',
  '#FF4A7A',
  '#2EFC8F',
  '#FCE588',
  '#4BEAFA',
  '#FA4DB1',
  '#4AFADD',
  '#FFFFFF',
}

-- Tab bar uses the theme background so it matches the terminal; active tab uses selection color.
local function tab_bar_for_theme(t)
  local bg = t.background
  local active_bg = t.selection_bg or t.cursor_bg or t.foreground
  return {
    background = bg,
    active_tab = {
      bg_color = active_bg,
      fg_color = t.foreground,
      intensity = 'Bold',
    },
    inactive_tab = {
      bg_color = bg,
      fg_color = '#888888',
    },
    inactive_tab_hover = {
      bg_color = active_bg,
      fg_color = t.foreground,
    },
    new_tab = {
      bg_color = bg,
      fg_color = t.foreground,
    },
  }
end

local function make_theme(t)
  local cursor_bg = t.cursor_bg or t.foreground
  return {
    background = t.background,
    foreground = t.foreground,
    cursor_bg = cursor_bg,
    cursor_fg = t.cursor_fg or t.background,
    cursor_border = t.cursor_border or cursor_bg,
    selection_bg = t.selection_bg,
    selection_fg = t.selection_fg or '#FFFFFF',
    split = t.split or cursor_bg,
    ansi = t.ansi or ansi,
    brights = t.brights or brights,
    tab_bar = t.tab_bar or tab_bar_for_theme(t),
  }
end

-- ---------------------------------------------------------------------------
-- Theme definitions (full color tables for hot-swap)
-- ---------------------------------------------------------------------------
local themes = {
  make_theme { -- 1. Cyberpunk Base
    background = '#090B10',
    foreground = '#AEE2FF',
    cursor_bg = '#F70A8D',
    cursor_border = '#6B7280',
    selection_bg = '#391242',
    split = '#6B7280',
  },
  make_theme { -- 2. Mainframe Matrix
    background = '#050A05',
    foreground = '#00FF41',
    cursor_bg = '#00FF41',
    selection_bg = '#004A11',
    selection_fg = '#00FF41',
  },
  make_theme { -- 3. Miami Synthwave
    background = '#262335',
    foreground = '#36F9F6',
    cursor_bg = '#FF7EDB',
    selection_bg = '#49465C',
  },
  make_theme { -- 4. Old School CRT
    background = '#1A0B00',
    foreground = '#FFB000',
    cursor_bg = '#FFB000',
    selection_bg = '#664400',
    selection_fg = '#FFD700',
  },
  make_theme { -- 5. Blood Ice
    background = '#0A0000',
    foreground = '#FF2A2A',
    cursor_bg = '#00FFFF',
    selection_bg = '#4A0000',
  },
  make_theme { -- 6. Corpo Gold
    background = '#111111',
    foreground = '#D4AF37',
    cursor_bg = '#FFFFFF',
    selection_bg = '#4A3B10',
  },
  make_theme { -- 7. Netrunner
    background = '#001A22',
    foreground = '#00FFCC',
    cursor_bg = '#FF0055',
    selection_bg = '#004D66',
  },
  make_theme { -- 8. Toxic Waste
    background = '#0D0D0D',
    foreground = '#BFFF00',
    cursor_bg = '#8A2BE2',
    selection_bg = '#334C00',
  },
  make_theme { -- 9. Ghost Ops
    background = '#1E2127',
    foreground = '#ABB2BF',
    cursor_bg = '#56B6C2',
    selection_bg = '#3E4452',
  },
  make_theme { -- 10. Neon Pastel
    background = '#1E1E2E',
    foreground = '#D9E0EE',
    cursor_bg = '#F5C2E7',
    selection_bg = '#575268',
    selection_fg = '#F5C2E7',
  },
}

config.colors = themes[1]

-- ---------------------------------------------------------------------------
-- Theme hot-swap events (Alt+1..0)
-- ---------------------------------------------------------------------------
for i, theme in ipairs(themes) do
  wezterm.on('trigger-theme-' .. tostring(i), function(window)
    local overrides = window:get_config_overrides() or {}
    overrides.colors = theme
    window:set_config_overrides(overrides)
  end)
end

-- ---------------------------------------------------------------------------
-- Shell
-- ---------------------------------------------------------------------------
config.default_prog = { '/bin/bash' }

-- ---------------------------------------------------------------------------
-- Font & text
-- ---------------------------------------------------------------------------
config.font = wezterm.font('FiraCode Nerd Font', { weight = 'Thin' })
config.font_size = 11.0
config.line_height = 1.3

-- ---------------------------------------------------------------------------
-- Window
-- ---------------------------------------------------------------------------
config.window_decorations = 'NONE'
config.window_background_opacity = 0.8
config.macos_window_background_blur = 30
config.window_padding = { left = 20, right = 20, top = 20, bottom = 20 }

config.inactive_pane_hsb = { saturation = 0.5, brightness = 0.5 }

-- ---------------------------------------------------------------------------
-- Cursor & display
-- ---------------------------------------------------------------------------
config.default_cursor_style = 'BlinkingBlock'
config.animation_fps = 60
config.hide_tab_bar_if_only_one_tab = true

-- ---------------------------------------------------------------------------
-- Tab bar
-- ---------------------------------------------------------------------------
config.use_fancy_tab_bar = false
config.tab_bar_at_bottom = false
config.tab_max_width = 25

config.window_frame = {
  inactive_titlebar_bg = 'rgba(0, 0, 0, 0)',
  active_titlebar_bg = 'rgba(0, 0, 0, 0)',
}

-- ---------------------------------------------------------------------------
-- Key bindings
-- ---------------------------------------------------------------------------
local act = wezterm.action
local keys = {
  { key = 'Enter', mods = 'ALT', action = wezterm.action.ToggleFullScreen },

  -- Rename current tab (Alt+R)
  {
    key = 'r',
    mods = 'ALT',
    action = act.PromptInputLine {
      description = 'Rename tab',
      action = wezterm.action_callback(function(window, _pane, line)
        if line and #line > 0 then
          window:active_tab():set_title(line)
        end
      end),
    },
  },

  -- Split panes (Shift+Alt+Arrow)
  { key = 'UpArrow', mods = 'SHIFT|ALT', action = wezterm.action.SplitPane { direction = 'Up', size = { Percent = 50 } } },
  { key = 'DownArrow', mods = 'SHIFT|ALT', action = wezterm.action.SplitPane { direction = 'Down', size = { Percent = 50 } } },
  { key = 'LeftArrow', mods = 'SHIFT|ALT', action = wezterm.action.SplitPane { direction = 'Left', size = { Percent = 50 } } },
  { key = 'RightArrow', mods = 'SHIFT|ALT', action = wezterm.action.SplitPane { direction = 'Right', size = { Percent = 50 } } },

  -- Focus panes (Alt+Arrow)
  { key = 'LeftArrow', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Right' },
  { key = 'UpArrow', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Up' },
  { key = 'DownArrow', mods = 'ALT', action = wezterm.action.ActivatePaneDirection 'Down' },

  -- Switch tabs (next/prev)
  { key = 'Tab', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 'Tab', mods = 'CTRL|SHIFT', action = act.ActivateTabRelative(-1) },
  { key = 'PageDown', mods = 'CTRL', action = act.ActivateTabRelative(1) },
  { key = 'PageUp', mods = 'CTRL', action = act.ActivateTabRelative(-1) },
  -- Switch to tab by index (Ctrl+Shift+1..9; 9 = last tab)
  { key = '1', mods = 'CTRL|SHIFT', action = act.ActivateTab(0) },
  { key = '2', mods = 'CTRL|SHIFT', action = act.ActivateTab(1) },
  { key = '3', mods = 'CTRL|SHIFT', action = act.ActivateTab(2) },
  { key = '4', mods = 'CTRL|SHIFT', action = act.ActivateTab(3) },
  { key = '5', mods = 'CTRL|SHIFT', action = act.ActivateTab(4) },
  { key = '6', mods = 'CTRL|SHIFT', action = act.ActivateTab(5) },
  { key = '7', mods = 'CTRL|SHIFT', action = act.ActivateTab(6) },
  { key = '8', mods = 'CTRL|SHIFT', action = act.ActivateTab(7) },
  { key = '9', mods = 'CTRL|SHIFT', action = act.ActivateTab(-1) },
}

for i = 1, 10 do
  keys[#keys + 1] = {
    key = i == 10 and '0' or tostring(i),
    mods = 'ALT',
    action = wezterm.action.EmitEvent('trigger-theme-' .. tostring(i)),
  }
end

config.keys = keys

return config
