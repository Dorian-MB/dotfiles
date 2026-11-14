# Graph Report - dotfiles  (2026-11-14)

## Corpus Check
- 71 files · ~183,951 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 22 file(s) not represented in the graph (top: (none) 8, .toml 5, .css 2)
- WARNING: 22 of 93 files seen (24%) have no supported extractor and are missing from this graph entirely. It may look complete while representing only part of the codebase.

## Summary
- 717 nodes · 961 edges · 68 communities (43 shown, 25 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 6 edges (avg confidence: 0.57)
- Token cost: 56,893 input · 2,451 output

## Community Hubs (Navigation)
- GlazeWM Keybindings
- YASB Bar Layout
- Jupyter Kernel Bridge
- YASB Weather Widget
- YASB Pomodoro Widget
- SketchyBar Colors & Workspaces
- YASB Recycle Bin & Bluetooth
- jupynb Kernel Client
- jupynb Document Model
- jupynb Image Rendering
- jupynb Cell Rendering
- jupynb Cell Actions
- jupynb Config & Health
- jupynb Plugin Entry
- ipynb Parsing
- GlazeWM Window Effects
- YASB Click Callbacks
- jupynb Utilities
- YASB Popup Menus A
- YASB Systray Widget
- YASB Popup Menus B
- YASB Todo Labels
- YASB Power Menu
- Dotfiles Docs Overview
- jupynb Theme Colors
- YASB Media Widget
- YASB Clock Widget
- YASB Wallpapers Widget
- YASB Widget Types
- YASB Popup Menus C
- YASB CPU Widget
- YASB Popup Menus D
- YASB Popup Menus E
- YASB WiFi Widget
- YASB Disk Widget
- Savvy-flow Agents
- jupynb Table Rendering
- YASB GlazeWM Workspaces
- YASB Memory Widget
- YASB Brightness Widget
- YASB Weather Units
- YASB Volume Widget
- Claude Keybindings
- YASB GPU Thresholds
- SketchyBar Icon Map
- SketchyBar Aerospace Plugin
- SketchyBar Clock
- SketchyBar Front App
- SketchyBar Battery
- SketchyBar Reload
- SketchyBar Stats
- SketchyBar Volume
- CLI/TUI Docs

## God Nodes (most connected - your core abstractions)
1. `icons` - 31 edges
2. `menu` - 25 edges
3. `widgets` - 21 edges
4. `callbacks` - 20 edges
5. `weather_card` - 20 edges
6. `Bridge` - 19 edges
7. `label` - 18 edges
8. `label_alt` - 16 edges
9. `options` - 16 edges
10. `audio_menu` - 13 edges

## Surprising Connections (you probably didn't know these)
- `dotfiles README` --references--> `Neovim Config README`  [EXTRACTED]
  README.md → nvim/README.md
- `Claude Code Plugins` --references--> `savvy-flow skill`  [INFERRED]
  agents/plugins.md → agents/savvy-flow/skills/savvy-flow/SKILL.md
- `savvy-flow skill` --calls--> `savvy-careful`  [EXTRACTED]
  agents/savvy-flow/skills/savvy-flow/SKILL.md → agents/savvy-flow/agents/savvy-careful.md
- `savvy-flow skill` --calls--> `savvy-fable`  [EXTRACTED]
  agents/savvy-flow/skills/savvy-flow/SKILL.md → agents/savvy-flow/agents/savvy-fable.md
- `savvy-flow skill` --calls--> `savvy-heavy`  [EXTRACTED]
  agents/savvy-flow/skills/savvy-flow/SKILL.md → agents/savvy-flow/agents/savvy-heavy.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Savvy-Flow Multi-Agent System** — agents_savvyflow_skills_savvyflow_skill, agents_savvyflow_agents_savvyfable, agents_savvyflow_agents_savvyheavy, agents_savvyflow_agents_savvycareful, agents_savvyflow_agents_savvymedium, agents_savvyflow_agents_savvylight [EXTRACTED 1.00]
- **jupynb.nvim Plugin Stack** — nvim_jupynb_readme, nvim_jupynb_design, nvim_jupynb_nvim_python_jupynb_bridge, image_nvim, otter_nvim, render_markdown_nvim [EXTRACTED 1.00]

## Communities (68 total, 25 thin omitted)

### Community 0 - "GlazeWM Keybindings"
Cohesion: 0.04
Nodes (46): binding_modes, keybindings, name, enabled, trigger, centered, shown_on_top, maximized (+38 more)

### Community 1 - "YASB Bar Layout"
Cohesion: 0.05
Nodes (40): align, position, duration, enabled, bars, yasb-bar, border_color, dark_mode (+32 more)

### Community 2 - "Jupyter Kernel Bridge"
Cohesion: 0.11
Nodes (3): Bridge, _image_size(), send()

### Community 3 - "YASB Weather Widget"
Cohesion: 0.06
Nodes (34): default_view, enabled, rain_icon, snow_icon, temperature_icon, bottom_color, enabled, top_color (+26 more)

### Community 4 - "YASB Pomodoro Widget"
Cohesion: 0.06
Nodes (31): alignment, blur, border_color, circle_background_color, circle_break_progress_color, circle_size, circle_thickness, circle_work_progress_color (+23 more)

### Community 5 - "SketchyBar Colors & Workspaces"
Cohesion: 0.08
Nodes (17): CAT_BAR_BG, CAT_BAR_BG_ALT, CAT_BASE, CAT_BLUE, CAT_CLEAR, CAT_GREEN, CAT_ITEM_BG, CAT_MAROON (+9 more)

### Community 6 - "YASB Recycle Bin & Bluetooth"
Cohesion: 0.08
Nodes (25): add, bin_empty, bin_filled, bluetooth_connected, bluetooth_off, bluetooth_on, break, category (+17 more)

### Community 7 - "jupynb Kernel Client"
Cohesion: 0.19
Nodes (19): bridge_path(), discover_venvs(), flush_waiting(), handle_line(), M.execute(), M.get(), M.handle(), M.interrupt() (+11 more)

### Community 8 - "jupynb Document Model"
Cohesion: 0.16
Nodes (13): Doc:anchor(), Doc:cell_at(), Doc:cell_at_cursor(), Doc:fill(), Doc:rebuild(), Doc:scan(), Doc:sync(), Doc:to_nb() (+5 more)

### Community 9 - "jupynb Image Rendering"
Cohesion: 0.16
Nodes (13): api(), force_direct_transmit(), herdr_forwards_graphics(), M.available(), M.blocker(), M.cell_size(), M.clear(), M.clear_all() (+5 more)

### Community 10 - "jupynb Cell Rendering"
Cohesion: 0.21
Nodes (18): any_running(), header_chunks(), lang_icon(), lang_label(), M.cell_at_cached(), M.render(), M.render_active(), M.render_headers() (+10 more)

### Community 11 - "jupynb Cell Actions"
Cohesion: 0.30
Nodes (17): after_change(), cursor_cell(), focus(), get(), M.change_kind(), M.clear(), M.delete(), M.fix() (+9 more)

### Community 12 - "jupynb Config & Health"
Cohesion: 0.18
Nodes (9): M.check(), run(), html_table(), M.as_text(), M.image_path(), M.render(), pad(), pick_image() (+1 more)

### Community 13 - "jupynb Plugin Entry"
Cohesion: 0.18
Nodes (10): ensure_setup(), M.activate_otter(), M.attach(), M.lsp_for(), M.new_file(), M.open(), M.read(), M.setup() (+2 more)

### Community 14 - "ipynb Parsing"
Cohesion: 0.17
Nodes (11): M.empty(), M.load(), M.normalize(), M.outputs_for_disk(), M.to_nb(), encode(), encode_number(), encode_string() (+3 more)

### Community 15 - "GlazeWM Window Effects"
Cohesion: 0.16
Nodes (18): color, enabled, enabled, style, border, corner_style, hide_title_bar, transparency (+10 more)

### Community 16 - "YASB Click Callbacks"
Cohesion: 0.16
Nodes (18): options, on_left, on_middle, on_right, options, options, options, type (+10 more)

### Community 18 - "YASB Popup Menus A"
Cohesion: 0.15
Nodes (13): alignment, blur, border_color, direction, offset_left, offset_top, round_corners, round_corners_type (+5 more)

### Community 19 - "YASB Systray Widget"
Cohesion: 0.15
Nodes (13): icon_size, label_collapsed, label_expanded, label_position, pin_click_modifier, show_battery, show_network, show_unpinned (+5 more)

### Community 20 - "YASB Popup Menus B"
Cohesion: 0.17
Nodes (12): alignment, blur, border_color, direction, extended, offset_left, offset_top, round_corners (+4 more)

### Community 21 - "YASB Todo Labels"
Cohesion: 0.18
Nodes (11): default, important, soon, today, urgent, label, label, categories (+3 more)

### Community 22 - "YASB Power Menu"
Cohesion: 0.18
Nodes (11): animation_duration, blur, blur_background, button_row, buttons, profile_image_size, show_user, uptime (+3 more)

### Community 23 - "Dotfiles Docs Overview"
Cohesion: 0.20
Nodes (10): AeroSpace, dotfiles README, herdr, image.nvim, jupynb.nvim Design, jupynb.nvim README, Neovim Config README, otter.nvim (+2 more)

### Community 24 - "jupynb Theme Colors"
Cohesion: 0.42
Nodes (9): blend(), first(), groups(), hex(), hl(), luminance(), M.apply(), palette() (+1 more)

### Community 25 - "YASB Media Widget"
Cohesion: 0.20
Nodes (10): options, type, options, type, hide_empty, label_device_separator, label_no_device, tooltip (+2 more)

### Community 26 - "YASB Clock Widget"
Cohesion: 0.20
Nodes (10): options, type, image_path, locale, timezones, update_interval, options, type (+2 more)

### Community 27 - "YASB Wallpapers Widget"
Cohesion: 0.20
Nodes (10): blur, enabled, image_corner_radius, image_per_page, image_spacing, image_width, lazy_load, lazy_load_fadein (+2 more)

### Community 29 - "YASB Widget Types"
Cohesion: 0.22
Nodes (9): type, type, type, type, widgets, bin, ethernet, gpu (+1 more)

### Community 30 - "YASB Popup Menus C"
Cohesion: 0.22
Nodes (9): alignment, blur, border_color, direction, offset_left, offset_top, round_corners, round_corners_type (+1 more)

### Community 31 - "YASB CPU Widget"
Cohesion: 0.22
Nodes (9): options, high, low, medium, type, cpu_thresholds, histogram_icons, histogram_num_columns (+1 more)

### Community 32 - "YASB Popup Menus D"
Cohesion: 0.22
Nodes (9): alignment, blur, border_color, direction, round_corners, round_corners_type, show_label_name, volume_labels (+1 more)

### Community 33 - "YASB Popup Menus E"
Cohesion: 0.22
Nodes (9): alignment, blur, border_color, direction, offset_left, offset_top, round_corners, round_corners_type (+1 more)

### Community 34 - "YASB WiFi Widget"
Cohesion: 0.22
Nodes (9): ethernet_icon, ethernet_label, ethernet_label_alt, get_exact_wifi_strength, hide_if_ethernet, wifi_icons, wifi, options (+1 more)

### Community 35 - "YASB Disk Widget"
Cohesion: 0.25
Nodes (8): options, high, low, medium, type, disk_thresholds, volume_label, disk

### Community 36 - "Savvy-flow Agents"
Cohesion: 0.29
Nodes (7): Claude Code Plugins, savvy-careful, savvy-fable, savvy-heavy, savvy-light, savvy-medium, savvy-flow skill

### Community 37 - "jupynb Table Rendering"
Cohesion: 0.43
Nodes (3): clean(), M.parse(), parse_rows()

### Community 38 - "YASB GlazeWM Workspaces"
Cohesion: 0.29
Nodes (7): options, type, enable_scroll_switching, hide_if_offline, monitor_exclusive, offline_label, glazewm_workspaces

### Community 39 - "YASB Memory Widget"
Cohesion: 0.29
Nodes (7): options, high, low, medium, type, memory_thresholds, memory

### Community 41 - "YASB Brightness Widget"
Cohesion: 0.40
Nodes (5): options, type, brightness_icons, brightness_toggle_level, brightness

### Community 42 - "YASB Weather Units"
Cohesion: 0.40
Nodes (5): options, type, hide_decimal, units, open_meteo

### Community 43 - "YASB Volume Widget"
Cohesion: 0.40
Nodes (5): scroll_step, slider_beep, options, type, volume

### Community 44 - "Claude Keybindings"
Cohesion: 0.50
Nodes (3): bindings, $docs, $schema

### Community 45 - "YASB GPU Thresholds"
Cohesion: 0.50
Nodes (4): high, low, medium, gpu_thresholds

## Knowledge Gaps
- **28 isolated node(s):** `CAT_BASE`, `CAT_TEXT`, `CAT_SURFACE1`, `CAT_ITEM_BG`, `CAT_BAR_BG` (+23 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 417 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **25 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `widgets` connect `YASB Widget Types` to `YASB Bar Layout`, `YASB WiFi Widget`, `YASB Disk Widget`, `YASB GlazeWM Workspaces`, `YASB Memory Widget`, `YASB Brightness Widget`, `YASB Weather Units`, `YASB Volume Widget`, `YASB Click Callbacks`, `YASB Systray Widget`, `YASB Power Menu`, `YASB Media Widget`, `YASB Clock Widget`, `YASB CPU Widget`?**
  _High betweenness centrality (0.068) - this node is a cross-community bridge._
- **What connects `CAT_BASE`, `CAT_TEXT`, `CAT_SURFACE1` to the rest of the system?**
  _28 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `GlazeWM Keybindings` be split into smaller, more focused modules?**
  _Cohesion score 0.04440333024976873 - nodes in this community are weakly interconnected._
- **Why does `options` connect `YASB Weather Units` to `YASB Click Callbacks`, `YASB Media Widget`, `YASB Clock Widget`, `YASB Weather Widget`?**
  _High betweenness centrality (0.044) - this node is a cross-community bridge._
- **Should `YASB Bar Layout` be split into smaller, more focused modules?**
  _Cohesion score 0.04878048780487805 - nodes in this community are weakly interconnected._
- **Why does `weather_card` connect `YASB Weather Widget` to `YASB Weather Units`?**
  _High betweenness centrality (0.041) - this node is a cross-community bridge._
- **Should `Jupyter Kernel Bridge` be split into smaller, more focused modules?**
  _Cohesion score 0.10873440285204991 - nodes in this community are weakly interconnected._