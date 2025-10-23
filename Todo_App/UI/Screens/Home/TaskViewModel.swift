//
//  TaskViewModel.swift
//  Todo_App
//
//  Created by admin on 14/10/25.
//

import Foundation
import RxRelay
import RxSwift

class TaskViewModel {
    
    let disposeBag = DisposeBag()
    
    var tasks: [Tasks]
    
    let sections = BehaviorRelay<[TaskSection]>(value: [])
    
    var taskComplete: [Tasks] = []
    var taskTodo: [Tasks] = []
    
    let currentDate = BehaviorRelay<Date>(value: Date())
    
    let error = BehaviorRelay<Errors?>(value: nil)
    let success = BehaviorRelay<String?>(value: nil)
    let isLoading = BehaviorRelay(value: false)
    
    init(tasks: [Tasks]) {
        self.tasks = tasks
        
        dateTracking()
        taskComplete = tasks.filter { $0.isComplete == true}
        taskTodo = tasks.filter { $0.isComplete == false}
        updateData()
    }
    
    static func dateAt(hour: Int, minute: Int = 0) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)!
    }
    
    func dateTracking(){
        Observable<Int>.interval(.seconds(60), scheduler:MainScheduler.instance)
            .map { _ in Date() }
            .filter { [weak self] newDate in
                guard let oldDate = self?.currentDate.value else { return true }
                return !Calendar.current.isDate(newDate, inSameDayAs: oldDate)
            }
            .bind(to: currentDate)
            .disposed(by: disposeBag)
    }
    
    func updateData(task: Tasks? = nil){
        if let task = task {
            if let index = taskTodo.firstIndex(where: {$0.id == task.id}) {
                taskTodo[index] = task
            } else {
                taskTodo.append(task)
            }
        }
        
        let list = [
            TaskSection(header: nil, items: taskTodo),
            TaskSection(header: "Complete", items: taskComplete)
        ]
        sections.accept(list)
    }
    
    func completeTask(task: Tasks){
        isLoading.accept(true)
        Task {
            do {
                let taskCompleted = Tasks(
                    id: task.id,
                    title: task.title,
                    dueDate: task.dueDate,
                    notes: task.notes,
                    isComplete: true,
                    category: task.category
                )
                
                let taskUpdated = try await TaskService.share.updateTask(task: taskCompleted)
                
                if let index = taskTodo.firstIndex(where: {$0.id == task.id}) {
                    taskTodo.remove(at: index)
                }
    
                taskComplete.append(taskUpdated)
                
                DispatchQueue.main.async {
                    self.isLoading.accept(false)
                    self.success.accept("Congratulations on completing this task")
                    self.updateData()
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading.accept(false)
                    self.error.accept(Errors(title: "Connection Error", message: error.localizedDescription))
                }
            }
        }
    }
    
    func deleteTask(task: Tasks){
        isLoading.accept(true)
        Task{
            do {
                try await TaskService.share.deleteTask(task: task)
                if let index = taskComplete.firstIndex(where: {$0.id == task.id}) {
                    taskComplete.remove(at: index)
                }
                
                if let index = taskTodo.firstIndex(where: {$0.id == task.id}) {
                    taskTodo.remove(at: index)
                }
                
                DispatchQueue.main.async {
                    self.isLoading.accept(false)
                    self.success.accept("Delete Task successfully")
                    self.updateData()
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading.accept(false)
                    self.error.accept(Errors(title: "Connection Error", message: error.localizedDescription))
                }
            }
        }
    }
    

}
