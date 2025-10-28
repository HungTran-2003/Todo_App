//
//  Navigatior.swift
//  Todo_App
//
//  Created by admin on 27/10/25.
//

import Foundation
import RxSwift
import UIKit

class Navigator {
    let disposeBag = DisposeBag()
    
    weak var viewController: UIViewController?
    
    lazy var navigationController: UINavigationController? = {
        return self.viewController?.navigationController
    }()
    
    
    init(with viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func showErrorAlert(){
        showAlert(title: "Error", message: "System error")
    }
    
    func showAlert(title: String?, message: String?, buttonTitles: [String]? = nil, highlightedButtonIndex: Int? = nil, completion: ((Int) -> Void)? = nil) {
        viewController?.showAlert(title: title,
                                  message: message,
                                  buttonTitles: buttonTitles,
                                  highlightedButtonIndex: highlightedButtonIndex,
                                  completion: completion)
    }
}
