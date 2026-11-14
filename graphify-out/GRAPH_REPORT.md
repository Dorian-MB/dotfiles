# Graph Report - dotfiles  (2026-11-14)

## Corpus Check
- 68 files · ~73,222 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 23 file(s) not represented in the graph (top: (none) 9, .toml 5, .css 2)
- WARNING: 23 of 91 files seen (25%) have no supported extractor and are missing from this graph entirely. It may look complete while representing only part of the codebase.

## Summary
- 331 nodes · 485 edges · 50 communities (17 shown, 33 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 6 edges (avg confidence: 0.57)
- Token cost: 2,273 input · 1,957 output

## Community Hubs (Navigation)
- Jupyter Kernel Bridge
- SketchyBar Colors & Bar Setup
- jupynb Kernel Client
- jupynb Document Model
- jupynb Image Rendering
- jupynb Cell Rendering
- jupynb Config & Output
- jupynb Cell Actions
- jupynb Plugin Entry
- ipynb Parsing
- jupynb Utilities
- jupynb Theme Colors
- Savvy-flow Agents
- jupynb Table Rendering
- jupynb Docs & Deps
- Claude Keybindings
- Docs Index
- Install & Shell Docs
- SketchyBar Icon Map
- Install Script
- SketchyBar Aerospace Plugin
- SketchyBar Clock
- SketchyBar Front App
- SketchyBar Battery
- SketchyBar Reload
- SketchyBar Stats
- SketchyBar Volume
- CLI/TUI Docs
- Herdr Docs
- AeroSpace Docs
- Ghostty Docs
- SketchyBar Docs
- WezTerm Docs
- Starship Docs
- Windows WM Docs
- Windows WezTerm Docs
- WSL Docs

## God Nodes (most connected - your core abstractions)
1. `Bridge` - 19 edges
2. `cursor_cell()` - 12 edges
3. `send()` - 12 edges
4. `focus()` - 10 edges
5. `encode()` - 8 edges
6. `M.render_headers()` - 8 edges
7. `after_change()` - 7 edges
8. `Doc:sync()` - 7 edges
9. `M.send()` - 7 edges
10. `palette()` - 7 edges

## Surprising Connections (you probably didn't know these)
- `Claude Code Plugins` --references--> `savvy-flow skill`  [INFERRED]
  agents/plugins.md → agents/savvy-flow/skills/savvy-flow/SKILL.md
- `savvy-flow skill` --calls--> `savvy-careful`  [EXTRACTED]
  agents/savvy-flow/skills/savvy-flow/SKILL.md → agents/savvy-flow/agents/savvy-careful.md
- `savvy-flow skill` --calls--> `savvy-fable`  [EXTRACTED]
  agents/savvy-flow/skills/savvy-flow/SKILL.md → agents/savvy-flow/agents/savvy-fable.md
- `savvy-flow skill` --calls--> `savvy-heavy`  [EXTRACTED]
  agents/savvy-flow/skills/savvy-flow/SKILL.md → agents/savvy-flow/agents/savvy-heavy.md
- `savvy-flow skill` --calls--> `savvy-light`  [EXTRACTED]
  agents/savvy-flow/skills/savvy-flow/SKILL.md → agents/savvy-flow/agents/savvy-light.md

## Import Cycles
- None detected.

## Hyperedges (group relationships)
- **Zsh Startup Sequence** — zsh_config [EXTRACTED 0.90]
- **jupynb.nvim Plugin Stack** — nvim_jupynb_readme, nvim_jupynb_design, nvim_jupynb_nvim_python_jupynb_bridge, image_nvim, otter_nvim, render_markdown_nvim [EXTRACTED 1.00]
- **Savvy-Flow Multi-Agent System** — agents_savvyflow_skills_savvyflow_skill, agents_savvyflow_agents_savvyfable, agents_savvyflow_agents_savvyheavy, agents_savvyflow_agents_savvycareful, agents_savvyflow_agents_savvymedium, agents_savvyflow_agents_savvylight [EXTRACTED 1.00]
- **macOS Desktop Environment** — macos_sketchybar, macos_aerospace, macos_wezterm, macos_ghostty [INFERRED 0.80]

## Communities (50 total, 33 thin omitted)

### Community 0 - "Jupyter Kernel Bridge"
Cohesion: 0.11
Nodes (3): Bridge, _image_size(), send()

### Community 1 - "SketchyBar Colors & Bar Setup"
Cohesion: 0.09
Nodes (16): CAT_BAR_BG, CAT_BAR_BG_ALT, CAT_BASE, CAT_BLUE, CAT_CLEAR, CAT_GREEN, CAT_ITEM_BG, CAT_MAROON (+8 more)

### Community 2 - "jupynb Kernel Client"
Cohesion: 0.19
Nodes (19): bridge_path(), discover_venvs(), flush_waiting(), handle_line(), M.execute(), M.get(), M.handle(), M.interrupt() (+11 more)

### Community 3 - "jupynb Document Model"
Cohesion: 0.16
Nodes (13): Doc:anchor(), Doc:cell_at(), Doc:cell_at_cursor(), Doc:fill(), Doc:rebuild(), Doc:scan(), Doc:sync(), Doc:to_nb() (+5 more)

### Community 4 - "jupynb Image Rendering"
Cohesion: 0.16
Nodes (13): api(), force_direct_transmit(), herdr_forwards_graphics(), M.available(), M.blocker(), M.cell_size(), M.clear(), M.clear_all() (+5 more)

### Community 5 - "jupynb Cell Rendering"
Cohesion: 0.21
Nodes (18): any_running(), header_chunks(), lang_icon(), lang_label(), M.cell_at_cached(), M.render(), M.render_active(), M.render_headers() (+10 more)

### Community 6 - "jupynb Config & Output"
Cohesion: 0.16
Nodes (9): M.check(), run(), html_table(), M.as_text(), M.image_path(), M.render(), pad(), pick_image() (+1 more)

### Community 7 - "jupynb Cell Actions"
Cohesion: 0.30
Nodes (17): after_change(), cursor_cell(), focus(), get(), M.change_kind(), M.clear(), M.delete(), M.fix() (+9 more)

### Community 8 - "jupynb Plugin Entry"
Cohesion: 0.18
Nodes (10): ensure_setup(), M.activate_otter(), M.attach(), M.lsp_for(), M.new_file(), M.open(), M.read(), M.setup() (+2 more)

### Community 9 - "ipynb Parsing"
Cohesion: 0.17
Nodes (11): M.empty(), M.load(), M.normalize(), M.outputs_for_disk(), M.to_nb(), encode(), encode_number(), encode_string() (+3 more)

### Community 11 - "jupynb Theme Colors"
Cohesion: 0.42
Nodes (9): blend(), first(), groups(), hex(), hl(), luminance(), M.apply(), palette() (+1 more)

### Community 13 - "Savvy-flow Agents"
Cohesion: 0.29
Nodes (7): Claude Code Plugins, savvy-careful, savvy-fable, savvy-heavy, savvy-light, savvy-medium, savvy-flow skill

### Community 14 - "jupynb Table Rendering"
Cohesion: 0.43
Nodes (3): clean(), M.parse(), parse_rows()

### Community 15 - "jupynb Docs & Deps"
Cohesion: 0.33
Nodes (6): image.nvim, jupynb.nvim Design, jupynb.nvim README, Neovim Config README, otter.nvim, render-markdown.nvim

### Community 17 - "Claude Keybindings"
Cohesion: 0.50
Nodes (3): bindings, $docs, $schema

### Community 18 - "Docs Index"
Cohesion: 0.50
Nodes (4): Claude Code Plugins Documentation, CLI Tools Documentation, Neovim Documentation, dotfiles README

### Community 19 - "Install & Shell Docs"
Cohesion: 0.50
Nodes (4): Install Script, Neovim Config, Zsh Config, Zsh Secret Config

## Knowledge Gaps
- **39 isolated node(s):** `CAT_BASE`, `CAT_TEXT`, `CAT_SURFACE1`, `CAT_ITEM_BG`, `CAT_BAR_BG` (+34 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 148 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **33 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `jupynb.nvim Design` connect `jupynb Docs & Deps` to `Jupyter Kernel Bridge`?**
  _High betweenness centrality (0.003) - this node is a cross-community bridge._
- **What connects `CAT_BASE`, `CAT_TEXT`, `CAT_SURFACE1` to the rest of the system?**
  _39 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Jupyter Kernel Bridge` be split into smaller, more focused modules?**
  _Cohesion score 0.10873440285204991 - nodes in this community are weakly interconnected._
- **Should `SketchyBar Colors & Bar Setup` be split into smaller, more focused modules?**
  _Cohesion score 0.08695652173913043 - nodes in this community are weakly interconnected._
- **Should `jupynb Utilities` be split into smaller, more focused modules?**
  _Cohesion score 0.14285714285714285 - nodes in this community are weakly interconnected._