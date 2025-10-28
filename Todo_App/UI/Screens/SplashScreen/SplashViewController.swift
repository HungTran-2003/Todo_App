//
//  SplashViewController.swift
//  Todo_App
//
//  Created by admin on 16/10/25.
//
import UIKit
import RxSwift
import RxCocoa

class SplashViewController : ViewController<SplashViewModel, SplashNavigator> {
    
    @IBOutlet weak var labelIndicator: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override var shouldUseAutoHUD: Bool {false}
    
    override func viewDidLoad() {
        let navigator = SplashNavigator(with: self)
        viewModel = SplashViewModel(navigator: navigator)
        super.viewDidLoad()
        bindViewModel()
        viewModel.loadData()
    }
    
    private func bindViewModel() {
        
        viewModel.status.bind(to: labelIndicator.rx.text)
            .disposed(by: disposeBag)

        
        viewModel.isLoading.bind(to: activityIndicator.rx.isAnimating) .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                guard let self = self else {return}
                self.showAlert(title: "Error", message: message)
                
            })
            .disposed(by: disposeBag)
    }
    
    
    
}
