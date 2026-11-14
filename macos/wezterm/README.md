# WezTerm (macOS)

Config du terminal [WezTerm](https://wezfurlong.org/wezterm/), le terminal secondaire. La version Windows est dans [`../../windows/wezterm`](../../windows/wezterm).

- Fichier : `wezterm.lua`. Le dossier est lié à `~/.config/wezterm` (`./install.sh macos/wezterm`).
- Catppuccin Macchiato, `JetBrainsMono Nerd Font` 19 sans ligatures, fond à 85 % d'opacité avec flou, pas de barre d'onglets.
- Protocole graphique kitty activé : figures matplotlib dans nvim (jupynb.nvim).
- Image de fond : désactivée (`enable_background = false`).

## Raccourcis clavier

Leader : **`Ctrl+<`** (1 seconde pour taper la touche suivante).

| Touche | Action |
|---|---|
| `Leader` puis `v` | couper en deux, côte à côte |
| `Leader` puis `h` | couper en deux, l'un au-dessus de l'autre |
| `Leader` puis `z` | agrandir / réduire le pane actif |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | laissés à nvim (`<C-Tab>`) au lieu de changer d'onglet |
