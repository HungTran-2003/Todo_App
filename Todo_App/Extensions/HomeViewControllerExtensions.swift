//
//  TodoItemExtensions.swift
//  Todo_App
//
//  Created by admin on 22/10/25.
//

import UIKit
import SwipeCellKit
import RxRelay

extension HomeViewController : SwipeCollectionViewCellDelegate {
    func collectionView(_ collectionView: UICollectionView,
                            editActionsForItemAt indexPath: IndexPath,
                            for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
                
        guard orientation == .right else { return nil }

        let delete = SwipeAction(style: .destructive, title: "Delete") { [weak self] action, indexPath in
            guard let self = self else { return }

            self.handleDelete(at: indexPath)
            action.fulfill(with: .reset)
        }

        delete.image = UIImage(systemName: "trash")

        return [delete]
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        editActionsOptionsForItemAt indexPath: IndexPath,
                        for orientation: SwipeActionsOrientation) -> SwipeOptions {
        var options = SwipeOptions()

        options.expansionStyle = .destructive(automaticallyDelete: true)
        options.transitionStyle = .drag

        return options
    }
}

extension HomeViewController: UICollectionViewDelegateFlowLayout {

    func collectionView(
        _ collectionView: UICollectionView,
        layout collectionViewLayout: UICollectionViewLayout,
        referenceSizeForHeaderInSection section: Int
    ) -> CGSize {
        let sections = viewModel.sections.value
        
        if sections.allSatisfy({ $0.items.isEmpty }) {
            return .zero
        }
        return section == 0
            ? .zero : CGSize(width: collectionView.frame.width, height: 80)
    }
}
