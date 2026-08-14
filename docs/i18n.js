const I18N = {
  zh: {
    htmlLang: "zh-CN",
    meta: {
      home: { title: "FilesDesk — Mac 智能批量重命名", desc: "原生 Mac 批量重命名工具。实时预览、撤销、历史与预设。绝不覆盖已有文件。" },
      download: { title: "下载 — FilesDesk", desc: "下载 FilesDesk for macOS。批量重命名、实时预览、撤销与历史。" },
      faq: { title: "常见问题 — FilesDesk", desc: "FilesDesk 使用说明：预览、撤销、预设、文件夹编号与刷新。" },
      privacy: { title: "隐私政策 — FilesDesk", desc: "FilesDesk 隐私说明。重命名在本地完成，更新通过 Sparkle 检查。" },
      changelog: { title: "更新日志 — FilesDesk", desc: "FilesDesk 版本更新与 Sparkle 更新记录。" }
    },
    nav: { features: "功能", download: "下载", faq: "常见问题", privacy: "隐私", changelog: "更新", moreApps: "更多软件", menu: "菜单" },
    lang: { label: "语言", zh: "中文", en: "English" },
    home: {
      badge: "macOS 14+ · Apple 芯片 & Intel · 原生",
      lede: "一次重命名上千个文件",
      sub: "拖拽导入文件或文件夹，组合 9 种规则，输入即预览。智能建议、12 套预设、文件夹编号。原生 Mac 工具，绝不覆盖已有文件。",
      cta: "下载 Mac 版",
      source: "查看源码",
      statRules: "9",
      statRulesLabel: "种规则",
      statFiles: "12",
      statFilesLabel: "套预设",
      statFolders: "文件夹",
      statFoldersLabel: "也可连续编号",
      statSafe: "0",
      statSafeLabel: "覆盖已有文件",
      pillarsEyebrow: "核心能力",
      pillarsTitle: "看得见，改得准，丢不了",
      pillarsLead: "从导入到执行，每一步都先预览、再校验、最后才写入磁盘。",
      pillar1Title: "实时预览",
      pillar1Desc: "规则一边输入，新名称一边更新。预览不写磁盘，不必点生成。",
      pillar2Title: "智能建议",
      pillar2Desc: "识别相机文件、截图、拷贝编号和所在文件夹，一键套用规则。",
      pillar3Title: "安全校验",
      pillar3Desc: "重名、覆盖、空名、非法字符、无权限——有错误就阻止执行。",
      pillar4Title: "撤销与历史",
      pillar4Desc: "每次重命名自动存档。完成提示或历史页一键恢复原名。",
      rulesEyebrow: "重命名规则",
      rulesTitle: "9 种规则，自由组合",
      rulesLead: "摄影、截图、电商、文档、视频、微信、文件夹——常见整理都能覆盖。",
      ruleReplace: "替换", ruleReplaceDesc: "查找并替换文本",
      rulePrefix: "前缀", rulePrefixDesc: "在文件名前插入",
      ruleSuffix: "后缀", ruleSuffixDesc: "在扩展名前插入",
      ruleRemove: "删除", ruleRemoveDesc: "移除指定文本",
      ruleNumber: "编号", ruleNumberDesc: "001、002 顺序编号",
      ruleCase: "大小写", ruleCaseDesc: "小写、大写、标题",
      ruleDate: "日期", ruleDateDesc: "创建/修改/当前日期",
      ruleCleanup: "清理", ruleCleanupDesc: "空格、符号、重音",
      ruleRegex: "正则", ruleRegexDesc: "高级模式匹配",
      exampleLabel: "示例",
      exampleSteps: "删除 IMG_ + 前缀 Taipei_ + 编号",
      flowEyebrow: "工作流程",
      flowTitle: "三步完成批量重命名",
      flow1Title: "添加", flow1Desc: "拖拽文件或文件夹。可只重命名文件夹，或导入其中的内容。",
      flow2Title: "配置规则", flow2Desc: "添加规则或套用建议，列表马上显示新名称。⌘R 可刷新磁盘上的最新状态。",
      flow3Title: "安全执行", flow3Desc: "校验通过后一键重命名。两阶段临时名处理，支持 A↔B 互换。",
      scenesEyebrow: "适用场景",
      scenesTitle: "从相册到货架，一种流程",
      scene1: "摄影",
      scene2: "截图",
      scene3: "电商",
      scene4: "文档",
      scene5: "文件夹",
      scene6: "微信",
      bentoEyebrow: "更多特性",
      bentoTitle: "专业工具该有的细节",
      bentoImportTitle: "灵活导入",
      bentoImportDesc: "拖拽、添加文件、添加文件夹。列表显示原名、新名、类型、大小、状态。支持搜索、全选、快速查看、在 Finder 中显示。",
      bentoFolderTitle: "文件与文件夹",
      bentoFolderDesc: "可只重命名文件夹，或只重命名其中的文件。编号只对当前范围连续计数。底部范围：全部 / 文件 / 文件夹。",
      bentoSmartTitle: "智能建议",
      bentoSmartDesc: "根据文件名给出摄影、截图、拷贝编号、文件夹前缀等建议，点一下即可套用。",
      bentoRefreshTitle: "刷新状态",
      bentoRefreshDesc: "⌘R 从磁盘重新读取名称、权限。已删除的项目会从列表去掉，再立刻更新预览。",
      bentoPresetTitle: "预设模板",
      bentoPresetDesc: "12 套内置：摄影、截图、电商、文档、视频、微信图片、去掉拷贝编号、日期前缀、顺序编号等。也可保存自己的规则。",
      bentoPerfTitle: "大规模处理",
      bentoPerfDesc: "支持 10,000+ 文件。预览在后台线程计算，不阻塞界面。",
      bentoNativeTitle: "原生 macOS",
      bentoNativeDesc: "SwiftUI + AppKit。NavigationSplitView、Table、沙盒。浅色/深色自动适配。",
      bentoUpdateTitle: "自动更新",
      bentoUpdateDesc: "Sparkle 应用内更新，EdDSA 签名验证，安全可靠。",
      safetyEyebrow: "安全机制",
      safetyTitle: "绝不丢失用户文件",
      safetyLead: "重命名前全面校验，执行时使用临时名避免冲突，中断后可恢复。",
      safety1: "禁止覆盖已有文件",
      safety2: "检测批量重名冲突",
      safety3: "拦截空文件名与非法字符",
      safety4: "检查目录写入权限",
      safety5: "两阶段临时重命名",
      safety6: "中断后自动恢复",
      featureTitle: "改之前，先看新名字",
      featureLead: "规则一改，列表立刻更新。未点「重命名」前不会写入磁盘；有冲突则整批阻止。",
      downloadTitle: "下载 FilesDesk",
      downloadLead: "macOS 14 及以上 · 开源免费 · Apple 芯片与 Intel · 当前 1.1.1",
      downloadCta: "获取最新版本",
      version: "版本",
      featSafeTitle: "安全",
      featUndoTitle: "撤销",
      featuresTitle: "功能"
    },
    mock: {
      rename: "重命名", presets: "预设", history: "历史", settings: "设置",
      remove: "删除 4000", prefix: "前缀 Taipei_", numbering: "编号 4001",
      suggest: "建议：去掉拷贝编号",
      files: "61 个项目", ready: "就绪", renameBtn: "重命名 13"
    },
    download: {
      title: "下载",
      intro: "FilesDesk 是 macOS 14 Sonoma 及更高版本的原生应用。当前版本：",
      cta: "下载 .zip",
      source: "GitHub 源码",
      afterTitle: "安装后",
      after: "解压后将 FilesDesk 拖入「应用程序」，添加文件或文件夹即可开始。应用会通过 Sparkle 从此站点检查更新。",
      reqTitle: "系统要求",
      req1: "Universal 二进制：Apple 芯片（M 系列）与 Intel",
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
      a4: "预设是一组可复用的规则模板。内置摄影、截图、电商、文档、视频、微信图片、去掉拷贝编号、日期前缀、顺序编号等，也可保存自己的规则。",
      q5: "如何在线更新？",
      a5: "应用使用 Sparkle，读取本站 appcast.xml，并从 GitHub Releases 下载已签名的更新包。",
      q6: "需要账号吗？",
      a6: "不需要。无登录、无云同步、无账号体系。",
      q7: "怎么把文件夹改成 4001、4002、4003？",
      a7: "范围选「文件夹」。先用「删除」去掉原来的 4000，再加「编号」：起始 4001、位数 4、分隔符留空、位置选文件名前。",
      q8: "刷新按钮做什么？",
      a8: "从磁盘重新读取当前名称、权限和是否还在。适合在 Finder 里改过文件后再继续重命名。"
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
      v111Date: "2026 年 8 月 14 日",
      v111Items: [
        "输入规则后立即预览新名称",
        "刷新按钮可重新读取磁盘上的文件状态",
        "编号只对当前范围（文件或文件夹）连续计数",
        "新增视频、微信图片、拷贝编号、日期、顺序编号等预设"
      ],
      v110Date: "2026 年 8 月 14 日",
      v110Items: [
        "中文界面，文件和文件夹可一起重命名",
        "嵌套文件夹可同时加前缀，不再误报错误",
        "智能建议：摄影、截图、拷贝编号、文件夹前缀",
        "侧边栏与官网导航改版",
        "Universal：Apple 芯片与 Intel"
      ],
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
      faq: { title: "FAQ — FilesDesk", desc: "Answers about FilesDesk preview, undo, presets, folder numbering, and refresh." },
      privacy: { title: "Privacy — FilesDesk", desc: "FilesDesk privacy policy. Renaming stays local; updates use Sparkle." },
      changelog: { title: "Changelog — FilesDesk", desc: "FilesDesk release history and Sparkle update feed." }
    },
    nav: { features: "Features", download: "Download", faq: "FAQ", privacy: "Privacy", changelog: "Updates", moreApps: "More Apps", menu: "Menu" },
    lang: { label: "Language", zh: "中文", en: "English" },
    home: {
      badge: "macOS 14+ · Apple silicon & Intel · Native",
      lede: "Rename thousands of files at once",
      sub: "Drag in files or folders, combine 9 rules, and see new names as you type. Smart suggestions, 12 presets, folder numbering. A native Mac tool that never overwrites existing files.",
      cta: "Download for Mac",
      source: "View source",
      statRules: "9",
      statRulesLabel: "Rule types",
      statFiles: "12",
      statFilesLabel: "Presets",
      statFolders: "Folders",
      statFoldersLabel: "Sequential numbering too",
      statSafe: "0",
      statSafeLabel: "Overwrites",
      pillarsEyebrow: "Core capabilities",
      pillarsTitle: "See first. Rename safely.",
      pillarsLead: "Every step previews, validates, then writes — never the other way around.",
      pillar1Title: "Live preview",
      pillar1Desc: "New names update as you type. Preview never writes to disk — no generate button needed.",
      pillar2Title: "Smart suggestions",
      pillar2Desc: "Detects camera files, screenshots, copy numbers, and parent folders — apply a rule in one click.",
      pillar3Title: "Safety checks",
      pillar3Desc: "Duplicates, overwrites, empty names, invalid chars, permissions — errors block rename.",
      pillar4Title: "Undo & history",
      pillar4Desc: "Every batch is saved. Restore original names from the banner or History page.",
      rulesEyebrow: "Rename rules",
      rulesTitle: "9 rules, freely combined",
      rulesLead: "Photos, screenshots, e-commerce, documents, videos, WeChat, folders — everyday cleanup, covered.",
      ruleReplace: "Replace", ruleReplaceDesc: "Find and replace text",
      rulePrefix: "Prefix", rulePrefixDesc: "Insert at the start",
      ruleSuffix: "Suffix", ruleSuffixDesc: "Insert before extension",
      ruleRemove: "Remove", ruleRemoveDesc: "Delete matching text",
      ruleNumber: "Number", ruleNumberDesc: "001, 002 sequential",
      ruleCase: "Case", ruleCaseDesc: "Lower, upper, title",
      ruleDate: "Date", ruleDateDesc: "Created, modified, now",
      ruleCleanup: "Cleanup", ruleCleanupDesc: "Spaces, symbols, accents",
      ruleRegex: "Regex", ruleRegexDesc: "Advanced pattern match",
      exampleLabel: "Example",
      exampleSteps: "Remove IMG_ + Prefix Taipei_ + Number",
      flowEyebrow: "Workflow",
      flowTitle: "Three steps to batch rename",
      flow1Title: "Add", flow1Desc: "Drag files or folders. Rename folders only, or import what is inside.",
      flow2Title: "Configure rules", flow2Desc: "Add a rule or apply a suggestion — new names appear immediately. ⌘R reloads the latest disk state.",
      flow3Title: "Rename safely", flow3Desc: "Validate, then rename. Two-phase temp names handle A↔B swaps.",
      scenesEyebrow: "Use cases",
      scenesTitle: "From albums to SKUs, one flow",
      scene1: "Photography",
      scene2: "Screenshots",
      scene3: "E-commerce",
      scene4: "Documents",
      scene5: "Folders",
      scene6: "WeChat",
      bentoEyebrow: "More features",
      bentoTitle: "Details a pro tool should have",
      bentoImportTitle: "Flexible import",
      bentoImportDesc: "Drag & drop, add files, add folders. The table shows original, new, type, size, status. Search, select all, Quick Look, Reveal in Finder.",
      bentoFolderTitle: "Files and folders",
      bentoFolderDesc: "Rename folders only, or the files inside. Numbering counts only the current scope. Switch: All / Files / Folders.",
      bentoSmartTitle: "Smart suggestions",
      bentoSmartDesc: "Suggestions for photos, screenshots, copy numbers, and folder prefixes — apply with one click.",
      bentoRefreshTitle: "Refresh",
      bentoRefreshDesc: "⌘R reloads names and permissions from disk. Missing items drop out of the list, then preview updates.",
      bentoPresetTitle: "Presets",
      bentoPresetDesc: "12 built-ins: photos, screenshots, e-commerce, documents, videos, WeChat images, strip copy numbers, date prefix, sequential numbers, and more. Save your own too.",
      bentoPerfTitle: "Scale",
      bentoPerfDesc: "Handles 10,000+ files. Preview runs on background threads without blocking the UI.",
      bentoNativeTitle: "Native macOS",
      bentoNativeDesc: "SwiftUI + AppKit. NavigationSplitView, Table, sandbox. Light and dark mode.",
      bentoUpdateTitle: "Auto-update",
      bentoUpdateDesc: "Sparkle in-app updates with EdDSA signature verification.",
      safetyEyebrow: "Safety",
      safetyTitle: "Never lose user files",
      safetyLead: "Full validation before rename. Temp names during execution. Recovery after interruption.",
      safety1: "Never overwrite existing files",
      safety2: "Detect duplicate names in batch",
      safety3: "Block empty and invalid filenames",
      safety4: "Check directory write permission",
      safety5: "Two-phase temporary rename",
      safety6: "Auto-recover after interruption",
      featureTitle: "See the new name first",
      featureLead: "Rules update the list as you type. Nothing is written until you rename, and conflicts block the batch.",
      downloadTitle: "Download FilesDesk",
      downloadLead: "macOS 14+ · Free & open source · Apple silicon and Intel · Now 1.1.1",
      downloadCta: "Get the latest build",
      version: "Version",
      featSafeTitle: "Safety",
      featUndoTitle: "Undo",
      featuresTitle: "Features"
    },
    mock: {
      rename: "Rename", presets: "Presets", history: "History", settings: "Settings",
      remove: "Remove 4000", prefix: "Prefix Taipei_", numbering: "Number 4001",
      suggest: "Suggestion: strip copy numbers",
      files: "61 items", ready: "Ready", renameBtn: "Rename 13"
    },
    download: {
      title: "Download",
      intro: "FilesDesk is a native Mac app for macOS 14 Sonoma and later. Current release:",
      cta: "Download .zip",
      source: "Source on GitHub",
      afterTitle: "After install",
      after: "Open the zip, move FilesDesk to Applications, then add files or a folder. Updates are checked via Sparkle from this site.",
      reqTitle: "Requirements",
      req1: "Universal Binary: Apple silicon (M series) and Intel",
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
      a4: "Presets are reusable rule templates. Built-ins include photos, screenshots, e-commerce, documents, videos, WeChat images, strip copy numbers, date prefix, sequential numbers, and more. You can also save your own.",
      q5: "How do in-app updates work?",
      a5: "FilesDesk uses Sparkle to read the appcast on this site and install signed builds from GitHub Releases.",
      q6: "Is there an account?",
      a6: "No. No login, cloud sync, or account system.",
      q7: "How do I rename folders to 4001, 4002, 4003?",
      a7: "Set scope to Folders. Use Remove to strip the original 4000, then Numbering: start 4001, 4 digits, empty separator, position Before name.",
      q8: "What does Refresh do?",
      a8: "It reloads current names, permissions, and whether items still exist on disk. Use it after you change files in Finder."
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
      v111Date: "August 14, 2026",
      v111Items: [
        "New names update as soon as you type a rule",
        "Refresh reloads names, permissions, and missing files from disk",
        "Numbering counts only items in the current scope",
        "More presets: videos, WeChat photos, copy numbers, dates, sequential names"
      ],
      v110Date: "August 14, 2026",
      v110Items: [
        "Chinese-first UI; rename files and folders in one list",
        "Nested folders can be renamed together",
        "Smart suggestions for photos, screenshots, copy numbers, and folder prefixes",
        "Redesigned sidebar and website navigation",
        "Universal binary for Apple silicon and Intel"
      ],
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
  document.querySelectorAll("[data-i18n-aria]").forEach((el) => {
    const val = t(lang, el.dataset.i18nAria);
    if (typeof val === "string") el.setAttribute("aria-label", val);
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
