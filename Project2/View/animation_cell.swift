//
//  animation_cell.swift
//  Project2
//
//  Created by virdeshp on 3/9/19.
//  Copyright © 2019 Viraj. All rights reserved.
//

import Foundation
import UIKit


class animation_cell: UICollectionViewCell {
    
    
    let color_array = ["UIcolor.magenta", "UIcolor.red", "UIcolor.black", "UIcolor.blue", "UIcolor.green", "UIcolor.gray", "UIcolor.yellow", "UIcolor.orange", "UIcolor.purple", "UIcolor.white"]
  
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder aDecoder: NSCoder) {
       super.init(coder: aDecoder)
    }
    
    func setupCell () {
        
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 2
        self.layer.cornerRadius = 5
    }
    
}
