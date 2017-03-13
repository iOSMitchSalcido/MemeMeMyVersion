//
//  Meme.swift
//  MemeMeMyVersion
//
//  Created by Online Training on 3/7/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About Meme.swift:
 Meme data model object. Contains text, images for a meme. Conforms to UIActivityItemSource...can be passed
 into activityItems argument for UIActivityViewController
 */

import Foundation
import UIKit

class Meme: NSObject {
    
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
}

// extension. conform to ActivityItem data source
extension Meme: UIActivityItemSource {
    
    func activityViewControllerPlaceholderItem(_ activityViewController: UIActivityViewController) -> Any {
        return memedImage
    }
    
    func activityViewController(_ activityViewController: UIActivityViewController, itemForActivityType activityType: UIActivityType) -> Any? {
        return memedImage
    }
}
