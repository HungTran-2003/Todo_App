//
//  DetailViewModel.swift
//  Todo_App
//
//  Created by admin on 21/10/25.
//
import RxSwift
import RxRelay
import Foundation

class DetailTaskViewModel: ViewModel {
    private let navigator: DetailTaskNavigator
    
    let categorys = [Categorys.TASK, Categorys.EVENT, Categorys.GOAL]
    
    private(set) var taskVM: TodoItemViewModel?
    private(set) var indexPath: IndexPath?
    
    let title = BehaviorRelay(value: "")
    let category = BehaviorRelay(value: 1)
    let date = BehaviorRelay<Date>(value: Date())
    let time = BehaviorRelay<Date>(value: Date())
    let notes = BehaviorRelay(value: "")
    
    let isLoading = BehaviorRelay(value: false)
    
    let dataOutput = BehaviorRelay<Tasks?>(value: nil)
    
    init(navigator: DetailTaskNavigator) {
        self.navigator = navigator
        super.init(navigator: navigator)
        
        observeChanges()
    }
    
    func setData(_ taskVM: TodoItemViewModel, _ indexPath: IndexPath) {
        self.taskVM = taskVM
        self.indexPath = indexPath
        bindCellViewModelCallbacks()
    }
    
    func valiedData() -> (text: String?, date: Date?){
        let finalTitle = title.value.trimmingCharacters(in: .whitespacesAndNewlines)
        if finalTitle.isEmpty {
            navigator.showAlert(title: "Missing Data", message: "Title cannot be empty")
            return(nil, nil)
        }
        
        let calendar = Calendar.current
        var dateComponents = calendar.dateComponents([.year, .month, .day], from: date.value)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time.value)
        dateComponents.hour = timeComponents.hour
        dateComponents.minute = timeComponents.minute
        
        guard let finalDate = calendar.date(from: dateComponents), finalDate > Date() else {
            navigator.showAlert(title: "Invalid Data", message: "The selected time must be in the future")
            return(nil, nil)
        }
        
        return (finalTitle, finalDate)
    }
    
    
    func addTaskToSupabase(){
        let result = valiedData()
        guard let finalTitle = result.text else {return}
        guard let finalDate = result.date else {return}
        
        let task = Tasks(id: nil, title: finalTitle, dueDate: finalDate, notes: notes.value, isComplete: false, category: categorys[category.value - 1])
        
        isLoading.accept(true)
        
        Task{
            do {
                let data = try await TaskService.share.addTask(task: task)
                DispatchQueue.main.async {
                    self.dataOutput.accept(data)
                    self.navigator.showAlert(title: "Success", message: "Added Task successfully") { _ in
                        self.navigator.backHome()
                    }
                    self.navigator.backHome()
                }
            } catch {
                DispatchQueue.main.async {
                    self.navigator.showErrorAlert()
                }
            }
        }
        
        
    }
    
    func updateTask(task: Tasks){
        guard let taskVM = taskVM, let indexPath = indexPath else {
            self.navigator.showAlert(title: "Error", message: "Cannot find this Task")
            return
        }
        
        let result = valiedData()
        guard let finalTitle = result.text else {return}
        guard let finalDate = result.date else {return}
        
        let task = Tasks(id: task.id, title: finalTitle, dueDate: finalDate, notes: notes.value, isComplete: false, category: categorys[category.value - 1])
        
        isLoading.accept(true)
        
        taskVM.updateTask(task: task, isCompleteBefore: task.isComplete, indexPath: indexPath)
        
    }
    
    func bindCellViewModelCallbacks(){
        guard let taskVM = taskVM else {return}
        
        taskVM.onCompletionChanged
            .subscribe(onNext: {[weak self] _, _ in
                guard let self = self else {return}
                self.isLoading.accept(false)
                self.navigator.showAlert(title: "Success", message: "Task update successfully") { _ in
                    self.navigator.backHome()
                }
            })
            .disposed(by: disposeBag)
    }
    
    func observeChanges() {
        title
            .skip(1)
            .subscribe(onNext: { newValue in
                print("Title changed:", newValue)
            })
            .disposed(by: disposeBag)

        category
            .skip(1)
            .subscribe(onNext: { newValue in
                print("Category changed:", newValue)
            })
            .disposed(by: disposeBag)

        date
            .skip(1)
            .subscribe(onNext: { newValue in
                print("Date changed:", newValue)
            })
            .disposed(by: disposeBag)

        time
            .skip(1)
            .subscribe(onNext: { newValue in
                print("Time changed:", newValue)
            })
            .disposed(by: disposeBag)

        notes
            .skip(1)
            .subscribe(onNext: { newValue in
                print("Notes changed:", newValue)
            })
            .disposed(by: disposeBag)
    }

}

