//
//  MenuBar.swift
//  Project2
//
//  Created by virdeshp on 7/9/18.
//  Copyright © 2018 Viraj. All rights reserved.
//

import UIKit


class MenuBar: UIView, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    
    lazy var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.backgroundColor = UIColor.init(red: (247.0/255.0), green: (247.0/255.0), blue: (247.0/255.0), alpha: 0.95)
        cv.dataSource = self
        cv.delegate = self
        cv.layer.shadowColor = UIColor.lightGray.cgColor
        cv.layer.shadowOffset = CGSize(width: 0, height: 0.5)
        cv.layer.shadowOpacity = 0.8
        cv.layer.shadowRadius = 0.1
        cv.clipsToBounds = false
        cv.layer.masksToBounds = false
        return cv
    }()
    
    let cellId = "cellId"
    let image_names = ["icons8-contacts-50", "icons8-musical-notes-50", "video", "icons8-sheet-music-50"]
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        collectionView.register(MenuCell.self, forCellWithReuseIdentifier: cellId)
        
        addSubview(collectionView)
        addConstraintWithFormat(format: "H:|[v0]|", views: collectionView)
        addConstraintWithFormat(format: "V:|[v0]|", views: collectionView)
        
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int{
      return 4
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! MenuCell
        
        cell.imageView.image = UIImage(named: image_names[indexPath.item])
        cell.backgroundColor = UIColor.init(red: (247.0/255.0), green: (247.0/255.0), blue: (247.0/255.0), alpha: 0.0)
        
        return cell
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath ) -> CGSize {
        return CGSize(width: frame.width/4, height: frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class MenuCell: BaseCell{
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(named: "icons8-musical-notes-50")
        return iv
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(imageView)
        addConstraintWithFormat(format: "H:[v0(25)]", views: imageView)
        addConstraintWithFormat(format: "V:[v0(25)]", views: imageView)
        
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerX, relatedBy: .equal, toItem: self, attribute: .centerX, multiplier: 1, constant: 0))
        addConstraint(NSLayoutConstraint(item: imageView, attribute: .centerY, relatedBy: .equal, toItem: self, attribute: .centerY, multiplier: 1, constant: 0))

        
        

    }
    
    
    
    
}
