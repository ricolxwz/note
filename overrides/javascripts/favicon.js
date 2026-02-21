function updateFavicon() {
    const lightIcon = 'https://cdn.ricolxwz.cn/favicon-black-mc-be1517f676f6767b821a61dee1fe0de1.svg';
    const darkIcon = 'https://cdn.ricolxwz.cn/favicon-white-mc-9874bcbf2890db92e65db16e14c4edb4.svg';
    const currentTheme = window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light';
    const favicon = document.querySelector('link[rel="icon"]');
    favicon.href = currentTheme === 'dark' ? darkIcon : lightIcon;
  }

window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', updateFavicon);
updateFavicon();
