//
//  HomeNavigator.swift
//  Todo_App
//
//  Created by admin on 27/10/25.
//

import Foundation

class HomeNavigator: Navigator {
    func pushTaskDetail(task: Tasks? = nil) {
        if let task = task {
            print("push detal task")
        } else {
            print("push detail")
        }
    }
}
