//
//  TodoItemViewModel.swift
//  Todo_App
//
//  Created by admin on 27/10/25.
//

import Foundation
import RxRelay

class TodoItemViewModel: CellViewModel {
    let item: Tasks
    
    let calendar = Calendar.current
    
    init(item: Tasks) {
        self.item = item
        super.init()
        self.title.accept(item.title)
        self.dueDate.accept(stringDate(date: item.dueDate))
        self.category.accept(nameCategoryImg(category: item.category))
        self.isComplete.accept(item.isComplete)
        print("a")
    }
    
    func stringDate(date: Date) -> String {
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = Configs.DateFormart.time
        if calendar.isDateInToday(date) {
            timeFormat.dateFormat = Configs.DateFormart.dateTime
        }
        
        return timeFormat.string(from: date)
    }
    
    func nameCategoryImg(category : Categorys) -> String? {
        switch category {
        case .EVENT:
            return "Event"
        case .GOAL:
            return "Goal"
        case .TASK:
            return "Task"
        }
    }
}
