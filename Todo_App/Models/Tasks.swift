//
//  Task.swift
//  Todo_App
//
//  Created by admin on 14/10/25.
//

import Foundation

struct Tasks: Codable {
    
    let id: Int?
    let title: String
    let dueDate: Date
    let notes: String?
    let isComplete: Bool
    let category: Categorys
    let userId: String?
//    let createdAt: Date
//    let completedAt: Date?

    enum CodingKeys: String, CodingKey {
        case id
        case title
        case dueDate = "due_date"
        case notes = "note"
        case isComplete = "is_complete"
        case category
        case userId = "user_id"
//        case createdAt = "created_at"
//        case completedAt = "completed_at"
    }
    
    init(id: Int?, title: String, dueDate: Date, notes: String?, isComplete: Bool, category: Categorys) {
        self.id = id
        self.title = title
        self.dueDate = dueDate
        self.notes = notes
        self.isComplete = isComplete
        self.category = category
        self.userId = nil
    }
}




