---
title: 配置Latex-Workshop
comments: true
---

## 添加 biber

在`latex-workshop.latex.tools`中添加以下工具:

```json
{
  "name": "xelatex",
  "command": "xelatex",
  "args": [
      "-synctex=1",
      "-interaction=nonstopmode",
      "-file-line-error",
      "%DOC%"
  ]
}
```

```json
{
  "name": "biber",
  "command": "biber",
  "args": ["%DOCFILE%"]
}
```

在`latex-workshop.latex.recipes`中添加以下工具链:

```json
{
  "name": "xelatex -> biber -> xelatex*2",
  "tools": ["xelatex", "biber", "xelatex", "xelatex"]
}
```

自定义默认工具链:

```json
"latex-workshop.latex.recipe.default": "xelatex -> biber -> xelatex*2"
```

### 引用示例

```tex
\usepackage[backend=biber,style=numeric,sorting=none]{biblatex}
\addbibresource{a1.bib}
\begin{document}
xxx \cite{paper1}
\printbibliography[heading=bibnumbered]
\end{document}
```

通常, bib文件中每个条目只需要保留:

* author
* title
* publisher 
* pages
* year