//
//  TaskSection.swift
//  Todo_App
//
//  Created by admin on 20/10/25.
//
import RxDataSources

struct TaskSection {
    var header: String?
    var items: [TodoItemViewModel]
}

extension TaskSection: SectionModelType {
    
    init(original: TaskSection, items: [TodoItemViewModel]) {
        self = original
        self.items = items
    }
}

