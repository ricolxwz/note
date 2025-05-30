---
title: 基础配置
comments: true
---

# 配置

## 总体配置

```json
"editor.fontSize": 14,
"editor.fontFamily": "Maple Mono Normal NL NF CN",
"editor.wrappingStrategy": "advanced",
"editor.minimap.enabled": true,
"editor.tabCompletion": "onlySnippets",
"editor.cursorBlinking": "solid",
"editor.cursorStyle": "line",
"editor.fontLigatures": false,
"editor.lineHeight": 1.6,
"editor.stickyScroll.enabled": false,
"editor.colorDecorators": false,
"editor.codeLens": true,
"editor.links": false,
"editor.matchBrackets": "always",
"editor.parameterHints.enabled": true,
"editor.lightbulb.enabled": "off",
"editor.hover.enabled": true,
"editor.lineNumbers": "on",
"editor.showFoldingControls": "never",
"editor.detectIndentation": false,
"editor.guides.indentation": false,
"editor.renderWhitespace": "selection",
"editor.renderLineHighlight": "none",
"editor.occurrencesHighlight": "multiFile",
"editor.selectionHighlight": true,
"editor.scrollbar.vertical": "hidden",
"editor.scrollbar.horizontal": "hidden",
"editor.overviewRulerBorder": false,
"editor.hideCursorInOverviewRuler": true,
"editor.experimentalEditContextEnabled": true,
"editor.formatOnSave": false,
"editor.accessibilitySupport": false,
"editor.cursorSmoothCaretAnimation": "on",
"editor.smoothScrolling": true,
"editor.codeLensFontFamily": "Maple Mono Normal NL NF CN",
"editor.inlayHints.fontFamily": "Maple Mono Normal NL NF CN",
"editor.inlineSuggest.fontFamily": "Maple Mono Normal NL NF CN",

"debug.console.fontFamily": "Maple Mono Normal NL NF CN",
"debug.enableStatusBarColor": false,
"debug.inlineValues": "off",
"debug.toolBarLocation": "commandCenter",

"notebook.markup.fontFamily": "Maple Mono Normal NL NF CN",
"notebook.output.fontFamily": "Maple Mono Normal NL NF CN",

"chat.editor.fontFamily": "Maple Mono Normal NL NF CN",

"markdown.preview.fontFamily": "Maple Mono Normal NL NF CN",

"workbench.preferredLightColorTheme": "Quiet Light",
"workbench.preferredDarkColorTheme": "Aura Dark (Soft Text)",
"workbench.activityBar.location": "top",
"workbench.sideBar.location": "right",
"workbench.editor.showTabs": "multiple",
"workbench.productIconTheme": "material-product-icons",
"workbench.iconTheme": "gruvbox-material-icon-theme",
"workbench.statusBar.visible": true,
"workbench.tips.enabled": false,
"workbench.tree.enableStickyScroll": false,
"workbench.tree.renderIndentGuides": "none",
"workbench.tree.indent": 16,
"workbench.list.smoothScrolling": true,

"explorer.compactFolders": false,
"explorer.confirmDragAndDrop": false,
"explorer.confirmDelete": false,
"explorer.decorations.badges": false,

"git.decorations.enabled": false,
"git.autofetch": true,
"git.confirmSync": false,

"window.zoomLevel": 0,
"window.commandCenter": true,
"window.autoDetectColorScheme": true,

"breadcrumbs.enabled": true,

"files.autoSave": "onFocusChange",
"files.trimFinalNewlines": false,
"files.trimTrailingWhitespace": false,
"files.insertFinalNewline": false,
"files.eol": "\n",

"material-icon-theme.hidesExplorerArrows": true,

"scm.inputFontFamily": "Maple Mono Normal NL NF CN",
"scm.diffDecorations": "gutter",

"extensions.ignoreRecommendations": false,

"inlineChat.lineNaturalLanguageHint": false,

"terminal.integrated.copyOnSelection": true,
"terminal.integrated.smoothScrolling": true,

"animations.Enabled": true,
"animations.CursorAnimation": true,
"animations.UseCursorColorForCursorAnimation": true,

"remote.SSH.remotePlatform": {
    "lab": "linux"
},

"[python]": {
    "editor.formatOnSave": false
},
```

