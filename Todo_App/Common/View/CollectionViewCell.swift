//
//  CollectionViewCell.swift
//  Todo_App
//
//  Created by admin on 27/10/25.
//

import Foundation
import RxSwift
import SwipeCellKit

class CollectionViewCell: SwipeCollectionViewCell {
    var disposeBag = DisposeBag()
    
    override func prepareForReuse() {
        super.prepareForReuse()
        disposeBag = DisposeBag()
    }
    
    func bind(viewModel: CellViewModel) {
        
    }
}
