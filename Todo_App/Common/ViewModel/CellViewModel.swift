//
//  CellViewModel.swift
//  Todo_App
//
//  Created by admin on 27/10/25.
//

import Foundation
import RxSwift
import RxCocoa

class CellViewModel {
    var disposeBag = DisposeBag()
    
    let title = BehaviorRelay<String?>(value: nil)
    let dueDate = BehaviorRelay<String?>(value: nil)
    let category = BehaviorRelay<String?>(value: nil)
    let isComplete = BehaviorRelay<Bool>(value: false)
}
