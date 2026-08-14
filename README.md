<p align="center">
  <img src="docs/assets/icon.png" width="96" height="96" alt="FilesDesk">
</p>

<h1 align="center">FilesDesk</h1>

<p align="center">
  <strong>Mac 智能批量重命名</strong><br>
  原生、安全、即时预览。一次整理上千个文件和文件夹。
</p>

<p align="center">
  <b>中文</b> · <a href="./README.en.md">English</a>
</p>

<p align="center">
  <a href="https://github.com/linux503/FilesDesk/releases/latest"><img src="https://img.shields.io/github/v/release/linux503/FilesDesk?style=flat-square&label=release&color=0D7EA8" alt="Release"></a>
  <a href="https://github.com/linux503/FilesDesk/releases"><img src="https://img.shields.io/badge/macOS-14%2B-111111?style=flat-square" alt="macOS 14+"></a>
  <a href="https://github.com/linux503/FilesDesk/releases"><img src="https://img.shields.io/badge/Universal-arm64%20%7C%20x86_64-24292f?style=flat-square" alt="Universal"></a>
  <a href="./LICENSE"><img src="https://img.shields.io/badge/license-MIT-5A7286?style=flat-square" alt="MIT"></a>
</p>

<p align="center">
  <a href="https://linux503.github.io/FilesDesk/FilesDesk.dmg"><strong>下载 DMG</strong></a>
  ·
  <a href="https://linux503.github.io/FilesDesk/">官网</a>
  ·
  <a href="https://github.com/linux503/FilesDesk/releases">全部版本</a>
</p>

---

<p align="center">
  <img src="docs/screenshots/rename-window.png" alt="FilesDesk 重命名界面：左侧导航、中间预览列表、右侧规则" width="880">
</p>

拖入文件或文件夹，组合规则，列表立刻显示新名称。未点「重命名」前不写磁盘；有冲突则整批阻止。**绝不覆盖已有文件。**

<p align="center">
  <img src="docs/screenshots/presets-window.png" alt="FilesDesk 预设：12 套内置规则模板" width="880">
</p>

## 为什么用 FilesDesk

| | |
|---|---|
| **看得见再改** | 规则一边输入，新名称一边更新，不必点生成 |
| **文件和文件夹** | 同一列表处理；范围可切全部 / 文件 / 文件夹 |
| **改错能回** | 每次成功重命名写入历史，一键撤销 |
| **原生 Mac** | SwiftUI + AppKit，浅色/深色自动适配 |
| **一套安装包** | Universal：Apple 芯片与 Intel |

## 功能

| 能力 | 说明 |
|------|------|
| **导入** | 拖拽、添加文件、添加文件夹；可只改文件夹，或导入其中内容 |
| **实时预览** | 输入即更新；大规模时后台计算，不卡界面 |
| **智能建议** | 识别相机文件、截图、拷贝编号、所在文件夹，一键套用 |
| **10 种规则** | 替换、前缀、后缀、删除、删除前几位、编号、大小写、日期、清理、正则 |
| **范围编号** | 编号只对当前范围连续计数，文件不会打乱文件夹序号 |
| **12 套预设** | 摄影、截图、电商、文档、视频、微信等，也可保存自己的规则 |
| **刷新 ⌘R** | 从磁盘重读名称、权限；已删除的项目会从列表去掉 |
| **安全校验** | 重名、覆盖、空名、非法字符、无权限 → 阻止执行 |
| **撤销 / 历史** | 两阶段临时名，支持 A↔B 互换；中断后可恢复 |
| **自动更新** | Sparkle 应用内更新，EdDSA 签名 |

## 10 种规则

| 规则 | 做什么 |
|------|--------|
| 替换 | 查找并替换文本 |
| 前缀 / 后缀 | 在文件名前或扩展名前插入 |
| 删除 | 去掉指定文字 |
| **删除前几位** | 从开头去掉固定个数的字符，适合 `IMG_`、`4000` |
| 编号 | `001`、`4001` 等顺序编号，可放在名前 / 名后 / 替换整名 |
| 大小写 | 小写、大写、标题、句首大写 |
| 日期 | 创建 / 修改 / 当前日期 |
| 清理 | 空格、符号、重音 |
| 正则 | 高级模式匹配 |

规则可叠加、排序、随时启用或停用。

## 12 套预设

摄影 · 截图 · 电商 · 文档 · 视频 · 微信图片 · 去掉拷贝编号 · 今天日期前缀 · 顺序编号 · 空格改下划线 · 连字符小写 · 全部小写

## 快速上手

**把 `4000-AA-1 (16)` 改成 `4001`、`4002`、`4003`：**

1. 拖入这些文件夹  
2. 底部范围选 **文件夹**  
3. 添加 **删除前几位**，位数填 `4`  
4. 添加 **编号**：起始 `4001`，位数 `4`，分隔符留空，位置选 **文件名前**  
5. 列表确认新名称后，点 **重命名**

摄影文件同理：套用智能建议，或用预设「摄影」去掉 `IMG_` 再加前缀。

## 安全

- 禁止覆盖已有文件  
- 检测批量结果重名  
- 拦截空文件名与非法字符  
- 检查目录写入权限  
- 两阶段临时重命名，中断后自动恢复  

## 安装

1. 下载 [FilesDesk.dmg](https://linux503.github.io/FilesDesk/FilesDesk.dmg)  
2. 打开磁盘映像，将 **FilesDesk** 拖入「应用程序」  
3. 若系统提示无法打开：系统设置 → 隐私与安全性 → 仍要打开  

需要 **macOS 14+**。应用内会通过 Sparkle 检查更新。

## 快捷键

| 操作 | 快捷键 |
|------|--------|
| 添加文件 | ⌘O |
| 添加文件夹 | ⌘⇧O |
| 刷新状态 | ⌘R |
| 重命名 | ⌘⇧R |
| 撤销上次重命名 | ⌘⌥Z |
| 快速查看 | ⌘Y |
| 在 Finder 中显示 | ⌘⌃R |
| 全选列表 | ⌘⇧A |

## 从源码构建

需要 **Xcode 16+**、macOS 14+。

```bash
git clone https://github.com/linux503/FilesDesk.git
cd FilesDesk
make test
make build
```

发布（测试 → Universal 安装包 → GitHub Release → Sparkle 更新源 → 官网 DMG）：

```bash
make release VERSION=1.1.2
```

Sparkle 私钥放在本地 `sparkle/eddsa-private.key`，不要提交。

```text
FilesDesk/           应用源码
FilesDeskTests/      重命名引擎测试
docs/                官网、FAQ、隐私、更新日志、Sparkle 源、DMG
scripts/             构建、签名、发布
```

## 链接

- 官网：https://linux503.github.io/FilesDesk/  
- 更新源：https://linux503.github.io/FilesDesk/appcast.xml  
- 问题反馈：https://github.com/linux503/FilesDesk/issues  

## 许可

[MIT](./LICENSE)
