//
//  ViewController.swift
//  Todo_App
//
//  Created by admin on 27/10/25.
//

import UIKit
import RxSwift
import MBProgressHUD
import RxRelay
import SwiftyBeaver

class ViewController<V: ViewModel, N: Navigator>: UIViewController {
    var viewModel: V!
    var navigator: N!
    
    let disposeBag = DisposeBag()
    
    let isLoading = BehaviorRelay(value: false)
    
    let emptyDataSetButtonTap = PublishSubject<Void>()
    
    var shouldUseAutoHUD: Bool { true }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        setupUI()
        setupListener()
    }
    
    deinit {
        log.info("\(type(of: self)): Deinited")
    }
    
    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        log.info("\(type(of: self)): Received Memory Warning")
    }
    
    func setupUI() {
        
    }
    
    func setupListener() {
        guard self.shouldUseAutoHUD else { return }
        
        isLoading.subscribe(onNext: {[weak self] (loading) in
            guard let self = self else { return }
            if loading {
                let Indicator = MBProgressHUD.showAdded(to: self.view, animated: true)
                Indicator.label.text = "Loading..."
                Indicator.isUserInteractionEnabled = false
                Indicator.show(animated: true)
            } else {
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }).disposed(by: disposeBag)
    }
    
    func showLeftButton(image: UIImage? = nil) {
        var image = image
        if image == nil {
            image = UIImage(systemName: "xmark")
        }
        navigationController?.navigationBar.tintColor = .white
        let barButtonItem = UIBarButtonItem(image: image, style: .plain, target: self, action: #selector(self.leftButtonTapped(sender:)))
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    func hideLeftButton() {
        navigationItem.setHidesBackButton(true, animated: false)
    }
    
    @objc func leftButtonTapped(sender: UIBarButtonItem) {
        if let nav = navigationController {
            nav.popViewController(animated: true)
            return
        }
        dismiss(animated: true, completion: nil)
    }
}