## 补全栏平滑过度

```css
.monaco-editor .suggest-widget {
    opacity: 0;
    transform: translateY(6px) scale(.96);
    transition: opacity .5s cubic-bezier(.4, 0, .2, 1),
        transform .5s cubic-bezier(.4, 0, .2, 1);
}

.monaco-editor .suggest-widget.visible {
    opacity: 1;
    transform: translateY(0) scale(1);
}
```

## 键盘配置

## macOS

```json
{
    "key": "cmd+e",
    "command": "editor.action.insertSnippet",
    "when": "editorTextFocus",
    "args": {
        "snippet": "$${0}$"
    },
},
{
    "key": "shift+cmd+/",
    "command": "chinese-punctuation-to-english.toEnglish"
},
{
    "key": "ctrl+\\",
    "command": "workbench.action.toggleAuxiliaryBar"
},
{
    "key": "alt+cmd+b",
    "command": "-workbench.action.toggleAuxiliaryBar"
},
{
    "key": "cmd+\\",
    "command": "workbench.action.toggleSidebarVisibility"
},
{
    "key": "cmd+b",
    "command": "-workbench.action.toggleSidebarVisibility"
},
{
    "key": "alt+\\",
    "command": "workbench.action.togglePanel"
},
{
    "key": "cmd+j",
    "command": "-workbench.action.togglePanel"
},
{
    "key": "ctrl+z",
    "command": "editor.action.toggleWordWrap"
},
{
    "key": "alt+z",
    "command": "-editor.action.toggleWordWrap"
},
```

## Windows

```json
{
    "key": "ctrl+e",
    "command": "editor.action.insertSnippet",
    "when": "editorTextFocus",
    "args": {
        "snippet": "$${0}$"
    },
},
{
    "key": "ctrl+v",
    "command": "-workbench.action.terminal.sendSequence",
    "when": "terminalFocus && !accessibilityModeEnabled && terminalShellType == 'pwsh'"
},
{
    "key": "ctrl+shift+/",
    "command": "chinese-punctuation-to-english.toEnglish"
},
{
    "key": "ctrl+oem_5",
    "command": "-workbench.action.splitEditor"
},
{
    "key": "ctrl+oem_5",
    "command": "workbench.action.toggleSidebarVisibility"
},
{
    "key": "ctrl+b",
    "command": "-workbench.action.toggleSidebarVisibility"
},
{
    "key": "alt+oem_5",
    "command": "workbench.action.toggleAuxiliaryBar"
},
{
    "key": "ctrl+alt+b",
    "command": "-workbench.action.toggleAuxiliaryBar"
},
{
    "key": "win+oem_5",
    "command": "workbench.action.togglePanel"
},
{
    "key": "ctrl+j",
    "command": "-workbench.action.togglePanel"
},
{
    "key": "ctrl+l",
    "command": "workbench.debug.panel.action.clearReplAction"
},
``` 

### 全平台

