---
title: 基础配置
comments: true
---

# 配置

```json
{
    "editor.fontFamily": "Maple Mono Normal NL NF CN",
    "editor.wrappingStrategy": "advanced",
    "editor.minimap.enabled": true,
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
    "editor.codeLensFontFamily": "Maple Mono Normal NL NF CN",
    "editor.inlayHints.fontFamily": "Maple Mono Normal NL NF CN",
    "debug.console.fontFamily": "Maple Mono Normal NL NF CN",
    "scm.inputFontFamily": "Maple Mono Normal NL NF CN",
    "notebook.markup.fontFamily": "Maple Mono Normal NL NF CN",
    "notebook.output.fontFamily": "Maple Mono Normal NL NF CN",
    "chat.editor.fontFamily": "Maple Mono Normal NL NF CN",
    "markdown.preview.fontFamily": "Maple Mono Normal NL NF CN",
    "editor.inlineSuggest.fontFamily": "Maple Mono Normal NL NF CN",
    "debug.enableStatusBarColor": false,
    "debug.inlineValues": "off",
    "debug.toolBarLocation": "commandCenter",
    "workbench.colorTheme": "Vesper",  // vesper, minimal, poimandres
    "workbench.activityBar.location": "top",
    "workbench.sideBar.location": "right",
    "workbench.iconTheme": "moxer-icons",  // symbols
    "workbench.editor.showTabs": "multiple",
    "workbench.productIconTheme": "materialiconic-product-icons",
    "workbench.statusBar.visible": true,
    "workbench.tips.enabled": false,
    "workbench.tree.enableStickyScroll": false,
    "workbench.tree.renderIndentGuides": "none",
    "workbench.tree.indent": 16,
    "explorer.compactFolders": false,
    "explorer.confirmDragAndDrop": false,
    "explorer.confirmDelete": false,
    "explorer.decorations.badges": false,
    "git.decorations.enabled": false,
    "git.autofetch": true,
    "git.confirmSync": false,
    "window.zoomLevel": 0,
    "breadcrumbs.enabled": false,
    "files.autoSave": "onFocusChange",
    "files.trimFinalNewlines": true,
    "files.trimTrailingWhitespace": true,
    "files.insertFinalNewline": true,
    "material-icon-theme.hidesExplorerArrows": true,
    "scm.diffDecorations": "gutter",
    "extensions.ignoreRecommendations": true,
    "window.commandCenter": true,
    "inlineChat.lineNaturalLanguageHint": false,
    "files.eol": "\n",
    "terminal.integrated.copyOnSelection": true,
    "editor.cursorSmoothCaretAnimation": "on",
    "editor.smoothScrolling": true,
    "workbench.list.smoothScrolling": true,
    "terminal.integrated.smoothScrolling": true,
    "window.autoDetectColorScheme": true,
    "animations.Enabled": true,
    "animations.CursorAnimation": true,
    "animations.UseCursorColorForCursorAnimation": true,
    "remote.SSH.remotePlatform": {
        "lab": "linux"
    },
    "[python]": {
        "editor.formatOnSave": false
    }
}
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

```css
.monaco-editor .suggest-widget{
    display:block!important;
    pointer-events:none;
    opacity:0;
    transform:translateY(6px) scale(.96);
    visibility:hidden;
    transition:opacity .3s cubic-bezier(.4,0,.2,1),
               transform .3s cubic-bezier(.4,0,.2,1),
               visibility 0s linear .3s;
}

.monaco-editor .suggest-widget.visible{
    opacity:1;
    transform:translateY(0) scale(1);
    visibility:visible;
    transition:opacity .3s cubic-bezier(.4,0,.2,1),
               transform .3s cubic-bezier(.4,0,.2,1),
               visibility 0s linear .3s;
}
```

记得, Reload Custom CSS and JS.
