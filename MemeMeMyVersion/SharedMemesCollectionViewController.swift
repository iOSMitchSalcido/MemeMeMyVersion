//
//  SharedMemesCollectionViewController.swift
//  MemeMeMyVersion
//
//  Created by Online Training on 3/13/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cell"

class SharedMemesCollectionViewController: UICollectionViewController {

    // for debug.. create five memes and put in table
    lazy var testMemes: [Meme]  = {
        
        var memes = [Meme]()
        
        for i in 0..<5 {
            let originalImage = UIImage(named: "CreateMeme")
            let memedImage = UIImage(named: "CreateMeme")
            let attribute = [NSStrokeColorAttributeName: UIColor.white,
                             NSStrokeWidthAttributeName: NSNumber(value: 0.0),
                             NSForegroundColorAttributeName: UIColor.white,
                             NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!]
            let meme = Meme(topText: "Meme #\(i)",
                bottomText: "I'm Meme #\(i) in the list of memes",
                textAttributes: attribute,
                originalImage: originalImage!,
                memedImage: memedImage!)
            memes.append(meme)
        }
        
        return memes
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
    }
    
    // used to set titleView in landscape/portrait
    override func viewWillLayoutSubviews() {
        
        // detect orientation changes. Set titleView to correct size
        let orientation = UIDevice.current.orientation
        var frame: CGRect = CGRect.zero
        var image: UIImage!
        if orientation == .portrait {
            frame = CGRect(x: 0, y: 0, width: 200, height: 35)
            image = UIImage(named: "MemeTitleViewPortrait")
        }
        else {
            frame = CGRect(x: 0, y: 0, width: 200, height: 25)
            image = UIImage(named: "MemeTitleViewLandscape")
        }
        
        // titleView
        let imageView = UIImageView(frame: frame)
        imageView.image = image
        navigationItem.titleView = imageView
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }


    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return 0
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
    
        // Configure the cell
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    /*
    // Uncomment this method to specify if the specified item should be highlighted during tracking
    override func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment this method to specify if the specified item should be selected
    override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        return true
    }
    */

    /*
    // Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
    override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        return false
    }

    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
    
    }
    */

}
