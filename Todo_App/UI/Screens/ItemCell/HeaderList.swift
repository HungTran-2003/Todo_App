//
//  HeaderList.swift
//  Todo_App
//
//  Created by admin on 14/10/25.
//

import UIKit

class HeaderList : UICollectionReusableView {
    
    @IBOutlet weak var headerTabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        isHidden = false
    }
}
