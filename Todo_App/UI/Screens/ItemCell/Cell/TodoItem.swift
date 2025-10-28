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

class TodoItem : CollectionViewCell {
    
    
    @IBOutlet weak var categoryImV: UIImageView!
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var timeLabel: UILabel!
    
    @IBOutlet weak var TaskStackView: UIStackView!
    
    @IBOutlet weak var checkBoxBT: CheckboxButton!
    
    let onCheckBoxTapped = PublishRelay<Void>()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        titleLabel.attributedText = nil
        timeLabel.attributedText = nil
        titleLabel.text = nil
        timeLabel.text = nil
        TaskStackView.alpha = 1.0
        contentView.layer.cornerRadius = 0
        contentView.layer.maskedCorners = []
        checkBoxBT.onChecked.accept(false)
        hideSwipe(animated: false)
    }
    
    override func bind(viewModel: CellViewModel) {
        guard let viewModel = viewModel as? TodoItemViewModel else {
            return
        }
        
        let item = viewModel.item
        
        viewModel.title.bind(to: titleLabel.rx.text).disposed(by: disposeBag)
        viewModel.category
            .map { nameImage in
                return UIImage(named: nameImage ?? "Task")
                }
            .bind(to: categoryImV.rx.image)
            .disposed(by: disposeBag)
        viewModel.dueDate.bind(to: timeLabel.rx.text).disposed(by: disposeBag)
        
        viewModel.isComplete
            .subscribe(onNext: {[weak self] complete in
                guard let self = self else {return}
                if complete {
                    self.setupCompletedUI(title: item.title,time: viewModel.stringDate(date: item.dueDate))
                }
                checkBoxBT.onChecked.accept(complete)
            })
            .disposed(by: disposeBag)
        
        checkBoxBT.rx.tap.bind(to: onCheckBoxTapped).disposed(by: disposeBag)
    }
    
    // MARK: - UI Configuration
    func config(_ viewModel: CellViewModel, firstItem: Bool = false, lastItem: Bool = false) {
        bind(viewModel: viewModel)
        
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
    }
    
    // MARK: - Helper UI Configuration
    private func setupCompletedUI(title: String?, time: String?) {
        if let titleText = title {
            titleLabel.attributedText = NSAttributedString(
                string: titleText,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
        }
        if let timeText = time {
            timeLabel.attributedText = NSAttributedString(
                string: timeText,
                attributes: [.strikethroughStyle: NSUnderlineStyle.single.rawValue]
            )
        }
        TaskStackView.alpha = 0.5
    }
        
}
