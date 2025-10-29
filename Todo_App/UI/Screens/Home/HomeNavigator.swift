//
//  HomeNavigator.swift
//  Todo_App
//
//  Created by admin on 27/10/25.
//

import Foundation
import UIKit
import RxRelay
import RxSwift

class HomeNavigator: Navigator {
    
    let task = BehaviorRelay<Tasks?>(value: nil)
    
    func pushTaskDetail(taskVM: TodoItemViewModel? = nil, indexPath: IndexPath? = nil) {
        let viewController = storyBoard.instantiateViewController(identifier: "DetailTaskScreen") as! DetailTaskViewController
        let navigator = DetailTaskNavigator(with: viewController)
        let viewModel = DetailTaskViewModel(navigator: navigator)
        viewController.viewModel = viewModel
        bindDataFlow(viewModel: viewModel)
        if let taskVM = taskVM, let indexPath = indexPath{
            viewModel.setData(taskVM, indexPath)
            navigationController?.pushViewController(viewController, animated: true)
        } else {
            navigationController?.pushViewController(viewController, animated: true)
        }
    }
    
    func bindDataFlow(viewModel: DetailTaskViewModel){
        viewModel.dataOutput
            .subscribe(onNext: {[weak self] task in
                guard let self = self else {return}
                guard let task = task else {return}
                self.task.accept(task)
            })
            .disposed(by: viewModel.disposeBag)
    }
}
