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
    
    let sections = BehaviorRelay<[TodoSection]>(value: [])
    
    let currentDate = BehaviorRelay<Date>(value: Date())
    
    let isLoading = BehaviorRelay(value: false)
    
    init(tasks: [Tasks], navigator: HomeNavigator) {
        let completeTasks = tasks.filter { $0.isComplete }
        let incompleteTasks = tasks.filter { !$0.isComplete }

        let sections = [
            TodoSection(header: "", items: incompleteTasks.map { TodoItemViewModel(item: $0) }),
            TodoSection(header: "Complete", items: completeTasks.map { TodoItemViewModel(item: $0) })
        ]
        self.sections.accept(sections)
        self.navigator = navigator
        super.init(navigator: navigator)
        self.dateTracking()
        bindDataFlow()
        bindAllCellViewModelEvents()
    }
    
    static func dateAt(hour: Int, minute: Int = 0) -> Date {
        var components = Calendar.current.dateComponents([.year, .month, .day], from: Date())
        components.hour = hour
        components.minute = minute
        return Calendar.current.date(from: components)!
    }
    
    func pushDetail(task: TodoItemViewModel? = nil, indexPath: IndexPath? = nil){
        navigator.pushTaskDetail(taskVM: task, indexPath: indexPath)
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
    
    private func bindAllCellViewModelEvents() {
        print("bind all cells")
        for section in sections.value {
            for cellVM in section.items {
                print("bind cell")
                bindEvents(for: cellVM)
            }
        }
    }

    private func bindEvents(for taskVM: TodoItemViewModel) {
        taskVM.onCompletionChanged
            .subscribe(onNext: { [weak self] changeSection, indexPath in
                guard let self = self else { return }
                print("bind event")
                self.updateSection(changeSection, indexPath)
            })
            .disposed(by: disposeBag)
    }

    
    func bindDataFlow(){
        navigator.task
            .subscribe(onNext: {task in
                guard let task = task else {return}
                var sections = self.sections.value
                let taskVM = TodoItemViewModel(item: task)
                self.bindEvents(for: taskVM)
                sections[0].items.append(taskVM)
                self.sections.accept(sections)
                
            })
            .disposed(by: navigator.disposeBag)
    }
    
    func updateSection(_ changeSection: Bool , _ indexPath: IndexPath){
        var sections = self.sections.value
        let cellVM = sections[indexPath.section].items[indexPath.row]
        if indexPath.section == 0 && changeSection {
            sections[0].items.remove(at: indexPath.row)
            sections[1].items.append(cellVM)
            self.navigator.showAlert(title: "Success", message: "Task complete successfully")
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
                    self.navigator.showAlert(title: "Success", message: "Delete successful")
                    self.sections.accept(sections)
                }
            } catch {
                DispatchQueue.main.async {
                    self.isLoading.accept(false)
                    self.navigator.showAlert(title: "Connection Error", message: error.localizedDescription)
                }
            }
        }
    }
    

}
