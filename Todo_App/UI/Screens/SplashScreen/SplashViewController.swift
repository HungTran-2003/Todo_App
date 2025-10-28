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
    }
    
    override func setupUI() {
        bindViewModel()
        viewModel.loadData()
    }
    
    private func bindViewModel() {
        
        viewModel.status.bind(to: labelIndicator.rx.text)
            .disposed(by: disposeBag)

        
        viewModel.isLoading.bind(to: activityIndicator.rx.isAnimating) .disposed(by: disposeBag)
    }
    
    
    
}
