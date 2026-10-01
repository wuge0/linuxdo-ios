//
//  main.swift
//  Reynard
//
//  Created by Minh Ton on 1/2/26.
//

import Foundation
import GeckoView
import UIKit
import Darwin

@available(iOS, introduced: 13.0, obsoleted: 14.0)
private func configureUnsandboxedAppDataDirectories() {
    guard let cachesDirectory = FileManager.default.urls(
        for: .cachesDirectory,
        in: .userDomainMask
    ).first else {
        return
    }
    
    guard let bundleIdentifier = Bundle.main.bundleIdentifier else {
        return
    }
    
    let appDataDirectory = cachesDirectory
        .appendingPathComponent(bundleIdentifier, isDirectory: true)
        .appendingPathComponent(".mozilla", isDirectory: true)
        .appendingPathComponent("firefox", isDirectory: true)
    
    do {
        try FileManager.default.createDirectory(
            at: appDataDirectory,
            withIntermediateDirectories: true
        )
    } catch {
        return
    }
    
    setenv("MOZ_APP_DATA", appDataDirectory.path, 1)
    setenv("MOZ_LOCAL_APP_DATA", appDataDirectory.path, 1)
}

private func configureSandboxExtension() {
    guard let documentsDirectoryURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
        return
    }
    
    typealias IssueFileExtension = @convention(c) (UnsafePointer<CChar>, UnsafePointer<CChar>, UInt32) -> UnsafeMutablePointer<CChar>?
    
    // I can't seem to find any public documentation for these stuff on iOS?
    // Also I'm surprised that this works on iOS
    // https://github.com/WebKit/WebKit/blob/main/Source/WTF/wtf/spi/darwin/SandboxSPI.h
    // https://github.com/WebKit/WebKit/blob/main/Source/WebKit/Shared/Cocoa/SandboxExtensionCocoa.mm
    guard let sandboxHandle = dlopen("/usr/lib/system/libsystem_sandbox.dylib", RTLD_LAZY),
          let symbol = dlsym(sandboxHandle, "sandbox_extension_issue_file") else {
        return
    }
    
    let issueFileExtension = unsafeBitCast(symbol, to: IssueFileExtension.self)
    let extensionClass = "com.apple.app-sandbox.read"
    
    guard let token = extensionClass.withCString({ extensionClassPointer in
        documentsDirectoryURL.path.withCString { pathPointer in
            issueFileExtension(extensionClassPointer, pathPointer, 0)
        }
    }) else {
        return
    }
    
    let tokenString = String(cString: token)
    free(UnsafeMutableRawPointer(token))
    setenv("MOZ_DOCUMENTS_SANDBOX_EXTENSION", tokenString, 1)
}

LocalizationBundle.activate()
JITController.shared.start()

if #unavailable(iOS 14.0),
   getEntitlementValue("com.apple.private.security.no-sandbox") {
    configureUnsandboxedAppDataDirectories()
}

configureSandboxExtension()

_ = NotificationCenter.default.addObserver(forName: Notification.Name("GeckoView.BuildMenu"), object: nil, queue: .main) { notification in
    guard let builder = notification.object as? UIMenuBuilder else { return }
    ApplicationMenuBuilder.build(with: builder)
}

// --- linux.do 客户端：首次启动写入默认首屏 ---
// 用 UserDefaults 直接探测是否已写过，避免覆盖用户手动改过的设置。
private func applyLinuxDOFirstRunDefaults() {
    guard ClientMode.enabled else { return }

    let flagKey = "linuxdo.firstRunApplied"
    let defaults = UserDefaults.standard

    // 只在全新安装时设置一次；用户之后在设置里改动会保留
    guard !defaults.bool(forKey: flagKey) else { return }

    Prefs.NewTabSettings.newTabDisplayOption = .customURL
    Prefs.NewTabSettings.customNewTabURL = ClientMode.startURL
    // 首屏用 lastTab，配合新标签页的 customURL 一起生效
    Prefs.HomepageSettings.openingScreen = .lastTab

    defaults.set(true, forKey: flagKey)
    NSLog("[linuxdo] 已写入默认首屏: \(ClientMode.startURL)")
}

applyLinuxDOFirstRunDefaults()

GeckoRuntime.main(argc: CommandLine.argc, argv: CommandLine.unsafeArgv)
