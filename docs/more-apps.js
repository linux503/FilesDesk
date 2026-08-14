/** Cross-promotion menu — exclude current site via data-current-app on <body>. */
const MORE_APPS = [
  {
    id: "flare",
    url: "https://linux503.github.io/Flare/",
    name: "Flare",
    desc: { zh: "截图录屏", en: "Screenshot & Record" }
  },
  {
    id: "zipx",
    url: "https://linux503.github.io/ZipX/",
    name: "ZipX",
    desc: { zh: "解压压缩", en: "Archive & Compress" }
  },
  {
    id: "mactext",
    url: "https://linux503.github.io/MacText/",
    name: "MacText",
    desc: { zh: "文本编辑", en: "Text Editor" }
  },
  {
    id: "suptools",
    url: "https://linux503.github.io/suptools/",
    name: "SupTools",
    desc: { zh: "macOS 超级工具箱", en: "macOS Utility Suite" }
  },
  {
    id: "macfan",
    url: "https://linux503.github.io/MacFan/",
    name: "MacFan",
    desc: { zh: "精准控制 Mac 风扇转速", en: "Mac Fan Control" }
  },
  {
    id: "filesdesk",
    url: "https://linux503.github.io/FilesDesk/",
    name: "FilesDesk",
    desc: { zh: "Mac 智能批量重命名", en: "Smart Batch Renamer" }
  }
];

function moreAppsLang() {
  return localStorage.getItem("filesdesk-lang") === "en" ? "en" : "zh";
}

function refreshMoreApps() {
  const root = document.querySelector("[data-more-apps]");
  if (!root) return;

  const current = document.body.dataset.currentApp || "filesdesk";
  const lang = moreAppsLang();
  const label = lang === "zh" ? "更多软件" : "More Apps";
  const apps = MORE_APPS.filter((app) => app.id !== current);

  root.innerHTML = `
    <details class="more-apps-menu">
      <summary>${label}</summary>
      <div class="more-apps-panel" role="menu">
        ${apps.map((app) => `
          <a class="more-apps-item" href="${app.url}" role="menuitem" target="_blank" rel="noopener">
            <span class="more-apps-name">${app.name}</span>
            <span class="more-apps-desc">${app.desc[lang]}</span>
          </a>
        `).join("")}
      </div>
    </details>
  `;
}

document.addEventListener("DOMContentLoaded", () => {
  refreshMoreApps();
  document.querySelectorAll("[data-lang-btn]").forEach((btn) => {
    btn.addEventListener("click", () => setTimeout(refreshMoreApps, 0));
  });
});

window.refreshMoreApps = refreshMoreApps;
