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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // view title
        navigationItem.titleView = titleViewForOrientation(UIDevice.current.orientation)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        self.collectionView!.register(UICollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // observer for orientation change...used to update titleView with correct image size
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: .UIDeviceOrientationDidChange,
                                               object: nil)
    }
    
    // update titleView image
    func orientationChanged() {
        navigationItem.titleView = titleViewForOrientation(UIDevice.current.orientation)
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


// misc helper functions
extension SharedMemesCollectionViewController {
    
    // retieve titleView for device orientation
    func titleViewForOrientation(_ orientation: UIDeviceOrientation) -> UIView {
        
        // detect orientation changes. Set titleView to correct size
        var frame: CGRect = CGRect.zero
        var image: UIImage!
        if (orientation == .landscapeLeft) || (orientation == .landscapeRight) {
            frame = CGRect(x: 0, y: 0, width: 200, height: 25)
            image = UIImage(named: "SentTitleViewLandscape")
        }
        else {
            frame = CGRect(x: 0, y: 0, width: 200, height: 35)
            image = UIImage(named: "SentTitleViewPortrait")
        }
        
        // titleView
        let imageView = UIImageView(frame: frame)
        imageView.image = image
        
        return imageView
    }
}
