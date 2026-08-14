const REPO = "linux503/FilesDesk";

async function latestRelease() {
  const nodes = document.querySelectorAll("[data-download]");
  const tags = document.querySelectorAll("[data-latest-tag]");
  const fallback = "1.1.1";
  try {
    const response = await fetch(`https://api.github.com/repos/${REPO}/releases/latest`);
    if (!response.ok) throw new Error("no release");
    const data = await response.json();
    const zip = (data.assets || []).find((asset) => asset.name.endsWith(".zip"));
    const href = zip ? zip.browser_download_url : data.html_url;
    const version = (data.tag_name || fallback).replace(/^v/, "");
    nodes.forEach((node) => { node.href = href; });
    tags.forEach((node) => { node.textContent = version; });
  } catch {
    nodes.forEach((node) => {
      node.href = `https://github.com/${REPO}/releases`;
    });
    tags.forEach((node) => {
      if (!node.textContent.trim()) node.textContent = fallback;
    });
  }
}

function initNav() {
  const header = document.querySelector(".site-header");
  const toggle = document.querySelector(".nav-toggle");
  if (!header || !toggle) return;

  const close = () => {
    header.classList.remove("is-open");
    toggle.setAttribute("aria-expanded", "false");
  };

  toggle.addEventListener("click", () => {
    const open = header.classList.toggle("is-open");
    toggle.setAttribute("aria-expanded", open ? "true" : "false");
  });

  header.querySelectorAll(".nav-links a").forEach((link) => {
    link.addEventListener("click", close);
  });

  document.addEventListener("keydown", (event) => {
    if (event.key === "Escape") close();
  });
}

document.addEventListener("DOMContentLoaded", () => {
  latestRelease();
  initNav();
});
