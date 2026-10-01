//
//  ClientMode.swift
//  linux.do 客户端模式
//
//  由 apply-client-mode.sh 生成。关闭客户端模式只需把 enabled 改成 false。
//

import Foundation

enum ClientMode {
    /// 总开关：true = 纯客户端观感，false = 恢复完整浏览器
    static let enabled = true

    /// 站点地址
    static let startURL = "https://linux.do"

    /// 隐藏地址栏（客户端观感的关键）
    static let hideAddressBar = true

    /// 底部工具栏只保留这些按钮（顺序即显示顺序）
    /// 可选：.back .forward .share .library .tabOverview .download .newTab .sidebar
    static let visibleToolbarButtons: [ToolbarButton.ButtonType] = [
        .back, .forward, .share, .tabOverview
    ]

    /// 隐藏侧边栏入口
    static let hideSidebar = true

    /// 关闭首页推荐/常访问模块（客户端不需要）
    static let hideHomepageRecommendations = true

    /// 强制单窗口观感：隐藏标签总览的多标签能力
    static let singleTabMode = false
}
