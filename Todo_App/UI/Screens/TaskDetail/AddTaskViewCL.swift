//
//  AddTaskViewCL.swift
//  Todo_App
//
//  Created by admin on 14/10/25.
//

import UIKit
import RxSwift
import RxCocoa

class AddTaskViewCL : UIViewController {
    
    @IBOutlet weak var titleTextF: UITextField!
    
    @IBOutlet weak var TaskBT: UIButton!
    @IBOutlet weak var EventBT: UIButton!
    @IBOutlet weak var GoalBT: UIButton!
    
    
    @IBOutlet weak var dateTextField: UITextField!
    @IBOutlet weak var timeTextField: UITextField!
    @IBOutlet weak var noteTextView: UITextView!
    
    @IBOutlet weak var saveButton: UIButton!
    
    @IBOutlet weak var backButton: UIButton!
    
    let disposeBag = DisposeBag()

    var viewModel = DetailViewModel()
    
    var task: Tasks? = nil
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpui()
        guard let task = task else {return}
        setupUiTask(task: task)
    }
    
    func setUpui() {
        navigationItem.title = "Add New Task"
        
        [titleTextF, dateTextField, timeTextField].forEach {
                setUpTextField(textfield: $0)
        }
        
        navigationItem.hidesBackButton = true
        let back = UIBarButtonItem(customView: backButton)
        back.tintColor = .clear
        navigationItem.leftBarButtonItem = back
        
        



        
        setupDatePicker()
        setupTimePicker()
        bindUI()
        bindViewModel()
    }
    
    
    @IBAction func backView(_ sender: Any) {
        print("back")
        navigationController?.popViewController(animated: true)
    }
    func bindUI() {
        TaskBT.rx.tap
            .subscribe(onNext: { [weak self] in self?.updateCategory(tag: 1) })
            .disposed(by: disposeBag)

        EventBT.rx.tap
            .subscribe(onNext: { [weak self] in self?.updateCategory(tag: 2) })
            .disposed(by: disposeBag)

        GoalBT.rx.tap
            .subscribe(onNext: { [weak self] in self?.updateCategory(tag: 3) })
            .disposed(by: disposeBag)
        
        titleTextF.rx.text.orEmpty
            .bind(to: viewModel.title)
            .disposed(by: disposeBag)
        
        noteTextView.rx.didBeginEditing
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                if noteTextView.text == "Notes" {
                    noteTextView.text = ""
                    noteTextView.textColor = .label
                }
            }).disposed(by: disposeBag)

        noteTextView.rx.didEndEditing
            .subscribe(onNext: { [weak self] in
                guard let self else { return }
                if noteTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    noteTextView.text = "Notes"
                    noteTextView.textColor = .lightGray
                } else {
                    viewModel.notes.accept(noteTextView.text)
                }
            }).disposed(by: disposeBag)
        
        saveButton.rx.tap
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance)
            .subscribe(onNext: {[weak self] in
                guard let self = self else {return}
                self.view.endEditing(true)
                guard let task = task else {
                    viewModel.addTaskToSupabase()
                    return
                }
                viewModel.updateTask(task: task)
            })
            .disposed(by: disposeBag)
    }

    private func updateCategory(tag: Int) {
        viewModel.category.accept(tag)
        updateUiButton(button: TaskBT, tag: 1)
        updateUiButton(button: EventBT, tag: 2)
        updateUiButton(button: GoalBT, tag: 3)
    }

    private func updateUiButton(button: UIButton, tag: Int) {
        button.configuration?.baseBackgroundColor = (tag == viewModel.category.value) ? .black : .white
    }
    
    func setupDatePicker(initialDate: Date? = nil) {
        let datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .inline
        dateTextField.inputView = datePicker
        
        if let initial = initialDate {
                datePicker.date = initial                // Set date vào picker
                dateTextField.text = formatDate(date: initial) // Set lên textField
            }
        
        datePicker.rx.date
            .do(onNext: { [weak self] in self?.viewModel.date.accept($0) })
            .map { [weak self] in self?.formatDate(date: $0) ?? "" }
            .bind(to: dateTextField.rx.text)
            .disposed(by: disposeBag)
    }

    func setupTimePicker(initialDate: Date? = nil) {
        let timePicker = UIDatePicker()
        timePicker.datePickerMode = .time
        timePicker.preferredDatePickerStyle = .wheels
        timeTextField.inputView = timePicker
        
        if let initial = initialDate {
                timePicker.date = initial                // Set date vào picker
                timeTextField.text = formatTime(date: initial) // Set lên textField
            }
        
        timePicker.rx.date
            .do(onNext: { [weak self] in self?.viewModel.time.accept($0) })
            .map { [weak self] in self?.formatTime(date: $0) ?? "" }
            .bind(to: timeTextField.rx.text)
            .disposed(by: disposeBag)
    }
    
    func formatDate(date: Date) -> String {
        let format = DateFormatter()
        format.dateFormat = "dd/MM/YYYY"
        return format.string(from: date)
    }
    
    func formatTime(date: Date) -> String {
        let format = DateFormatter()
        format.dateFormat = "hh:mm a"
        return format.string(from: date)
    }
    
    func setUpTextField(textfield: UITextField) {
        textfield.layer.cornerRadius = 8
        textfield.layer.masksToBounds = true
    }
    
    func bindViewModel(){
        viewModel.error
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] error in
                guard let self = self else {return}
                guard let error = error else {return}
                self.showAlert(title: error.title, message: error.message)
                print(error.message)
                
            })
            .disposed(by: disposeBag)
        
        viewModel.success
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] success in
                guard let self = self else {return}
                guard let success = success else {return}
                self.showAlert(title: "Success", message: success) { _ in
                    self.navigationController?.popViewController(animated: true)
                }
                
            })
            .disposed(by: disposeBag)
    }
    
    func setupUiTask(task: Tasks){
        navigationItem.title = "Detail Task"
        
        titleTextF.text = task.title
        viewModel.title.accept(task.title)
        
        let index = viewModel.categorys.firstIndex(where: { $0 == task.category}) ?? 0
    
        updateCategory(tag: index + 1)
        
        setupDatePicker(initialDate: task.dueDate)
        setupTimePicker(initialDate: task.dueDate)
        
        guard let note = task.notes, !note.isEmpty else {return}
        noteTextView.text = note
        viewModel.notes.accept(note)
    }
}
