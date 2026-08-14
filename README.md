<p align="center">
  <img src="docs/assets/icon.png" width="88" height="88" alt="FilesDesk" />
</p>

<h1 align="center">FilesDesk</h1>

<p align="center">
  <strong>Mac 智能批量重命名</strong><br/>
  拖拽导入、规则组合、输入即预览。绝不覆盖已有文件。
</p>

<p align="center">
  <b>中文</b> · <a href="README.en.md">English</a>
</p>

<p align="center">
  <a href="https://github.com/linux503/FilesDesk/releases/latest"><img src="https://img.shields.io/github/v/release/linux503/FilesDesk?style=flat-square&color=111111" alt="Release" /></a>
  <a href="https://github.com/linux503/FilesDesk/releases"><img src="https://img.shields.io/badge/macOS-14%2B-5b6cff?style=flat-square" alt="macOS 14+" /></a>
  <a href="LICENSE"><img src="https://img.shields.io/badge/License-MIT-2ea44f?style=flat-square" alt="License" /></a>
</p>

<p align="center">
  <a href="https://linux503.github.io/FilesDesk/FilesDesk.dmg"><strong>下载 DMG</strong></a>
  ·
  <a href="https://linux503.github.io/FilesDesk">官网</a>
  ·
  <a href="https://github.com/linux503/FilesDesk/releases">全部版本</a>
</p>

---

<p align="center">
  <img src="docs/assets/og.png" alt="FilesDesk" width="880" />
</p>

---

## 功能

原生 macOS 批量重命名。文件和文件夹可以放在同一列表里处理，实时预览新名字，执行前会校验。

| 能力 | 说明 |
|------|------|
| **导入** | 拖拽、添加文件、添加文件夹；支持嵌套文件夹一起改名 |
| **规则** | 替换、前缀、后缀、删除、去掉前 N 个字符、编号、大小写、日期、清理、正则 |
| **预览** | 改规则即刷新新名字；刷新按钮可从磁盘重读名称与权限 |
| **安全** | 阻止覆盖、重名、空名、权限错误；两阶段改名 |
| **撤销 / 历史** | 改完可撤销，历史可回看 |
| **预设** | 内置视频、微信照片、副本编号、日期、顺序名等，也可自存 |
| **建议** | 相机名、截图、Finder 副本、文件夹前缀等智能建议 |
| **更新** | Sparkle + [appcast.xml](https://linux503.github.io/FilesDesk/appcast.xml) |

需要 **macOS 14+**。Universal Binary（Apple Silicon + Intel）。

## 安装

1. 下载 [FilesDesk.dmg](https://linux503.github.io/FilesDesk/FilesDesk.dmg)
2. 将 **FilesDesk** 拖入「应用程序」
3. 官网支持中 / 英切换：https://linux503.github.io/FilesDesk

当前版本 **1.1.2**。

## 开发

```bash
make test
make build
```

用 Xcode 16 或更高打开 `FilesDesk.xcodeproj`。

```
FilesDesk/           应用源码
FilesDeskTests/      重命名引擎测试
docs/                官网、FAQ、隐私、changelog、Sparkle
scripts/             构建、测试、打 tag、发布
```

## 发布

```bash
make test
make release VERSION=1.1.2
```

脚本会构建、跑测试、打 `vVERSION`、发 GitHub Release、给 Sparkle 签名 zip，并更新 `docs/appcast.xml`。

Sparkle 私钥放在本地 `sparkle/eddsa-private.key`，切勿提交。仓库已配置 GitHub secret `SPARKLE_EDDSA_PRIVATE_KEY`。

## 其它工具

| 应用 | 说明 |
|------|------|
| [Flare Pro](https://github.com/linux503/Flare) | 截图与录屏 |
| [ZipX](https://github.com/linux503/ZipX) | 压缩 / 解压 / 预览 |
| [MacText](https://github.com/linux503/MacText) | 原生文本编辑器 |
| [SupTools](https://github.com/linux503/suptools) | 系统监控、清理、卸载 |
| [MacFan](https://github.com/linux503/MacFan) | 风扇转速 |

## 许可

[MIT](LICENSE)
