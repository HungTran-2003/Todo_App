//
//  TaskSection.swift
//  Todo_App
//
//  Created by admin on 20/10/25.
//
import RxDataSources

struct TodoSection {
    var header: String?
    var items: [TodoItemViewModel]
}

extension TodoSection: SectionModelType {
    
    init(original: TodoSection, items: [TodoItemViewModel]) {
        self = original
        self.items = items
    }
}

