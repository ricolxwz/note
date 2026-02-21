---
title: 主题美化
comments: true
---

# 主题美化

## 默认主题修改LOGO, 修改页脚

```html
<style>
.right.menu>a {
  visibility: hidden;
}
.footer .is-size-7 {
  visibility: hidden;
}
.item img {
  visibility: hidden;
}
</style>
<script>
window.onload = function() {
  document.querySelector("[rel='shortcut icon']").href = "https://cdn.jsdelivr.net/gh/ricolxwz/logo@master/favicon-blue-sigma-concat-margin-100-1.svg"
  var avatar = document.querySelector(".item img");
  var footer = document.querySelector("div.is-size-7");
  footer.innerHTML = "由麦旋风超好吃驱动 🚜 2024";
  footer.style.visibility = "visible";
  avatar.src = "https://cdn.jsdelivr.net/gh/ricolxwz/logo@master/favicon-blue-sigma-concat.svg";
  avatar.style.visibility = "visible";
  avatar.style.height = "95%";
}
</script>
```
