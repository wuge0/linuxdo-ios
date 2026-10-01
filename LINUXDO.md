# linux.do iOS 客户端

基于 [Reynard](https://github.com/minh-ton/reynard-browser)（Gecko 内核 iOS 浏览器）改造的
linux.do 专属客户端，用于在 **iOS 15** 等旧系统上访问 linux.do。

## 为什么需要它

Discourse（linux.do 的建站程序）从 2025 年 7 月起要求 **iOS 16.7+**，
因为用到了相对颜色语法、subgrid、正则 lookbehind、import maps 等特性。

iOS 上的 Safari / Chrome / Firefox 全部强制使用系统 WebKit，
旧系统的 WebKit 版本不够 → 白屏。

**Reynard 自带 Gecko 引擎，绕开系统 WebKit 限制。**

## 定制内容

| 项 | 改动 |
|---|---|
| App 名称 | `linuxdo` |
| Bundle ID | `do.linux.client` |
| 默认首屏 | `https://linux.do` |
| 图标 | linux.do 风格蓝色圆标 |
| 地址栏 | 隐藏（纯客户端观感） |
| 工具栏 | 只留 返回 / 前进 / 分享 / 标签 |
| 首页模块 | 去掉推荐、常访问 |

所有开关集中在 `browser/Reynard/Client/ClientMode.swift`。

## 构建

GitHub Actions 自动构建（`.github/workflows/build-linuxdo.yml`）：

1. 进 **Actions** → **Build linux.do Client** → **Run workflow**
2. 等约 60–90 分钟（首次编译 Gecko 很慢）
3. 构建完成后自动创建 **Release**，直接下载即可

```bash
# 或用命令行触发
gh workflow run build-linuxdo.yml -R wuge0/linuxdo-ios \
  -f build_trollstore=true -f build_normal=false
```

产物同时上传为 Actions Artifacts（保留 30 天），
但 **Release 才是推荐入口** —— 无体积限制、长期保留、手机点链接即可安装。

## 安装

需要 **TrollStore**（iOS 14 – 16.6.1）：

1. 在手机上点开 Release 里的 `.tipa` 链接
2. 下载完成后 TrollStore 会自动弹窗识别
3. 点安装

TrollStore 构建自动启用 JIT，浏览器性能有保障。

## 踩过的坑

| 现象 | 原因 | 解法 |
|---|---|---|
| CI 报 `pathspec 'support/idevice' did not match` | 重建仓库时用 `git add -A`，工作区里子模块目录为空 → git 判定为删除，提交树里丢了两个子模块 gitlink | 用 `git update-index --add --cacheinfo 160000,<sha>,<path>` 直接写 gitlink，不要依赖工作区状态 |
| 打好的 TIPA 里 Bundle ID 变回 `com.minh-ton.Reynard` | `tools/release/create-ipa.sh` 里硬编码了 `plutil -replace CFBundleIdentifier` | 已同步改为 `do.linux.client` |
| App 名字改了，但脚本路径全炸 | — | **不用改** `PRODUCT_NAME`：`INFOPLIST_KEY_CFBundleDisplayName = $(APP_DISPLAY_NAME)` 只影响显示名，`.app` 目录名仍是 `Reynard.app`，所有脚本路径保持有效 |
| YAML 报 `could not find expected ':'` | `--notes` 里的多行文本从第 1 列开始，打断了 YAML 块 | 改写成单行字符串 |

## 上游

- 原项目：https://github.com/minh-ton/reynard-browser
- 许可证：GPL-3.0（Gecko 补丁部分为 MPL-2.0）
