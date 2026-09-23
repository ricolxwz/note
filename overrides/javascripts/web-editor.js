// Open the current note in github.dev, including after instant navigation.
function updateWebEditorLinks() {
  const sourcePrefix = "https://github.com/ricolxwz/note/edit/master/docs/";
  const editorPrefix = "https://github.dev/ricolxwz/note/blob/master/docs/";
  document.querySelectorAll('a.md-content__button[rel="edit"]').forEach((link) => {
    if (link.href.startsWith(sourcePrefix)) {
      link.href = editorPrefix + link.href.slice(sourcePrefix.length);
    }
  });
}

if (typeof document$ !== "undefined") {
  document$.subscribe(updateWebEditorLinks);
} else if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", updateWebEditorLinks);
} else {
  updateWebEditorLinks();
}
