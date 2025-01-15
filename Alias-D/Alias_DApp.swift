//
//  Alias_DApp.swift
//  Alias-D
//
//  Created by Denys Spasiuk on 15.01.2025.
//

import SwiftUI
import AppKit

@main
struct AliasFileCheckerApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}


class AppDelegate: NSObject, NSApplicationDelegate {
    
    var statusBar: NSStatusItem!
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        // Создаем статусный элемент в статус-баре
        statusBar = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        if let button = statusBar.button {
            // Устанавливаем значок для приложения
            button.image = NSImage(systemSymbolName: "app.fill", accessibilityDescription: "Alias App")
        }
        
        // Создаем меню для значка
        let menu = NSMenu()
        menu.addItem(NSMenuItem(title: "Показать", action: #selector(showWindow), keyEquivalent: ""))
        menu.addItem(NSMenuItem(title: "Выход", action: #selector(quitApp), keyEquivalent: "q"))
        
        // Присваиваем меню значку
        statusBar.menu = menu
        
        // Устанавливаем политику активации как аксессуар (не отображать в доке)
        NSApp.setActivationPolicy(.accessory)
    }

    @objc func showWindow() {
        // Показать окно приложения
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc func quitApp() {
        // Завершаем приложение
        NSApp.terminate(nil)
    }
}
