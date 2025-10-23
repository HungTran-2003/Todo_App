//
//  SplashViewController.swift
//  Todo_App
//
//  Created by admin on 16/10/25.
//
import UIKit
import RxSwift
import RxCocoa

class SplashViewController : UIViewController {
    
    let disposeBag = DisposeBag()
    
    private var viewModel: SplashViewModel = SplashViewModel()
    
    @IBOutlet weak var labelIndicator: UILabel!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        bindViewModel()
        viewModel.loadData()
    }
    
    
    private func bindViewModel() {
        viewModel.status .bind(to: labelIndicator.rx.text) .disposed(by: disposeBag)
        
        viewModel.isLoading.bind(to: activityIndicator.rx.isAnimating) .disposed(by: disposeBag)
        
        viewModel.navigator
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let self = self else {return}
                self.navigationToHome()
            })
            .disposed(by: disposeBag)
        
        viewModel.errorMessage
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] message in
                guard let self = self else {return}
                self.showAlert(title: "Error", message: message)
                
            })
            .disposed(by: disposeBag)
    }
    
    func navigationToHome(){
        let viewModel = TaskViewModel(tasks: viewModel.tasks)
        let homeVC = storyBoard.instantiateViewController(withIdentifier: "HomeScreen") as! HomeViewController
        homeVC.viewModel = viewModel

        navigationController?.setViewControllers([homeVC], animated: true)
    }
    
    
}
