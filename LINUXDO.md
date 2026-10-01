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
3. 在 Artifacts 下载 `Reynard-TrollStore-tipa`

## 安装

需要 **TrollStore**（iOS 14 – 16.6.1）：

1. 下载 `.tipa`
2. 传到 iPhone
3. 用 TrollStore 打开安装

TrollStore 构建自动启用 JIT，浏览器性能有保障。

## 上游

- 原项目：https://github.com/minh-ton/reynard-browser
- 许可证：GPL-3.0（Gecko 补丁部分为 MPL-2.0）
