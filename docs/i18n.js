const I18N = {
  zh: {
    htmlLang: "zh-CN",
    meta: {
      home: { title: "FilesDesk — Mac 智能批量重命名", desc: "原生 Mac 批量重命名工具。实时预览、撤销、历史与预设。绝不覆盖已有文件。" },
      download: { title: "下载 — FilesDesk", desc: "下载 FilesDesk for macOS。批量重命名、实时预览、撤销与历史。" },
      faq: { title: "常见问题 — FilesDesk", desc: "FilesDesk 使用说明：预览、撤销、预设与在线更新。" },
      privacy: { title: "隐私政策 — FilesDesk", desc: "FilesDesk 隐私说明。重命名在本地完成，更新通过 Sparkle 检查。" },
      changelog: { title: "更新日志 — FilesDesk", desc: "FilesDesk 版本更新与 Sparkle 更新记录。" }
    },
    nav: { download: "下载", faq: "常见问题", privacy: "隐私", changelog: "更新", moreApps: "更多软件" },
    lang: { label: "语言", zh: "中文", en: "English" },
    home: {
      lede: "一次重命名上千个文件",
      sub: "实时预览、撤销与历史记录。原生 Mac 工具，绝不覆盖已有文件。",
      cta: "下载 Mac 版",
      source: "查看源码",
      featureTitle: "改之前，先看新名字",
      featureLead: "规则一改，列表立刻更新。未点「重命名」前不会写入磁盘；有冲突则整批阻止。",
      downloadTitle: "下载 FilesDesk",
      downloadLead: "支持 macOS 14 及以上。开源免费，应用内通过 Sparkle 自动更新。",
      downloadCta: "获取最新版本",
      version: "版本",
      featSafeTitle: "安全",
      featUndoTitle: "撤销",
      featuresTitle: "功能"
    },
    mock: {
      rename: "重命名", presets: "预设", history: "历史", settings: "设置",
      remove: "删除 IMG_", prefix: "前缀 Taipei_", numbering: "编号",
      files: "128 个文件", ready: "就绪", renameBtn: "重命名 128"
    },
    download: {
      title: "下载",
      intro: "FilesDesk 是 macOS 14 Sonoma 及更高版本的原生应用。当前版本：",
      cta: "下载 .zip",
      source: "GitHub 源码",
      afterTitle: "安装后",
      after: "解压后将 FilesDesk 拖入「应用程序」，添加文件或文件夹即可开始。应用会通过 Sparkle 从此站点检查更新。",
      reqTitle: "系统要求",
      req1: "Apple 芯片或 Intel Mac",
      req2: "macOS 14 或更高版本",
      req3: "对你选择的文件具备重命名权限"
    },
    faq: {
      title: "常见问题",
      q1: "预览会改文件吗？",
      a1: "不会。预览只在内存中计算新文件名，只有点击「重命名」并通过校验后才会写入磁盘。",
      q2: "会覆盖已有文件吗？",
      a2: "不会。若目标名已存在，或批量结果出现重名，重命名会被阻止。",
      q3: "撤销怎么用？",
      a3: "每次成功重命名都会写入历史，记录原路径与新路径。可从完成提示或历史页撤销，恢复原名。",
      q4: "预设是什么？",
      a4: "预设是一组可复用的规则模板。内置摄影、截图、电商、文档等模板，也可保存自己的规则。",
      q5: "如何在线更新？",
      a5: "应用使用 Sparkle，读取本站 appcast.xml，并从 GitHub Releases 下载已签名的更新包。",
      q6: "需要账号吗？",
      a6: "不需要。无登录、无云同步、无账号体系。"
    },
    privacy: {
      title: "隐私政策",
      p1: "FilesDesk 是本地工具，不创建账号，不上传你的文件。",
      p2: "文件名、路径、预设与重命名历史保存在你的 Mac 上（应用沙盒内）。仅对你主动添加的文件进行读取与重命名。",
      p3: "若开启自动更新，Sparkle 会定期请求本站的公开更新源，并可能从 GitHub Releases 下载已签名的安装包。请求包含应用版本等常规 HTTP 信息。可在「设置」中关闭自动检查。",
      p4: "本站为静态页面，不使用追踪 Cookie，也不接入第三方统计。",
      p5: "如有问题，请在 GitHub 提交 Issue。"
    },
    changelog: {
      title: "更新日志",
      intro: "应用通过 Sparkle 读取此更新源。安装包发布在 GitHub Releases。",
      v100Date: "2026 年 8 月 14 日",
      v100Items: [
        "批量重命名与实时预览",
        "替换、前缀、后缀、删除、编号、大小写、日期、清理、正则规则",
        "校验：阻止覆盖、重名、空名与无权限",
        "撤销与历史",
        "预设模板",
        "Sparkle 应用内更新"
      ]
    },
    footer: { privacy: "隐私", changelog: "更新", github: "GitHub" }
  },
  en: {
    htmlLang: "en",
    meta: {
      home: { title: "FilesDesk — Smart File Renamer for Mac", desc: "A native Mac batch renamer. Live preview, undo, history, and presets. Never overwrites existing files." },
      download: { title: "Download — FilesDesk", desc: "Download FilesDesk for macOS. Batch rename with live preview, undo, and history." },
      faq: { title: "FAQ — FilesDesk", desc: "Answers about FilesDesk preview, undo, presets, and updates." },
      privacy: { title: "Privacy — FilesDesk", desc: "FilesDesk privacy policy. Renaming stays local; updates use Sparkle." },
      changelog: { title: "Changelog — FilesDesk", desc: "FilesDesk release history and Sparkle update feed." }
    },
    nav: { download: "Download", faq: "FAQ", privacy: "Privacy", changelog: "Updates", moreApps: "More Apps" },
    lang: { label: "Language", zh: "中文", en: "English" },
    home: {
      lede: "Rename thousands of files at once",
      sub: "Live preview, undo, and history — a native Mac tool that never overwrites what is already there.",
      cta: "Download for Mac",
      source: "View source",
      featureTitle: "See the new name first",
      featureLead: "Rules update the list as you type. Nothing is written until you rename, and conflicts block the batch.",
      downloadTitle: "Download FilesDesk",
      downloadLead: "macOS 14 or later. Free and open source, with Sparkle in-app updates.",
      downloadCta: "Get the latest build",
      version: "Version",
      featSafeTitle: "Safety",
      featUndoTitle: "Undo",
      featuresTitle: "Features"
    },
    mock: {
      rename: "Rename", presets: "Presets", history: "History", settings: "Settings",
      remove: "Remove IMG_", prefix: "Prefix Taipei_", numbering: "Numbering",
      files: "128 Files", ready: "Ready", renameBtn: "Rename 128"
    },
    download: {
      title: "Download",
      intro: "FilesDesk is a native Mac app for macOS 14 Sonoma and later. Current release:",
      cta: "Download .zip",
      source: "Source on GitHub",
      afterTitle: "After install",
      after: "Open the zip, move FilesDesk to Applications, then add files or a folder. Updates are checked via Sparkle from this site.",
      reqTitle: "Requirements",
      req1: "Apple silicon or Intel Mac",
      req2: "macOS 14 or later",
      req3: "Permission to rename files you select"
    },
    faq: {
      title: "FAQ",
      q1: "Does preview rename files?",
      a1: "No. Preview only computes new names in memory. Disk writes happen after validation when you click Rename.",
      q2: "Can FilesDesk overwrite files?",
      a2: "No. If a target name already exists, or two files would collide, rename is blocked.",
      q3: "How does undo work?",
      a3: "Each successful batch is saved in History with old and new paths. Undo restores original names using the same safe two-phase rename.",
      q4: "What are presets?",
      a4: "Presets are reusable rule templates. Built-in Photography, Screenshots, E-commerce, and Documents presets are included.",
      q5: "How do in-app updates work?",
      a5: "FilesDesk uses Sparkle to read the appcast on this site and install signed builds from GitHub Releases.",
      q6: "Is there an account?",
      a6: "No. No login, cloud sync, or account system."
    },
    privacy: {
      title: "Privacy",
      p1: "FilesDesk is a local utility. It does not create an account or upload your files.",
      p2: "File names, paths, presets, and rename history stay on your Mac inside the app sandbox.",
      p3: "If automatic updates are enabled, Sparkle requests the public feed on this site and may download a signed archive from GitHub Releases.",
      p4: "This site is static. No tracking cookies or third-party analytics.",
      p5: "Questions? Open an issue on GitHub."
    },
    changelog: {
      title: "Changelog",
      intro: "The app checks this feed with Sparkle. Release archives are on GitHub.",
      v100Date: "August 14, 2026",
      v100Items: [
        "Batch rename with live preview",
        "Replace, prefix, suffix, remove, numbering, case, date, cleanup, regex",
        "Validation blocks overwrite, duplicates, empty names, and permission errors",
        "Undo and History",
        "Saved presets",
        "Sparkle in-app updates"
      ]
    },
    footer: { privacy: "Privacy", changelog: "Changelog", github: "GitHub" }
  }
};