```json   
{
    "key": "escape",
    "command": "-geminicodeassist.rejectCompletion",
    "when": "authLoggedIn && config.geminicodeassist.enable && inlineSuggestionVisible"
},

// 删除vim快捷键绑定
{
    "key": "ctrl+oem_4",
    "command": "-extension.vim_ctrl+[",
    "when": "editorTextFocus && vim.active && vim.use<C-[> && !inDebugRepl"
},
{
    "key": "ctrl+oem_6",
    "command": "-extension.vim_ctrl+]",
    "when": "editorTextFocus && vim.active && vim.use<C-]> && !inDebugRepl"
},
{
    "key": "ctrl+6",
    "command": "-extension.vim_ctrl+6",
    "when": "editorTextFocus && vim.active && vim.use<C-6> && !inDebugRepl"
},
{
    "key": "ctrl+a",
    "command": "-extension.vim_ctrl+a",
    "when": "editorTextFocus && vim.active && vim.use<C-a> && !inDebugRepl"
},
{
    "key": "ctrl+b",
    "command": "-extension.vim_ctrl+b",
    "when": "editorTextFocus && vim.active && vim.use<C-b> && !inDebugRepl && vim.mode != 'Insert'"
},
{
    "key": "ctrl+backspace",
    "command": "-extension.vim_ctrl+backspace",
    "when": "editorTextFocus && vim.active && vim.use<C-BS> && !inDebugRepl && vim.mode != 'Insert'"
},
{
    "key": "ctrl+c",
    "command": "-extension.vim_ctrl+c",
    "when": "editorTextFocus && vim.active && vim.overrideCtrlC && vim.use<C-c> && !inDebugRepl"
},
{
    "key": "ctrl+d",
    "command": "-extension.vim_ctrl+d",
    "when": "editorTextFocus && vim.active && vim.use<C-d> && !inDebugRepl"
},
{
    "key": "ctrl+down",
    "command": "-extension.vim_ctrl+down",
    "when": "editorTextFocus && vim.active && !inDebugRepl && vim.mode != 'Insert'"
},
{
    "key": "ctrl+e",
    "command": "-extension.vim_ctrl+e",
    "when": "editorTextFocus && vim.active && vim.use<C-e> && !inDebugRepl"
},
{
    "key": "ctrl+end",
    "command": "-extension.vim_ctrl+end",
    "when": "editorTextFocus && vim.active && !inDebugRepl && vim.mode != 'Insert'"
},
{
    "key": "ctrl+f",
    "command": "-extension.vim_ctrl+f",
    "when": "editorTextFocus && vim.active && vim.use<C-f> && !inDebugRepl && vim.mode != 'Insert'"
},
{
    "key": "ctrl+g",
    "command": "-extension.vim_ctrl+g",
    "when": "editorTextFocus && vim.active && vim.use<C-g> && !inDebugRepl"
},
{
    "key": "ctrl+h",
    "command": "-extension.vim_ctrl+h",
    "when": "editorTextFocus && vim.active && vim.use<C-h> && !inDebugRepl"
},
{
    "key": "ctrl+home",
    "command": "-extension.vim_ctrl+home",
    "when": "editorTextFocus && vim.active && !inDebugRepl && vim.mode != 'Insert'"
},
{
    "key": "ctrl+i",
    "command": "-extension.vim_ctrl+i",
    "when": "editorTextFocus && vim.active && vim.use<C-i> && !inDebugRepl"
},
{
    "key": "ctrl+j",
    "command": "-extension.vim_ctrl+j",
    "when": "editorTextFocus && vim.active && vim.use<C-j> && !inDebugRepl"
},
{
    "key": "ctrl+k",
    "command": "-extension.vim_ctrl+k",
    "when": "editorTextFocus && vim.active && vim.use<C-k> && !inDebugRepl"
},
{
    "key": "ctrl+left",
    "command": "-extension.vim_ctrl+left",
    "when": "editorTextFocus && vim.active && !inDebugRepl && vim.mode != 'Insert'"
},
{
    "key": "ctrl+m",
    "command": "-extension.vim_ctrl+m",
    "when": "editorTextFocus && vim.active && vim.use<C-m> && !inDebugRepl || vim.active && vim.use<C-m> && !inDebugRepl && vim.mode == 'CommandlineInProgress' || vim.active && vim.use<C-m> && !inDebugRepl && vim.mode == 'SearchInProgressMode'"
},
{
    "key": "ctrl+n",
    "command": "-extension.vim_ctrl+n",
    "when": "editorTextFocus && vim.active && vim.use<C-n> && !inDebugRepl || vim.active && vim.use<C-n> && !inDebugRepl && vim.mode == 'CommandlineInProgress' || vim.active && vim.use<C-n> && !inDebugRepl && vim.mode == 'SearchInProgressMode'"
},
{
    "key": "ctrl+o",
    "command": "-extension.vim_ctrl+o",
    "when": "editorTextFocus && vim.active && vim.use<C-o> && !inDebugRepl"
},
{
    "key": "ctrl+p",
    "command": "-extension.vim_ctrl+p",
    "when": "editorTextFocus && vim.active && vim.use<C-p> && !inDebugRepl || vim.active && vim.use<C-p> && !inDebugRepl && vim.mode == 'CommandlineInProgress' || vim.active && vim.use<C-p> && !inDebugRepl && vim.mode == 'SearchInProgressMode'"
},
{
    "key": "ctrl+pagedown",
    "command": "-extension.vim_ctrl+pagedown",
    "when": "editorTextFocus && vim.active && vim.use<C-pagedown> && !inDebugRepl"
},
{
    "key": "ctrl+pageup",
    "command": "-extension.vim_ctrl+pageup",
    "when": "editorTextFocus && vim.active && vim.use<C-pageup> && !inDebugRepl"
},
{
    "key": "ctrl+r",
    "command": "-extension.vim_ctrl+r",
    "when": "editorTextFocus && vim.active && vim.use<C-r> && !inDebugRepl"
},
{
    "key": "ctrl+right",
    "command": "-extension.vim_ctrl+right",
    "when": "editorTextFocus && vim.active && !inDebugRepl && vim.mode != 'Insert'"
},
{
    "key": "ctrl+s",
    "command": "-extension.vim_ctrl+s",
    "when": "editorTextFocus && vim.active && vim.use<C-s> && !inDebugRepl"
},
{
    "key": "ctrl+shift+2",
    "command": "-extension.vim_ctrl+shift+2",
    "when": "editorTextFocus && vim.active && vim.use<C-shift+2>"
},
{
    "key": "ctrl+space",
    "command": "-extension.vim_ctrl+space",
    "when": "editorTextFocus && vim.active && vim.use<C-space> && !inDebugRepl && vim.mode != 'Insert'"
},
{
    "key": "ctrl+t",
    "command": "-extension.vim_ctrl+t",
    "when": "editorTextFocus && vim.active && vim.use<C-t> && !inDebugRepl"
},
{
    "key": "ctrl+u",
    "command": "-extension.vim_ctrl+u",
    "when": "editorTextFocus && vim.active && vim.use<C-u> && !inDebugRepl"
},
{
    "key": "ctrl+up",
    "command": "-extension.vim_ctrl+up",
    "when": "editorTextFocus && vim.active && !inDebugRepl && vim.mode != 'Insert'"
},
{
    "key": "ctrl+v",
    "command": "-extension.vim_ctrl+v",
    "when": "editorTextFocus && vim.active && vim.use<C-v> && !inDebugRepl"
},
{
    "key": "ctrl+w",
    "command": "-extension.vim_ctrl+w",
    "when": "editorTextFocus && vim.active && vim.use<C-w> && !inDebugRepl"
},
{
    "key": "ctrl+x",
    "command": "-extension.vim_ctrl+x",
    "when": "editorTextFocus && vim.active && vim.use<C-x> && !inDebugRepl"
},
{
    "key": "ctrl+y",
    "command": "-extension.vim_ctrl+y",
    "when": "editorTextFocus && vim.active && vim.use<C-y> && !inDebugRepl"
},
{
    "key": "ctrl+z",
    "command": "-extension.vim_ctrl+z",
    "when": "editorTextFocus && vim.active && vim.use<C-z> && !inDebugRepl"
},
{
    "key": "ctrl+l",
    "command": "-extension.vim_navigateCtrlL",
    "when": "editorTextFocus && vim.active && vim.use<C-l> && !inDebugRepl"
},
{
    "key": "ctrl+q",
    "command": "-extension.vim_winCtrlQ",
    "when": "editorTextFocus && vim.active && vim.use<C-q> && !inDebugRepl"
},
// macos上的vim多余配置
{
    "key": "cmd+a",
    "command": "-extension.vim_cmd+a",
    "when": "editorTextFocus && vim.active && vim.use<D-a> && !inDebugRepl && vim.mode != 'Insert'"
},
{
    "key": "alt+cmd+down",
    "command": "-extension.vim_cmd+alt+down",
    "when": "editorTextFocus && vim.active && !inDebugRepl"
},
{
    "key": "alt+cmd+up",
    "command": "-extension.vim_cmd+alt+up",
    "when": "editorTextFocus && vim.active && !inDebugRepl"
},
{
    "key": "cmd+c",
    "command": "-extension.vim_cmd+c",
    "when": "editorTextFocus && vim.active && vim.overrideCopy && vim.use<D-c> && !inDebugRepl"
},
{
    "key": "cmd+d",
    "command": "-extension.vim_cmd+d",
    "when": "editorTextFocus && vim.active && vim.use<D-d> && !inDebugRepl"
},
{
    "key": "cmd+left",
    "command": "-extension.vim_cmd+left",
    "when": "editorTextFocus && vim.active && vim.use<D-left> && !inDebugRepl && vim.mode != 'Insert'"
},
{
    "key": "cmd+right",
    "command": "-extension.vim_cmd+right",
    "when": "editorTextFocus && vim.active && vim.use<D-right> && !inDebugRepl && vim.mode != 'Insert'"
},
{
    "key": "cmd+v",
    "command": "-extension.vim_cmd+v",
    "when": "editorTextFocus && vim.active && vim.use<D-v> && !inDebugRepl && vim.mode == 'CommandlineInProgress' || editorTextFocus && vim.active && vim.use<D-v> && !inDebugRepl && vim.mode == 'SearchInProgressMode'"
},
```

