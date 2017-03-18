//
//  SharedMemesCollectionViewController.swift
//  MemeMeMyVersion
//
//  Created by Online Training on 3/13/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About SharedMemesCollectionViewController.swift
 CollectionView to handle presentation of shared Meme's. Provides functionality for presenting MemeEditorVC, Deleting
 and moving Memes in CV
 */

import UIKit

class SharedMemesCollectionViewController: UICollectionViewController {
    
    // ref to app delegate..Meme store is defined in appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // ref to newMeme bbi
    var newMemeBbi: UIBarButtonItem!
    
    // ref to trash..for selecting and deleting Memes
    var trashBbi: UIBarButtonItem!
    
    // ref to flowLayout
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // view title
        navigationItem.titleView = titleViewForOrientation()
        
        // "+" button to create new Meme
        newMemeBbi = UIBarButtonItem(barButtonSystemItem: .add,
                                     target: self,
                                     action: #selector(createNewMeme))
        
        navigationItem.rightBarButtonItem = newMemeBbi
        navigationItem.leftBarButtonItem = editButtonItem
        
        // trashBbi
        trashBbi = UIBarButtonItem(barButtonSystemItem: .trash,
                                   target: self,
                                   action: #selector(trashBbiPressed(_:)))
        
        collectionView?.allowsMultipleSelection = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // observer for orientation change...used to update titleView with correct image size
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: .UIDeviceOrientationDidChange,
                                               object: nil)
        // show tabBar, reload cv data
        tabBarController?.tabBar.isHidden = false
        collectionView?.reloadData()
        
        // edit/done enable state...enable is any Memes
        editButtonItem.isEnabled = appDelegate.memeStore.count > 0
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
    
        // set tabBar items enable state to ! editing
        for item in (tabBarController?.tabBar.items)! {
            item.isEnabled = !editing
        }
        
        if editing {
            
            // editing. Place disabled trashBbi on right navbar, tint view a little to indicate editing state
            trashBbi.isEnabled = false
            navigationItem.setRightBarButton(trashBbi, animated: true)
            collectionView?.backgroundColor = UIColor(red: 0.1, green: 0.1, blue: 0.1, alpha: 1.0)
        }
        else {
            
            // done editing...Place newMemeBbi on right navbar, restore background color
            navigationItem.setRightBarButton(newMemeBbi, animated: true)
            collectionView?.backgroundColor = UIColor.black
            
            // deselect and currently selected cells
            let indexPaths = collectionView?.indexPathsForSelectedItems
            for indexPath in indexPaths! {
                collectionView?.deselectItem(at: indexPath, animated: false)
                let cell = collectionView?.cellForItem(at: indexPath) as! MemeCollectionViewCell
                cell.selectedImageView.alpha = 0.0
                cell.imageView.alpha = 1.0
            }
        }
    }
    
    // update titleView image
    func orientationChanged() {
        navigationItem.titleView = titleViewForOrientation()
    }
    
    // create a new Meme
    func createNewMeme() {
        
        // invoke MemeEditorVC in a navController, present
        let controller = storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        let nc = UINavigationController(rootViewController: controller)
        present(nc, animated: true, completion: nil)
    }
    
    // trashBbiPressed
    func trashBbiPressed(_ sender: UIBarButtonItem) {
        
        // get indexPaths os selected cells. Reverse sort according to row property..needed when iterating/deleting
        // memes from array
        var indexPaths = collectionView?.indexPathsForSelectedItems
        indexPaths?.sort {
            (index1, index2) -> Bool in
            return index1.row > index2.row
        }
        
        // delete meme(s) from store
        for indexPath in indexPaths! {
            appDelegate.memeStore.remove(at: indexPath.row)
        }
        
        // delete cell(s)
        collectionView?.deleteItems(at: indexPaths!)
        
        // disable trashBbi..cells no longer selected
        trashBbi.isEnabled = false
        
        // remove from editing state if no Memes
        if appDelegate.memeStore.count == 0 {
            setEditing(false, animated: true)
            editButtonItem.isEnabled = false
        }
    }
}

// collectionView data source functions
extension SharedMemesCollectionViewController {
 
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        // count of items in cv
        return appDelegate.memeStore.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "MemeCollectionViewCellID", for: indexPath) as! MemeCollectionViewCell
        
        // Configure the cell
        let meme = appDelegate.memeStore[indexPath.row]
        cell.imageView.image = meme.memedImage
        
        // test cell selection to show selection "checkmark"
        if cell.isSelected {
            cell.selectedImageView.alpha = 1.0
        }
        else {
            cell.selectedImageView.alpha = 0.0
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: UICollectionView, canMoveItemAt indexPath: IndexPath) -> Bool {
        
        // OK to reorder if editing and more than one cell
        if (collectionView.visibleCells.count > 1) && isEditing {
            return true
        }
        return false
    }
}

// collectionView delegate functions
extension SharedMemesCollectionViewController {
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        // cell is now selected. Enable trash and show "checkmark"
        if isEditing {
            trashBbi.isEnabled = true
            let cell = collectionView.cellForItem(at: indexPath) as! MemeCollectionViewCell
            cell.showSelectionView(true)
            return
        }
        
        // retrieve meme. Invoke MemeEditorVC, set meme, push...need to hide tabBar...
        let meme = appDelegate.memeStore[indexPath.row]
        let controller = storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        controller.meme = meme
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        
        // cell is now deleselected..hide "checkmark", and disable trash if no more selected cells
        if isEditing {
            let cell = collectionView.cellForItem(at: indexPath) as! MemeCollectionViewCell
            cell.showSelectionView(false)
            
            trashBbi.isEnabled = (collectionView.indexPathsForSelectedItems?.count)! > 0
            return
        }
    }
    
    override func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // swap cells
        let meme = appDelegate.memeStore.remove(at: sourceIndexPath.row)
        appDelegate.memeStore.insert(meme, at: destinationIndexPath.row)
    }
}

// misc helper functions
extension SharedMemesCollectionViewController {
    
    // retieve titleView for device orientation
    func titleViewForOrientation() -> UIView {
        
        // detect orientation changes. Set titleView to correct size
        var frame: CGRect = CGRect.zero
        var image: UIImage!
        if (UIScreen.main.bounds.size.width > UIScreen.main.bounds.size.height) {
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
