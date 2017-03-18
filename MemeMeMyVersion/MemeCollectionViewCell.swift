//
//  MemeCollectionViewCell.swift
//  MemeMeMyVersion
//
//  Created by Online Training on 3/14/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About MemeCollectionViewCell.swift
 Cell to handle meme image and selectedImage (checkmark). Provide functionality to place cell
 in "selected" state
 */

import UIKit

class MemeCollectionViewCell: UICollectionViewCell {
    
    // ref to memeImage and selectedImage (checkmark)
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectedImageView: UIImageView!
    
    // handle placing cell in "selected" state
    func showSelectionView(_ show: Bool) {
        
        if show {
            // dim meme image, show checkmark
            UIView.animate(withDuration: 0.15) {
                self.imageView.alpha = 0.5
                self.selectedImageView .alpha = 1.0
            }
        }
        else {
            // show meme image, hide checkmark
            UIView.animate(withDuration: 0.15) {
                self.imageView.alpha = 1.0
                self.selectedImageView .alpha = 0.0
            }
        }
    }
}
