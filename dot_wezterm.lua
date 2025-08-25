-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action -- Action API alias

-- This table will hold the configuration
local config = {}

-- In newer versions of Wezterm, use the config_builder which allows applying
-- multiple defaults sources.
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- Disable Kitty Keyboard Protocol to fix Ctrl+Shift+P
-- config.enable_kitty_keyboard_protocol = false
-- config.enable_csi_u_key_encoding = false -- Try disabling CSI u codes instead

-- ========= Background Image (Corrected & Cleaned - Using io.open check) =========

-- Get the directory where the configuration file is located (~/.wezterm.lua -> points to home dir)
local config_dir = wezterm.config_dir or ""

-- Construct the path relative to the configuration file directory
local image_filename = "background.png" -- Make sure this matches your actual file name
local background_image_path = config_dir .. "/" .. image_filename

-- Add logging to see exactly what path is being checked
wezterm.log_info("Checking for background image at path: " .. background_image_path)

-- Check if the file exists before setting it using io.open
local f = io.open(background_image_path, "r")
if f then
	-- File exists! Close the handle.
	f:close()
	wezterm.log_info("Background image FOUND! Applying: " .. background_image_path)
	-- config.window_background_image = background_image_path -- Commented out for solid color background

	-- Dim the background image (Using 1.0 brightness for TESTING!)
	config.window_background_image_hsb = {
		brightness = 0.2, -- Use 1.0 (full brightness) for testing! Adjust later (e.g., 0.3).
		hue = 1.0,
		saturation = 1.0,
	}
else
	-- File does not exist or isn't readable.
	wezterm.log_error(
		"Background image NOT FOUND or not readable at: "
			.. background_image_path
			.. " (config_dir was: "
			.. config_dir
			.. ")"
	)
end
-- (Rest of the config follows...)
-- ========= Theme and Appearance =========

-- Set colors manually for black/dark-gray background
config.colors = {
	background = "#1a1a1a", -- Dark gray background
	-- Alternative: use "#000000" for pure black
}

-- Font configuration
config.font = wezterm.font_with_fallback({
	"FiraCode Nerd Font", -- Ensure this Nerd Font is installed
	"Symbols Nerd Font Mono",
	"Noto Color Emoji",
})
config.font_size = 16.0

-- Makes the WHOLE window semi-transparent
-- 1.0 = Opaque (Default)
-- 0.0 = Fully Transparent (Invisible)
-- Values between 0.7 and 0.95 are common for transparency.
config.window_background_opacity = 0.95 -- Adjust this value to your liking

-- Enable font ligatures
config.harfbuzz_features = { "calt=1", "clig=1", "liga=1" }

-- Window padding
config.window_padding = {
	left = 10,
	right = 10,
	top = 10,
	bottom = 5,
}

-- Tab bar settings
config.use_fancy_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true

