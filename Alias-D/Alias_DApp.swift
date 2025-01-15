//
//  Alias_DApp.swift
//  Alias-D
//
//  Created by Denys Spasiuk on 15.01.2025.
//

import SwiftUI
import AppKit
import Cocoa

@main
struct AliasFileCheckerApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .onAppear {
                    NSApp.setActivationPolicy(.regular)
                    if let appIcon = NSImage(named: "AppIcon") {
                        NSApplication.shared.applicationIconImage = appIcon
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
    }
}


class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBar: NSStatusItem!
    var mainWindow: NSWindow?
    
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)

        // Создаем статусный элемент в статус-баре
        statusBar = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusBar.button {
            if let menuBarIcon = NSImage(named: "MenuBarIcon") {
                menuBarIcon.size = NSSize(width: 18, height: 18)
                button.image = menuBarIcon
            }
        }
        
        // Создаем меню для значка
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Показать", action: #selector(showWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "О программе", action: #selector(showAboutPanel), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Выход", action: #selector(quitApp), keyEquivalent: "q"))
        
        // Присваиваем меню значку
        statusBar.menu = menu
        
        // Сохраняем ссылку на главное окно и настраиваем его
        if let window = NSApplication.shared.windows.first {
            mainWindow = window
            window.styleMask.insert(.closable)
            window.styleMask.insert(.titled)
            window.isReleasedWhenClosed = false
            window.delegate = self // Добавляем делегат окна
        }
    }

    @objc func showAboutPanel() {
        let aboutIcon = NSImage(named: "AppIcon")
        aboutIcon?.size = NSSize(width: 512, height: 512)
        
        let creditsString = NSAttributedString(
            html: Data("""
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="utf-8">
                </head>
                <body>
                    Разработчик: Spasiuk Denys<br>
                    Email: <a href="mailto:denys.ops@gmail.com">denys.ops@gmail.com</a>
                </body>
                </html>
                """.utf8),
            options: [.documentType: NSAttributedString.DocumentType.html],
            documentAttributes: nil
        )
        
        let aboutPanelOptions: [NSApplication.AboutPanelOptionKey: Any] = [
            .applicationName: "Alias-D",
            .applicationVersion: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0",
            .applicationIcon: aboutIcon ?? NSImage(),
            .credits: creditsString ?? NSAttributedString()
        ]
        
        NSApp.orderFrontStandardAboutPanel(options: aboutPanelOptions)
    }

    @objc func showWindow() {
        NSApp.setActivationPolicy(.regular)
        
        if mainWindow == nil {
            // Если окно было освобождено, создаем новое
            let window = NSWindow(
                contentRect: NSRect(x: 0, y: 0, width: 960, height: 720),
                styleMask: [.titled, .closable, .miniaturizable, .resizable],
                backing: .buffered,
                defer: false
            )
            window.center()
            window.contentView = NSHostingView(rootView: ContentView())
            window.isReleasedWhenClosed = false
            window.delegate = self // Добавляем делегат окна
            mainWindow = window
        }
        
        mainWindow?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quitApp() {
        NSApp.terminate(nil)
    }
}

// Расширяем AppDelegate для обработки закрытия окна
extension AppDelegate: NSWindowDelegate {
    func windowWillClose(_ notification: Notification) {
        NSApp.setActivationPolicy(.accessory)
    }
}
