//
//  SplashViewModel.swift
//  Todo_App
//
//  Created by admin on 16/10/25.
//

import RxSwift
import Foundation
import RxRelay
import RxCocoa
import Supabase

class SplashViewModel : ViewModel {
    
    private let uuid = UserManager.share.getUserId()
    private let navigator: SplashNavigator
    
    let status = BehaviorRelay<String>(value: "loading")
    
    let isLoading = BehaviorRelay<Bool>(value: true)
    
    let errorMessage = PublishRelay<String>()
    
    var tasks: [Tasks] = []
    
    init(navigator: SplashNavigator) {
        self.navigator = navigator
        super.init(navigator: navigator)
        
        status.filter { $0 == "Success" }
            .delay(.seconds(1), scheduler: MainScheduler.instance)
            .observe(on: MainScheduler.instance)
            .subscribe(onNext: { [weak self] _ in
                    guard let self = self else { return }
                print("viewModel")
                    self.navigator.pushHome(tasks: tasks)
            })
            .disposed(by: disposeBag)
        
    }
    
    func loadData(){
        print("load")
        Task {
            do {
                let loginSuccess = try await AuthService.share.loginAnonymously()
                if loginSuccess {
                    let data = try await TaskService.share.fetchData()
                    self.tasks = data
                    self.status.accept("Success")
                    print("su")
                }
            } catch {
                errorMessage.accept(error.localizedDescription)
            }
            
            isLoading.accept(false)
        }

    }
}
