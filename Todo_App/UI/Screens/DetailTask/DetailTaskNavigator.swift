//
//  DetailTaskNavigator.swift
//  Todo_App
//
//  Created by admin on 28/10/25.
//
import UIKit
class DetailTaskNavigator : Navigator {
    
    func backHome(){
        navigationController?.popViewController(animated: true)
    }
}
