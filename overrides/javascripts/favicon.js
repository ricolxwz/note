function updateFavicon() {
  const lightIcon = "https://cdn.ricolxwz.cn/favicon-black-mc-be1517f676f6767b821a61dee1fe0de1.svg";
  const darkIcon = "https://cdn.ricolxwz.cn/favicon-white-mc-9874bcbf2890db92e65db16e14c4edb4.svg";
  const isDark =
    document.documentElement.getAttribute("data-md-color-scheme") === "slate";
  let link = document.querySelector('link[rel="icon"]');
  if (!link) {
    link = document.createElement("link");
    link.rel = "icon";
    document.head.appendChild(link);
  }
  const icon = isDark ? darkIcon : lightIcon;
  if (link.href !== icon) {
    link.href = icon;
  }
}

// 监听主题切换(手动切换或系统偏好变化), 而不是依赖 prefers-color-scheme 媒体查询
const observer = new MutationObserver(updateFavicon);
observer.observe(document.documentElement, {
  attributes: true,
  attributeFilter: ["data-md-color-scheme"],
});
updateFavicon();