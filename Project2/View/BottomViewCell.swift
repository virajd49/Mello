//
//  BottomViewCell.swift
//  Project2
//
//  Created by virdeshp on 5/8/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import UIKit


class BaseCell: UICollectionViewCell {
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

class BottomViewCell: BaseCell {
    
    var setting: Setting? {
        
        didSet{
            nameLabel.text = setting?.name
            
            if let nativeAppimageName = setting?.nativeAppimageName{
                nativeAppImageView.image = UIImage(named: nativeAppimageName)
                
            }
            
            if let addIconimageName = setting?.addIconimageName{
                addIconImageView.image = UIImage(named: addIconimageName)?.withRenderingMode(.alwaysTemplate)
                addIconImageView.tintColor = UIColor.black
            }
        }
    }
    
    override var isHighlighted: Bool {
        didSet {
            
            backgroundColor = isHighlighted ? UIColor.lightGray : UIColor.white
            nameLabel.textColor = isHighlighted ? UIColor.white : UIColor.black
            nativeAppImageView.tintColor = isHighlighted ? UIColor.white : UIColor.black
            
        }
        
    }
   
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Add to library"
        return label
    }()
    
    let nativeAppImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icons8-add-100")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    let addIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "icons8-add-100")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(nameLabel)
        addSubview(nativeAppImageView)
        addSubview(addIconImageView)
        
        addConstraintWithFormat(format: "|-12-[v0(25)]-8-[v1]-8-[v2(25)]-12-|", views: nativeAppImageView, nameLabel, addIconImageView)
        addConstraintWithFormat(format: "V:|[v0]|", views: nameLabel)
        addConstraintWithFormat(format: "V:|-12-[v0(25)]-13-|", views: nativeAppImageView)
        addConstraintWithFormat(format: "V:|-12-[v0(25)]-13-|", views: addIconImageView)
        //nativeAppImageView.center = self.center
        //addIconImageView.center = self.center
        //addConstraints([NSLayoutConstraint(item: nativeAppImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)])
        //addConstraints([NSLayoutConstraint(item: addIconImageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0)])
    }
    
    
    
    
}

extension UIView {
    func addConstraintWithFormat(format: String, views: UIView...) {
        var viewsDictionary = [String: UIView]()
        for (index, view) in views.enumerated() {
            let key = "v\(index)"
            view.translatesAutoresizingMaskIntoConstraints = false
            viewsDictionary[key] = view
        }
        
        addConstraints(NSLayoutConstraint.constraints(withVisualFormat: format, options: NSLayoutFormatOptions(), metrics: nil, views: viewsDictionary))
        
    }
    
    
}
