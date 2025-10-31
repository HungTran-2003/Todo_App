//
//  ViewModel.swift
//  Todo_App
//
//  Created by admin on 27/10/25.
//

import RxSwift
import RxCocoa
import Foundation

class ViewModel : NSObject {
    let disposeBag = DisposeBag()
    
    private let _navigator: Navigator
    
    init(navigator: Navigator) {
        self._navigator = navigator
        super.init()
    }
}