function getLang() {
  const saved = localStorage.getItem("filesdesk-lang");
  if (saved === "zh" || saved === "en") return saved;
  return "zh";
}

function t(lang, key) {
  const parts = key.split(".");
  let cur = I18N[lang];
  for (const p of parts) {
    if (!cur) return key;
    cur = cur[p];
  }
  return cur ?? key;
}

function applyLang(lang) {
  document.documentElement.lang = I18N[lang].htmlLang;
  document.querySelectorAll("[data-i18n]").forEach((el) => {
    const key = el.dataset.i18n;
    const val = t(lang, key);
    if (Array.isArray(val)) {
      if (el.tagName === "UL") {
        el.innerHTML = val.map((item) => `<li>${item}</li>`).join("");
      }
    } else {
      el.textContent = val;
    }
  });
  document.querySelectorAll("[data-i18n-placeholder]").forEach((el) => {
    el.placeholder = t(lang, el.dataset.i18nPlaceholder);
  });
  const page = document.body.dataset.page;
  if (page && I18N[lang].meta[page]) {
    document.title = I18N[lang].meta[page].title;
    const desc = document.querySelector('meta[name="description"]');
    if (desc) desc.content = I18N[lang].meta[page].desc;
  }
  document.querySelectorAll("[data-lang-btn]").forEach((btn) => {
    btn.classList.toggle("active", btn.dataset.langBtn === lang);
    btn.setAttribute("aria-pressed", btn.dataset.langBtn === lang ? "true" : "false");
  });
  localStorage.setItem("filesdesk-lang", lang);
  window.refreshMoreApps?.();
}

function initI18n() {
  const lang = getLang();
  applyLang(lang);
  document.querySelectorAll("[data-lang-btn]").forEach((btn) => {
    btn.addEventListener("click", () => applyLang(btn.dataset.langBtn));
  });
}

document.addEventListener("DOMContentLoaded", initI18n);
