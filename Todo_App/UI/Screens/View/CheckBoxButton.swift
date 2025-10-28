//
//  CheckBox.swift
//  Todo_App
//
//  Created by admin on 27/10/25.
//

import UIKit
import RxCocoa
import RxSwift

class CheckboxButton: UIButton {
    let onChecked = BehaviorRelay<Bool>(value: false)
    var disposeBag: DisposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        makeUI()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        makeUI()
    }
    
    private func makeUI() {
        onChecked.subscribe(onNext: { [weak self] isChecked in
            guard let self = self else { return }
            if isChecked {
                self.setImage(UIImage(named: "check_true"), for: .normal)
            } else {
                self.setImage(UIImage(named: "check_false"), for: .normal)
            }
        }).disposed(by: disposeBag)
    }
    
    deinit {
        disposeBag = DisposeBag()
    }
}