-- ========= Keybindings =========
wezterm.log_info("Using custom keybindings")
config.leader = { key = "a", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	-- macOS Option key as Meta (won't harm on Linux)
	{ key = "LeftArrow", mods = "OPT", action = act.SendString("\x1bb") },
	{ key = "RightArrow", mods = "OPT", action = act.SendString("\x1bf") },
	-- Pane Splitting
	{ key = "%", mods = "SHIFT|ALT", action = act.SplitHorizontal({ domain = "CurrentPaneDomain" }) },
	{ key = '"', mods = "SHIFT|ALT", action = act.SplitVertical({ domain = "CurrentPaneDomain" }) },
	-- Pane Navigation
	{ key = "h", mods = "ALT", action = act.ActivatePaneDirection("Left") },
	{ key = "j", mods = "ALT", action = act.ActivatePaneDirection("Down") },
	{ key = "k", mods = "ALT", action = act.ActivatePaneDirection("Up") },
	{ key = "l", mods = "ALT", action = act.ActivatePaneDirection("Right") },
	-- Pane Resizing
	{ key = "H", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Left", 5 }) },
	{ key = "J", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Down", 5 }) },
	{ key = "K", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Up", 5 }) },
	{ key = "L", mods = "LEADER|SHIFT", action = act.AdjustPaneSize({ "Right", 5 }) },
	-- Pane Management
	{ key = "z", mods = "ALT", action = act.TogglePaneZoomState },
	{ key = "x", mods = "ALT", action = act.CloseCurrentPane({ confirm = true }) },
	-- Tab Navigation
	{ key = "[", mods = "ALT", action = act.ActivateTabRelative(-1) },
	{ key = "]", mods = "ALT", action = act.ActivateTabRelative(1) },
	{ key = "n", mods = "ALT", action = act.ShowTabNavigator },
	-- Tab Management
	{ key = "t", mods = "SUPER", action = act.SpawnTab("CurrentPaneDomain") },
	{ key = "w", mods = "SUPER", action = act.CloseCurrentTab({ confirm = true }) },
	{ key = "Tab", mods = "CTRL", action = act.ActivateTabRelative(1) },
	{ key = "Tab", mods = "CTRL|SHIFT", action = act.ActivateTabRelative(-1) },
	-- Copy/Paste
	{ key = "c", mods = "SUPER", action = act.CopyTo("Clipboard") },
	{ key = "v", mods = "SUPER", action = act.PasteFrom("Clipboard") },
	-- Font size
	{ key = "+", mods = "CTRL", action = act.IncreaseFontSize },
	{ key = "-", mods = "CTRL", action = act.DecreaseFontSize },
	{ key = "0", mods = "CTRL", action = act.ResetFontSize },
	-- Scrollback
	{ key = "PageUp", mods = "SHIFT", action = act.ScrollByPage(-1) },
	{ key = "PageDown", mods = "SHIFT", action = act.ScrollByPage(1) },
	-- Launchers
	{ key = "L", mods = "CTRL|SHIFT", action = act.ShowLauncher },
	{ key = "P", mods = "CTRL|SHIFT", action = act.ActivateCommandPalette }, -- Should work now
	-- URL Selection
	{
		key = "u",
		mods = "CTRL|SHIFT",
		action = act.QuickSelectArgs({
			label = "open url",
			patterns = { "\\b\\w+://(?:[\\w.-]+|\\ P {Ip_Address})(?::\\d+)?(?:/\\S*)?" },
			action = wezterm.action_callback(function(window, pane)
				local url = window:get_selection_text_for_pane(pane)
				wezterm.log_info("Opening URL: " .. url)
				wezterm.open_with(url)
			end),
		}),
	},
}
-- Add bindings for Super+1..9
for i = 1, 9 do
	table.insert(config.keys, { key = tostring(i), mods = "SUPER", action = act.ActivateTab(i - 1) })
end

-- ========= Status Bar =========
config.enable_tab_bar = true

-- Function definition (needed by status bar)
local function get_git_branch()
	-- Using pcall to gracefully handle errors if git isn't found
	local success, result = pcall(wezterm.run_child_process, { "git", "rev-parse", "--abbrev-ref", "HEAD" })
	if success and result[1] == 0 then -- Check both pcall success and process exit code
		local branch = result[2]:gsub("[\r\n]", "") -- stdout is result[2]
		if branch ~= "" then
			return "  " .. branch -- Nerd Font Git icon
		end
	else
		-- Log error only if pcall failed or process returned error, not just if not a git repo
		if not success then
			wezterm.log_error("pcall failed for get_git_branch: ", result)
		elseif result[1] ~= 0 then
			wezterm.log_info(
				"get_git_branch failed (exit code "
					.. result[1]
					.. "), likely not a git repo or git not found. Stderr: "
					.. result[3]
			)
		end
	end
	return ""
end

-- Function definition (needed by status bar)
local function format_cwd(cwd)
	local home = os.getenv("HOME")
	if home and cwd and cwd:find(home, 1, true) == 1 then
		cwd = "~" .. cwd:sub(#home + 1)
	end
	return "  " .. (cwd or "") -- Nerd Font Folder icon
end

-- Define status bar elements (Corrected version - Git errors handled)
wezterm.on("update-right-status", function(window, pane)
	local elements = {}

	-- Git Branch (Error handled)
	local git_branch = get_git_branch()
	if git_branch ~= "" then
		table.insert(elements, git_branch)
	end

	-- Current Working Directory
	local cwd_uri = pane:get_current_working_dir()
	if cwd_uri then
		-- cwd_uri might be file://hostname/path -> extract path
		local cwd_path = cwd_uri.path or cwd_uri -- Handle both URI and plain path objects
		table.insert(elements, format_cwd(cwd_path))
	end

	-- Workspace Name
	table.insert(elements, " 󰣇 " .. window:active_workspace()) -- Nerd Font Desktop icon

	-- Clock
	table.insert(elements, "  " .. wezterm.strftime("%H:%M")) -- Nerd Font Clock icon

	-- Assemble the status string
	window:set_right_status(wezterm.format(elements))
end)

-- Customize Tab Titles (Corrected version - no nerd_glyph_width)
wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
	local pane = tab.active_pane
	-- If the pane title is nil, use the process name
	local title = pane.title or pane:get_foreground_process_name():match("([^/]+)$") or ""

	-- Basic title formatting
	local index = tab.tab_index + 1
	local prefix = string.format("%d: ", index)

	-- Simplified max width calculation
	local available_width = max_width - string.len(prefix) - 1
	if available_width < 1 then
		available_width = 1
	end

	if #title > available_width then
		title = wezterm.truncate_right(title, available_width)
	end

	return {
		{ Text = prefix .. title },
	}
end)

-- ========= Other Settings =========
config.scrollback_lines = 5000
config.hyperlink_rules = wezterm.default_hyperlink_rules()
config.default_domain = "local"
config.audible_bell = "Disabled"
config.window_close_confirmation = "AlwaysPrompt"
config.warn_about_missing_glyphs = false -- Suppress the glyph warning if desired

-- ========= Final Return =========
return config
