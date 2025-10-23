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

class SplashViewModel {
    let disposeBag = DisposeBag()
    
    private let uuid = UserManager.share.getUserId()
    
    let status = BehaviorRelay<String>(value: "loading")
    
    let isLoading = BehaviorRelay<Bool>(value: true)
    
    let errorMessage = PublishRelay<String>()

    let navigator = PublishSubject<Void>()
    
    var tasks: [Tasks] = []
    
    func loadData(){
        isLoading.accept(true)
        
        Task {
            do {
                let loginSuccess = try await AuthService.share.loginAnonymously()
                if loginSuccess {
                    let data = try await TaskService.share.fetchData()
                    self.tasks = data
                    self.status.accept("Success")
                    navigationToHome()
                }
            } catch {
                errorMessage.accept(error.localizedDescription)
            }
            
            isLoading.accept(false)
        }

    }
    
    func navigationToHome(){
        Observable.just(())
                .delay(.seconds(1), scheduler: MainScheduler.instance)
                .bind(to: navigator)
                .disposed(by: disposeBag)
    }
}
