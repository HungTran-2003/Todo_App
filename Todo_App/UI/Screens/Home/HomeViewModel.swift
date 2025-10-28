//
//  TaskViewModel.swift
//  Todo_App
//
//  Created by admin on 14/10/25.
//

import Foundation
import RxRelay
import RxSwift
import UIKit

class HomeViewModel: ViewModel {
    
    private let navigator: HomeNavigator
    
    let sections = BehaviorRelay<[TaskSection]>(value: [])
    
    let currentDate = BehaviorRelay<Date>(value: Date())
    
    let error = BehaviorRelay<Errors?>(value: nil)
    let success = BehaviorRelay<String?>(value: nil)
    let isLoading = BehaviorRelay(value: false)
    
    init(tasks: [Tasks], navigator: HomeNavigator) {
        let completeTasks = tasks.filter { $0.isComplete }
        let incompleteTasks = tasks.filter { !$0.isComplete }

        let sections = [
            TaskSection(header: "", items: incompleteTasks.map { TodoItemViewModel(item: $0) }),
            TaskSection(header: "Complete", items: completeTasks.map { TodoItemViewModel(item: $0) })
        ]
        self.sections.accept(sections)
        self.navigator = navigator
        super.init(navigator: navigator)
        self.dateTracking()
        bindCellViewModelCallbacks()
        bindDataFlow()
    }
    
    static func dateAt(hour: Int, minute: Int = 0) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)!
    }
    
    func pushDetail(task: TodoItemViewModel? = nil){
        
        navigator.pushTaskDetail(taskVM: task)
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
    
    func bindCellViewModelCallbacks(){
        for (_, section) in sections.value.enumerated() {
            for cellVM in section.items {
                cellVM.onCompletionChanged = { [weak self] changeSection, indexPath in
                    self?.updateSection(changeSection, indexPath)
                }
            }
        }
    }
    
    func bindDataFlow(){
        navigator.task
            .subscribe(onNext: {task in
                guard let task = task else {return}
                var sections = self.sections.value
                if let index = sections[0].items.firstIndex(where: {$0.item.id == task.id}) {
                    sections[0].items[index] = TodoItemViewModel(item: task)
                }else {
                    sections[0].items.append(TodoItemViewModel(item: task))
                }
                self.sections.accept(sections)
            })
            .disposed(by: navigator.disposeBag)
    }
    
    func updateSection(_ changeSection: Bool , _ indexPath: IndexPath){
        var sections = self.sections.value
        let cellVM = sections[indexPath.section].items[indexPath.row]
        if indexPath.section == 0 {
            sections[0].items.remove(at: indexPath.row)
            sections[1].items.append(cellVM)
        }
        isLoading.accept(false)
        self.sections.accept(sections)
    }

    func deleteTask(taskViewModel: TodoItemViewModel, indexPath: IndexPath){
        isLoading.accept(true)
        Task{
            do {
                var sections = self.sections.value
                try await TaskService.share.deleteTask(task: taskViewModel.item)
                sections[indexPath.section].items.remove(at: indexPath.row)
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.isLoading.accept(false)
                    self.success.accept("Delete successful")
                    self.sections.accept(sections)
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
