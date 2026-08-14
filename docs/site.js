const REPO = "linux503/FilesDesk";

function bindDownload(version) {
  const href = `./FilesDesk.dmg?v=${version}`;
  document.querySelectorAll("[data-download]").forEach((node) => {
    node.href = href;
    node.setAttribute("download", "FilesDesk.dmg");
  });
  document.querySelectorAll("[data-latest-tag]").forEach((node) => {
    node.textContent = version;
  });
}

async function latestRelease() {
  const fallback = "1.1.2";
  bindDownload(fallback);
  try {
    const response = await fetch(`https://api.github.com/repos/${REPO}/releases/latest`);
    if (!response.ok) throw new Error("no release");
    const data = await response.json();
    const version = (data.tag_name || fallback).replace(/^v/, "");
    bindDownload(version);
  } catch {
    bindDownload(fallback);
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
