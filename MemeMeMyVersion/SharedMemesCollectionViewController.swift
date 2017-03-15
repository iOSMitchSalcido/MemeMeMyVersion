//
//  SharedMemesCollectionViewController.swift
//  MemeMeMyVersion
//
//  Created by Online Training on 3/13/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

class SharedMemesCollectionViewController: UICollectionViewController {
    
    // ref to app delegate..Meme store is defined in appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // ref to newMeme bbi
    var newMemeBbi: UIBarButtonItem!
    
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    override func viewDidLoad() {
        super.viewDidLoad()

        // view title
        navigationItem.titleView = titleViewForOrientation(UIDevice.current.orientation)
        
        // "+" button to create new Meme
        newMemeBbi = UIBarButtonItem(barButtonSystemItem: .add,
                                     target: self,
                                     action: #selector(createNewMeme))
        
        navigationItem.rightBarButtonItem = newMemeBbi
        navigationItem.leftBarButtonItem = editButtonItem
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // observer for orientation change...used to update titleView with correct image size
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: .UIDeviceOrientationDidChange,
                                               object: nil)
        
        tabBarController?.tabBar.isHidden = false
        collectionView?.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if isEditing {
            setEditing(false, animated: false)
        }
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
    
        // retrieve flowLayout info...want to maintain same # of cells regardless of orientation
        let spacing: CGFloat = 2.0
        let dim = (view.frame.width - 2.0 * spacing) / 3.0
        flowLayout.minimumInteritemSpacing = spacing
        flowLayout.minimumLineSpacing = spacing
        flowLayout.itemSize = CGSize(width: dim, height: dim)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
    
        if editing {
            newMemeBbi.isEnabled = false
            collectionView?.backgroundColor = UIColor.darkGray
        }
        else {
            newMemeBbi.isEnabled = true
            collectionView?.backgroundColor = UIColor.black
        }
    }
    
    // update titleView image
    func orientationChanged() {
        navigationItem.titleView = titleViewForOrientation(UIDevice.current.orientation)
    }
    
    // create a new Meme
    func createNewMeme() {
        
        // invoke MemeEditorVC in a navController, present
        let controller = storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        let nc = UINavigationController(rootViewController: controller)
        present(nc, animated: true, completion: nil)
    }
}

// collectionView data source functions
extension SharedMemesCollectionViewController {
 
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return appDelegate.memeStore.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCellID", for: indexPath) as! MemeCollectionViewCell
        
        // Configure the cell
        let meme = appDelegate.memeStore[indexPath.row]
        cell.imageView.image = meme.memedImage
        
        return cell
    }
}

// collectionView delegate functions
extension SharedMemesCollectionViewController {
    
    // MARK: UICollectionViewDelegate
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if isEditing {
            return
        }
        
        // retrieve meme. Invoke MemeEditorVC, set meme, push...need to hide tabBar...
        let meme = appDelegate.memeStore[indexPath.row]
        let controller = storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        controller.meme = meme
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(controller, animated: true)
    }
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
