//
//  TodoItem.swift
//  Todo_App
//
//  Created by admin on 14/10/25.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa
import SwipeCellKit

class TodoItem : SwipeCollectionViewCell {
    
    
    @IBOutlet weak var categoryImV: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var TaskStackView: UIStackView!
    
    @IBOutlet weak var checkBox: UIButton!
    
    let onCheckBoxTapped = PublishRelay<Void>()
    
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
        
        titleLabel.attributedText = nil
        timeLabel.attributedText = nil
        titleLabel.text = nil
        timeLabel.text = nil
        TaskStackView.alpha = 1.0
        checkBox.setImage(UIImage(named: "check_false"), for: .normal)
        contentView.layer.cornerRadius = 0
        contentView.layer.maskedCorners = []
        hideSwipe(animated: false)
    }
    
    
    func config(task: Tasks, firstItem: Bool = false, lastItem: Bool = false) {
        
        let calendar = Calendar.current
        
        var nameImage = ""
        switch task.category {
        case .EVENT:
            nameImage = "Event"
        case .GOAL:
            nameImage = "Goal"
        case .TASK:
            nameImage = "Task"
        }
        
        categoryImV.image  = UIImage(named: nameImage)
        
        titleLabel.text = task.title
        
        let timeFormat = DateFormatter()
        timeFormat.dateFormat = "hh:mm a"
        
        if !calendar.isDateInToday(task.dueDate) {
            timeFormat.dateFormat = "dd/MM/yyyy hh:mm a"
        }
        
        timeLabel.text = timeFormat.string(from: task.dueDate)
        
        if(task.isComplete) {
            titleLabel.attributedText = NSAttributedString(
                string: task.title,
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue
                ]
                
            )

            timeLabel.attributedText = NSAttributedString(
                string: timeFormat.string(from: task.dueDate),
                attributes: [
                    .strikethroughStyle: NSUnderlineStyle.single.rawValue
                ]
            )
            TaskStackView.alpha = 0.5
            
            checkBox.setImage(UIImage(named: "check_true"), for: .normal)
        }
        
        if firstItem && lastItem {
            contentView.layer.cornerRadius = 16
            contentView.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner,
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
            contentView.clipsToBounds = false

        } else if firstItem {
            contentView.layer.cornerRadius = 16
            contentView.layer.maskedCorners = [
                .layerMinXMinYCorner,
                .layerMaxXMinYCorner
            ]
            contentView.clipsToBounds = false

        } else if lastItem {
            contentView.layer.cornerRadius = 16
            contentView.layer.maskedCorners = [
                .layerMinXMaxYCorner,
                .layerMaxXMaxYCorner
            ]
            contentView.clipsToBounds = false

        }
        checkBox.rx.tap
            .bind(to: onCheckBoxTapped)
            .disposed(by: disposeBag)
    }
}
