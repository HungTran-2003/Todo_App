//
//  TodoItemViewModel.swift
//  Todo_App
//
//  Created by admin on 27/10/25.
//

import Foundation
import RxRelay

class TodoItemViewModel: CellViewModel {
    private(set) var item: Tasks

    let calendar = Calendar.current
    let onCompletionChanged = PublishRelay<(Bool, IndexPath)>()

    init(item: Tasks) {
        self.item = item
        super.init()
        bindData()
    }
    
    func bindData(){
        self.title.accept(item.title)
        self.dueDate.accept(stringDate(date: item.dueDate))
        self.category.accept(nameCategoryImg(category: item.category))
        self.isComplete.accept(item.isComplete)
    }

    func stringDate(date: Date) -> String {
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = Configs.DateFormart.dateTime
        if calendar.isDateInToday(date) {
            timeFormat.dateFormat = Configs.DateFormart.time
        }

        return timeFormat.string(from: date)
    }

    func nameCategoryImg(category: Categorys) -> String? {
        switch category {
        case .EVENT:
            return "Event"
        case .GOAL:
            return "Goal"
        case .TASK:
            return "Task"
        }
    }

    func updateTask(task: Tasks? = nil, isCompleteBefore: Bool, indexPath: IndexPath) {
        let taskComplete = Tasks(id: item.id, title: item.title, dueDate: item.dueDate, notes: item.notes, isComplete: true, category: item.category)
        
        Task {
            let taskUpdate = try await TaskService.share.updateTask(task: task ?? taskComplete)
            let changeSection = taskUpdate.isComplete != item.isComplete
            self.item = taskUpdate
            bindData()
            self.onCompletionChanged.accept((changeSection, indexPath))
        }
    }
}
