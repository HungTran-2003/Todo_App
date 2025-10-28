//
//  SplashNavigatior.swift
//  Todo_App
//
//  Created by admin on 17/10/25.
//

import UIKit

class SplashNavigator: Navigator {
    
    func pushHome(tasks : [Tasks]) {
        print("Go to Home called")
        let homeVC = storyBoard.instantiateViewController(withIdentifier: "HomeScreen") as! HomeViewController
        let navigator = HomeNavigator(with: homeVC)
        let viewModel = HomeViewModel(tasks: tasks, navigator: navigator)
        homeVC.viewModel = viewModel
        navigationController?.setViewControllers([homeVC], animated: true)
        print("aaddđ")
    }
}
