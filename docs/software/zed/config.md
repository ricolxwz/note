---
title: 配置
comments: true
---


## 主配置

```json
{
  "minimum_split_diff_width": 0.0,
  "buffer_line_height": "comfortable",
  "agent_ui_font_size": 13.0,
  "cursor_shape": "bar",
  "reduce_motion": "off",
  "current_line_highlight": "all",
  "show_wrap_guides": false,
  "cursor_animation": {
    "enabled": true
  },
  "ui_font_weight": 500.0,
  "buffer_font_weight": 500.0,
  "use_system_path_prompts": true,
  "language_models": {
    "opencode": {
      "show_go_models": false,
      "show_zen_models": false
    }
  },
  "git": { "inline_blame": {
                "show_commit_summary": true,
                "location": "inline"
           },
           "diff_base": "head" },

  "search": {
    "search_on_type": false,
    "include_ignored": false,
    "regex": false
  },

  "file_scan_exclusions": [
    "**/AppData/**",
    "**/Local Settings/**",
    "**/Temp/**",
    "**/.codex/tmp/**",
    "**/.local/share/wezterm/**",
    "**/build/**",
    "**/cmake-build-*/**",
    "**/out/**",
    "**/output/**",
    "**/dist/**",
    "**/.cache/**",
    "**/node_modules/**",
    "**/target/**",
    "**/__pycache__/**",
    "**/.pytest_cache/**",
    "**/.mypy_cache/**",
    "**/.ruff_cache/**",
    "**/.venv/**",
    "**/venv/**",
    "**/*.log",
    "**/*.sock",
    "**/NTUSER.DAT*"
  ],

  "file_scan_depth": 2,
  "scan_symlinks": "expanded",
  "document_symbols": "off",

  "diagnostics_max_severity": "off",

  "diagnostics": {
    "inline": { "enabled": false }
  },

  "scrollbar": {
    "diagnostics": "none"
  },

  "tabs": {
    "show_diagnostics": "off"
  },

  "lsp": {
    "clangd": {
      "binary": {
        "arguments": ["--background-index"]
      }
    }
  },

  "project_panel": {
    "dock": "left",
    "git_status": true,
    "button": true,
    "show_diagnostics": "off"
  },

  "outline_panel": { "dock": "left" },
  
  "minimap": {
    "show": "always"
  },

  "git_panel": {
    "starts_open": true,
    "dock": "left"
  },

  "debugger": { "button": false },

  "collaboration_panel": {
    "dock": "left",
    "button": false
  },

  "markdown_preview": {
    "code_font_family": "Maple Mono Normal NL NF CN",
    "font_family": "Maple Mono Normal NL NF CN"
  },

  "agent": {
    "show_turn_stats": true,
    "dock": "right",
    "expand_terminal_card": false,
    "enable_feedback": false,
    "auto_compact": { "threshold": "90%" },
    "thinking_display": "preview",
    "play_sound_when_agent_done": "always",
    "commit_message_instructions": "Use Conventional Commits format: <type>(<scope>): <description>. Keep the subject concise & use simplified chinese.",
    "commit_message_include_project_rules": true,
    "default_model": {
      "speed": "fast",
      "effort": "medium",
      "enable_thinking": true,
      "provider": "openai-subscribed",
      "model": "gpt-5.6-luna"
    },
  },

  "agent_servers": {
    "codebuddy-code": {
      "type": "registry"
    },
    "Codebuddy": {
      "default_config_options": {
        "multitask": false,
        "model": "deepseek-v4.1-flash"
      },
      "favorite_config_option_values": {
        "model": ["deepseek-v4.1-flash"]
      },
      "type": "custom",
      "command": "codebuddy",
      "args": ["--acp"]
    }
  },

  "theme": {
    "mode": "system",
    "light": "One Light",
    "dark": "Catppuccin Mocha"
  },
  "icon_theme": {
    "mode": "system",
    "light": "Catppuccin Latte",
    "dark": "Catppuccin Mocha"
  },

  "autosave": "on_focus_change",
  "show_edit_predictions": false,
  "expand_excerpt_lines": 10,

  "cli_default_open_behavior": "existing_window",
  "diff_view_style": "split",
  "disable_ai": false,

  "remove_trailing_whitespace_on_save": false,
  "ensure_final_newline_on_save": false,

  "base_keymap": "VSCode",

  "terminal": {
    "font_size": 13
  },

  "enable_language_server": true,
  "accessible_mode": false,

  "vim_mode": true,

  "vim": {
    "use_system_clipboard": "never"
  },

  "ui_font_size": 14.0,
  "ui_font_family": "Maple Mono Normal NL NF CN",
  "buffer_font_size": 13,
  "buffer_font_family": "Maple Mono Normal NL NF CN",

  "languages": {
    "Markdown": {
      "soft_wrap": "editor_width"
    }
  }
}
```

## 键盘配置

```json
[
  {
    "context": "Workspace || Editor && !menu",
    "bindings": {
      "ctrl-a": "editor::SelectAll",
      "ctrl-c": "editor::Copy",
      "ctrl-v": "editor::Paste",
      "ctrl-x": "editor::Cut",
      "ctrl-z": "editor::Undo",
      "ctrl-shift-z": "editor::Redo",
      "ctrl-y": "editor::Redo",
      "ctrl-s": "workspace::Save",
      "ctrl-shift-s": "workspace::SaveAs",
      "ctrl-f": "buffer_search::Deploy",
      "ctrl-h": "buffer_search::DeployReplace",
      "ctrl-n": "workspace::NewFile",
      "ctrl-o": "workspace::Open",
      "ctrl-w": "pane::CloseActiveItem",
      "ctrl-p": "file_finder::Toggle",
      "ctrl-shift-p": "command_palette::Toggle",
      "ctrl-tab": "pane::ActivateNextItem",
      "ctrl-shift-tab": "pane::ActivatePreviousItem",
      "ctrl-]": "editor::GoToDefinition",
      "ctrl-shift-]": "editor::GoToDeclaration",
      "ctrl-\\": "workspace::ToggleRightDock",
      "alt-\\": "workspace::ToggleLeftDock",
      "win-\\": "workspace::ToggleBottomDock"
    },
  },
]
```
