//
//  ContentView.swift
//  Alias-D
//
//  Created by Denys Spasiuk on 15.01.2025.
//

import SwiftUI

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
    
    var body: some View {
        VStack {
            Text("Alias-D редактор алиасов")
                .font(.headline)
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
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private func addNewAlias() {
        guard !newAliasContent.isEmpty else { return }
        aliasItems.append(AliasItem(isActive: true, type: newAliasType, content: newAliasContent))
        newAliasContent = ""
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

            aliasItems = []

            for line in lines {
                if line.contains("() {") {  // Начало функции
                    inFunction = true
                    tempFunction = line + "\n"  // Начинаем собирать функцию
                } else if inFunction {
                    tempFunction += line + "\n"
                    if line.trimmingCharacters(in: .whitespacesAndNewlines).hasPrefix("}") {  // Конец функции
                        aliasItems.append(AliasItem(isActive: true, type: .function, content: tempFunction))
                        inFunction = false
                        tempFunction = ""
                    }
                } else if line.hasPrefix("alias") {  // Алиас
                    aliasItems.append(AliasItem(isActive: true, type: .alias, content: line))
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
                if item.isActive {
                    // Если алиас или функция активен — записываем как есть
                    content += item.content + "\n"
                } else {
                    // Если не активен — закомментировать
                    content += "# " + item.content + "\n#"
                }
            }

            try content.write(toFile: filePath, atomically: true, encoding: .utf8)
            print("Файл успешно сохранен в \(filePath)")
        } catch {
            print("Ошибка сохранения файла: \(error.localizedDescription)")
        }
    }
    
}

