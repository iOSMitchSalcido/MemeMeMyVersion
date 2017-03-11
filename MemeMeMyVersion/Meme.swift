//
//  Meme.swift
//  MemeMeMyVersion
//
//  Created by Online Training on 3/7/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import Foundation
import UIKit

class Meme: NSObject, UIActivityItemSource {
    
    let topText: String
    let bottomText: String
    let  textAttributes: [String: AnyObject]
    let originalImage: UIImage
    let memedImage: UIImage
    
    init(topText: String, bottomText: String, textAttributes: [String: AnyObject], originalImage: UIImage, memedImage: UIImage) {
        self.topText = topText
        self.bottomText = bottomText
        self.textAttributes = textAttributes
        self.originalImage = originalImage
        self.memedImage = memedImage
    }
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return memedImage
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        return memedImage
    }
}