## 插件

```json
{
    "recommendations": [
        // 主题
        "ms-ceintl.vscode-language-pack-zh-hans",
        "PKief.material-product-icons",
        "daltonmenezes.aura-theme",
        "be5invis.vscode-custom-css",
        "JonathanHarty.gruvbox-material-icon-theme",
        "BrandonKirbyson.vscode-animations",

        // 远程开发
        "ms-vscode-remote.remote-ssh",
        "ms-vscode-remote.remote-ssh-edit",
        "ms-vscode.remote-explprint()orer",

        // 编辑
        "vscodevim.vim",
        "buuug7.chinese-punctuation-to-english",
        "EditorConfig.EditorConfig",
        "ms-vscode.wordcount",

        // 代码智能
        "GitHub.copilot",
        "GitHub.copilot-chat",
        "VisualStudioExptTeam.vscodeintellicode",
        "VisualStudioExptTeam.intellicode-api-usage-examples",

        // 版本管理
        "MichaelCurrin.auto-commit-msg",
        "mhutchie.git-graph",
        "codezombiech.gitignore",

        // 服务器
        "ritwickdey.LiveServer",

        // C/C++
        "ms-vscode.cpptools",
        "ms-vscode.cpptools-extension-packs",
        "ms-vscode.cpptools-themes",
        "ms-vscode.cmake-tools",

        // Python
        "ms-python.python",
        "ms-python.vscode-pylance",
        "ms-python.debugpy",
        "WeidaWang.quick-python-print",
        "ms-toolsai.tensorboard",

        // LaTeX
        "James-Yu.latex-workshop",
        "nickfode.latex-formatter",

        // Markdown
        "yzhang.markdown-all-in-one",

        // YAML
        "redhat.vscode-yaml",
    ]
}
```