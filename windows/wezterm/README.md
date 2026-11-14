# WezTerm (Windows → WSL)

Config de [WezTerm](https://wezfurlong.org/wezterm/) sous Windows. Elle ouvre directement Ubuntu dans WSL. La version Mac est dans [`../../macos/wezterm`](../../macos/wezterm).

- Fichier : `.wezterm.lua`, à copier vers `%USERPROFILE%\.wezterm.lua` :
  `cp ~/dotfiles/windows/wezterm/.wezterm.lua /mnt/c/Users/<toi>/.wezterm.lua`
- Connexion à WSL par **SSH** sur `127.0.0.1:2222` (`USE_SSH = true`). Le domaine « WSL:Ubuntu » passe par ConPTY, qui bloque les images kitty (les figures matplotlib dans nvim).
- La mise en place unique (serveur SSH dans WSL, clé côté Windows, test) est décrite en commentaire en tête du fichier.
- Si SSH ne marche plus : `USE_SSH = false` pour revenir à « WSL:Ubuntu » (sans images).
- Au démarrage, WezTerm réveille Ubuntu et le garde allumé, sinon personne n'écoute sur le port 2222.

## Raccourcis clavier

Leader : **`Ctrl+<`** (1 seconde pour taper la touche suivante).

| Touche | Action |
|---|---|
| `Leader` puis `v` | couper en deux, côte à côte |
| `Leader` puis `h` | couper en deux, l'un au-dessus de l'autre |
| `Leader` puis `z` | agrandir / réduire le pane actif |
| `Ctrl+Entrée` / `Shift+Entrée` | envoyés à nvim comme `<C-CR>` / `<S-CR>` |
| `Ctrl+Tab` / `Ctrl+Shift+Tab` | laissés à nvim (`<C-Tab>`) au lieu de changer d'onglet |
