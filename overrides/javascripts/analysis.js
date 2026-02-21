function umami() {
  if (window.location.hostname !== "localhost" && window.location.hostname !== "127.0.0.1") {
    var script = document.createElement("script");
    script.defer = true;
    script.src = "https://umami.ricolxwz.download/script.js";
    script.setAttribute(
      "data-website-id",
      "c43fe42f-9cf0-4d15-8e52-f3f9fa525a9b"
    );
    document.head.appendChild(script);
  }
}
umami();
