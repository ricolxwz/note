function umami() {
  if (window.location.hostname !== "localhost" && window.location.hostname !== "127.0.0.1") {
    var script = document.createElement("script");
    script.defer = true;
    script.src = "http://35.95.99.18:45862/script.js";
    script.setAttribute(
      "data-website-id",
      "168d0646-2ebc-439e-a419-905fc93f2ce0"
    );
    document.head.appendChild(script);
  }
}
umami();
