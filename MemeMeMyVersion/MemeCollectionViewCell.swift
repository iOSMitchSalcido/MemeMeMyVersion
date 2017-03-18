//
//  MemeCollectionViewCell.swift
//  MemeMeMyVersion
//
//  Created by Online Training on 3/14/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

class MemeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    func showSelectionView(_ show: Bool) {
        
        if show {
            UIView.animate(withDuration: 0.15) {
                self.imageView.alpha = 0.5
                self.selectedImageView .alpha = 1.0
            }
        }
        else {
            UIView.animate(withDuration: 0.15) {
                self.imageView.alpha = 1.0
                self.selectedImageView .alpha = 0.0
            }
        }
    }
}
