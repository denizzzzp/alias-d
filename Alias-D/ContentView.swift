//
//  ContentView.swift
//  Alias-D
//
//  Created by Denys Spasiuk on 15.01.2025.
//

import SwiftUI
import AppKit
import Foundation

enum AliasType {
    case alias
    case function
}

struct AliasItem: Identifiable {
    let id = UUID()
    var isActive: Bool
    var type: AliasType
    var content: String
}

struct ContentView: View {
    @State private var aliasItems: [AliasItem] = []
    @State private var newAliasType: AliasType = .alias
    @State private var newAliasContent: String = ""
    @State private var isIntegratedWithZshrc: Bool = false
    
    var body: some View {
        VStack {                
            Toggle("Интеграция с .zshrc", isOn: $isIntegratedWithZshrc)
                .onChange(of: isIntegratedWithZshrc) { newValue in
                    toggleZshrcIntegration(enabled: newValue)
                }
                .padding()
                
            Spacer()
            List {
                ForEach($aliasItems) { $alias in
                    HStack(alignment: .top) {
                        Toggle("", isOn: $alias.isActive)
                            .frame(width: 40)
                        
                        Picker("Тип", selection: $alias.type) {
                            Text("Alias").tag(AliasType.alias)
                            Text("Function").tag(AliasType.function)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .frame(width: 120)
                        
                        if alias.type == .alias {
                            TextField("alias -- name='command'", text: $alias.content)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                        } else {
                            TextEditor(text: $alias.content)
                                .frame(height: 100)
                                .border(Color.gray, width: 1)
                                .font(.system(size: NSFont.systemFontSize + 2))
                        }
                        
                        Button(action: {
                            if let index = aliasItems.firstIndex(where: { $0.id == alias.id }) {
                                aliasItems.remove(at: index)
                            }
                        }) {
                            Image(systemName: "trash")
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
            
            HStack {
                Picker("Новый тип", selection: $newAliasType) {
                    Text("Alias").tag(AliasType.alias)
                    Text("Function").tag(AliasType.function)
                }
                .pickerStyle(SegmentedPickerStyle())
                .frame(width: 120)
                
                if newAliasType == .alias {
                    TextField("alias -- name='command'", text: $newAliasContent)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    TextEditor(text: $newAliasContent)
                        .frame(height: 100)
                        .border(Color.gray, width: 1)
                        .font(.system(size: NSFont.systemFontSize + 2))
                }
                
                Button(action: addNewAlias) {
                    Image(systemName: "plus")
                        .font(.title2)
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }
            }
            .padding(.top)
            // Кнопка сохранения файла
            Button("Сохранить изменения") {
                saveFile()
            }
            .padding(.top)
        }
        .padding()
        .onAppear {
            loadFile()
            checkZshrcIntegration()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func addNewAlias() {
        guard !newAliasContent.isEmpty else { return }
        aliasItems.append(AliasItem(isActive: true, type: newAliasType, content: newAliasContent))
        newAliasContent = ""
    }
    
    private func checkZshrcIntegration() {
        let fileManager = FileManager.default
        let homeDirectory = fileManager.homeDirectoryForCurrentUser.path
        let zshrcPath = "\(homeDirectory)/.zshrc"
        
        do {
            let content = try String(contentsOfFile: zshrcPath, encoding: .utf8)
            let sourceLine = "source \(homeDirectory)/.alias-d/dotfile.zsh"
            isIntegratedWithZshrc = content.contains(sourceLine) && !content.contains("# \(sourceLine)")
        } catch {
            print("Ошибка при проверке .zshrc: \(error.localizedDescription)")
        }
    }
    
    private func toggleZshrcIntegration(enabled: Bool) {
        let fileManager = FileManager.default
        let homeDirectory = fileManager.homeDirectoryForCurrentUser.path
        let zshrcPath = "\(homeDirectory)/.zshrc"
        let sourceLine = "source \(homeDirectory)/.alias-d/dotfile.zsh"
        
        do {
            var content = try String(contentsOfFile: zshrcPath, encoding: .utf8)
            
            // Удаляем существующие строки (закомментированные и нет)
            content = content.components(separatedBy: .newlines)
                .filter { !$0.contains(sourceLine) }
                .joined(separator: "\n")
            
            // Добавляем новую строку с переносом строки
            content += "\n" + (enabled ? sourceLine : "# \(sourceLine)")
            
            try content.write(toFile: zshrcPath, atomically: true, encoding: .utf8)
            print("Интеграция с .zshrc \(enabled ? "включена" : "выключена")")
        } catch {
            print("Ошибка при обновлении .zshrc: \(error.localizedDescription)")
        }
    }
    
    func loadFile() {
        let fileManager = FileManager.default
        let homeDirectory = fileManager.homeDirectoryForCurrentUser.path
        let filePath = "\(homeDirectory)/.alias-d/dotfile.zsh"

        guard fileManager.fileExists(atPath: filePath) else {
            aliasItems = []
            print("Файл не найден: \(filePath), создаем пустой список.")
            return
        }

        do {
            let content = try String(contentsOfFile: filePath, encoding: .utf8)
            var lines = content.split(separator: "\n").map { String($0) }

            var tempFunction = ""
            var inFunction = false
            var isActiveFunction = true

            aliasItems = []

            for line in lines {
                if line.contains("() {") || (line.contains("# ") && line.contains("() {")) {  // Начало функции
                    inFunction = true
                    isActiveFunction = !line.hasPrefix("# ")
                    tempFunction = isActiveFunction ? line + "\n" : String(line.dropFirst(2)) + "\n"  // Начинаем собирать функцию
                } else if inFunction {
                    if isActiveFunction {
                        tempFunction += line + "\n"
                    } else {
                        let lineContent: String = line.hasPrefix("# ") ? String(line.dropFirst(2)) : line
                        tempFunction += lineContent + "\n"
                    }
                    if line.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("}") || 
                       line.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("# }") {  // Конец функции
                        aliasItems.append(AliasItem(isActive: isActiveFunction, type: .function, content: tempFunction))
                        inFunction = false
                        tempFunction = ""
                    }
                } else if line.hasPrefix("alias") || line.hasPrefix("# alias") {  // Алиас
                    let isActive = !line.hasPrefix("# ")
                    let content = isActive ? line : String(line.dropFirst(2)) // Убираем "# " если неактивный
                    aliasItems.append(AliasItem(isActive: isActive, type: .alias, content: content))
                }
            }

            print("Файл успешно загружен из \(filePath)")
        } catch {
            print("Ошибка чтения файла: \(error.localizedDescription)")
        }
    }

    func saveFile() {
        let fileManager = FileManager.default
        let homeDirectory = fileManager.homeDirectoryForCurrentUser.path
        let filePath = "\(homeDirectory)/.alias-d/dotfile.zsh"

        do {
            // Создаем папку .alias-d, если её нет
            let directoryPath = "\(homeDirectory)/.alias-d"
            if !fileManager.fileExists(atPath: directoryPath) {
                try fileManager.createDirectory(atPath: directoryPath, withIntermediateDirectories: true, attributes: nil)
            }

            // Сохраняем файл
            var content = ""
            for item in aliasItems {
                if item.type == .function {
                    if !item.isActive {
                        // Добавляем # к каждой строке функции
                        content += item.content.split(separator: "\n")
                            .map { "# " + $0 }
                            .joined(separator: "\n") + "\n"
                    } else {
                        content += item.content
                    }
                } else {
                    // Для алиасов оставляем старую логику
                    let itemContent = item.isActive ? item.content : "# " + item.content
                    content += itemContent.trimmingCharacters(in: .whitespacesAndNewlines) + "\n"
                }
            }
            
            // Удаляем пустые строки
            content = content.components(separatedBy: .newlines)
                .filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
                .joined(separator: "\n")

            try content.write(toFile: filePath, atomically: true, encoding: .utf8)
            
            // Устанавливаем права на исполнение файла
            try FileManager.default.setAttributes([.posixPermissions: 0o755], ofItemAtPath: filePath)
            
            print("Файл успешно сохранен в \(filePath)")
        } catch {
            print("Ошибка сохранения файла: \(error.localizedDescription)")
        }
    }
    
}
