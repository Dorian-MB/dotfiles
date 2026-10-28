-- WezTerm Windows -> WSL (Ubuntu). Base : ../../wezterm/wezterm.lua (mac).
-- A copier dans C:\Users\dorian.mariani\.wezterm.lua :
--   cp ~/dotfiles/windows/wezterm/wezterm.lua /mnt/c/Users/dorian.mariani/.wezterm.lua
--
-- Pourquoi SSH : le domaine "WSL:Ubuntu" passe par ConPTY, qui supprime les
-- images kitty (figures matplotlib dans nvim) et ne remonte pas la taille des
-- cellules en pixels. Une connexion SSH directe vers WSL n'a pas ce pont.
--
-- Mise en place (une fois, depuis WSL) :
--
--   # 1. serveur SSH : cle uniquement, un seul utilisateur, port 2222
--   sudo apt install -y openssh-server
--   printf '%s\n' 'Port 2222' 'PasswordAuthentication no' 'KbdInteractiveAuthentication no' \
--     'PermitRootLogin no' 'AllowUsers dorianmariani' | sudo tee /etc/ssh/sshd_config.d/wezterm.conf
--   sudo systemctl daemon-reload && sudo systemctl restart ssh.socket
--   ss -ltn | grep 2222            # doit afficher une ligne
--
--   # 2. cle cote Windows (sans passphrase, n'ouvre que localhost:2222), autorisee dans WSL
--   mkdir -p /mnt/c/Users/dorian.mariani/.ssh
--   /mnt/c/Windows/System32/OpenSSH/ssh-keygen.exe -t ed25519 -N "" -C wezterm-wsl -f 'C:\Users\dorian.mariani\.ssh\wezterm_wsl'
--   mkdir -p ~/.ssh && chmod 700 ~/.ssh
--   tr -d '\r' < /mnt/c/Users/dorian.mariani/.ssh/wezterm_wsl.pub >> ~/.ssh/authorized_keys && chmod 600 ~/.ssh/authorized_keys
--
--   # 3. test depuis Windows (doit afficher "ok")
--   /mnt/c/Windows/System32/OpenSSH/ssh.exe -i 'C:\Users\dorian.mariani\.ssh\wezterm_wsl' -p 2222 dorianmariani@127.0.0.1 echo ok
--
-- En cas de probleme (sshd arrete, cle perdue...) : passer USE_SSH a false
-- pour revenir au domaine "WSL:Ubuntu" (ConPTY, sans images).

local wezterm = require("wezterm")
local config = wezterm.config_builder()

local USE_SSH = true

config.ssh_domains = {
	{
		name = "wsl-ssh",
		remote_address = "127.0.0.1:2222",
		username = "dorianmariani",
		multiplexing = "None", -- pty SSH directe : images + touches intactes
		ssh_option = { identityfile = "C:/Users/dorian.mariani/.ssh/wezterm_wsl" },
	},
}
config.default_domain = USE_SSH and "wsl-ssh" or "WSL:Ubuntu"

-- En SSH, wezterm ne demarre plus WSL tout seul : apres un reboot (ou
-- `wsl --shutdown`) personne n'ecoute sur 2222. On reveille Ubuntu une fois
-- (systemd lance alors ssh.socket). GLOBAL survit aux rechargements de config.
if USE_SSH and not wezterm.GLOBAL.wsl_started then
	wezterm.GLOBAL.wsl_started = true
	wezterm.run_child_process({ "wsl.exe", "-d", "Ubuntu", "--exec", "true" })
end

config.automatically_reload_config = true
config.adjust_window_size_when_changing_font_size = false
config.enable_tab_bar = false
config.window_decorations = "RESIZE"
config.window_close_confirmation = "NeverPrompt"
config.color_scheme = "Catppuccin Macchiato"
config.max_fps = 120
config.font_size = 16
config.font = wezterm.font_with_fallback({
	{
		family = "JetBrainsMono Nerd Font",
		weight = "Medium",
		harfbuzz_features = { "calt=0", "clig=0", "liga=0" },
	},
	{ family = "Terminus", weight = "Bold" },
	"Noto Color Emoji",
})
config.bold_brightens_ansi_colors = false

config.window_background_opacity = 0.85

-- Figures matplotlib dans nvim (jupynb.nvim / image.nvim) : desactive par defaut.
config.enable_kitty_graphics = true

-- Leader CTRL+< (comme dans tmux)
config.leader = { key = "<", mods = "CTRL", timeout_milliseconds = 1000 }

config.keys = {
	-- Ctrl/Shift+Enter envoyes en CSI u, lus par nvim comme <C-CR> / <S-CR>
	-- (indispensable en repli "WSL:Ubuntu" : ConPTY ne sait pas les encoder).
	{ key = "Enter", mods = "CTRL", action = wezterm.action.SendString("\x1b[13;5u") },
	{ key = "Enter", mods = "SHIFT", action = wezterm.action.SendString("\x1b[13;2u") },

	-- La barre d'onglets est desactivee, mais wezterm garde ses raccourcis
	-- d'onglets par defaut et avale CTRL+Tab. On les rend au terminal pour que
	-- <C-Tab> de nvim (mappings.lua) fonctionne.
	{ key = "Tab", mods = "CTRL", action = wezterm.action.DisableDefaultAssignment },
	{ key = "Tab", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },

	-- Diviser verticalement avec Leader + v
	{
		key = "v",
		mods = "LEADER",
		action = wezterm.action.SplitHorizontal({ domain = "CurrentPaneDomain" }),
	},
	-- Diviser horizontalement avec Leader + h
	{
		key = "h",
		mods = "LEADER",
		action = wezterm.action.SplitVertical({ domain = "CurrentPaneDomain" }),
	},
	-- Zoomer/Agrandir le volet actuel avec Leader + z
	{
		key = "z",
		mods = "LEADER",
		action = wezterm.action.TogglePaneZoomState,
	},
}

return config
