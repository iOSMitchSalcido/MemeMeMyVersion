//
//  SharedMemesTableViewController.swift
//  MemeMeMyVersion
//
//  Created by Online Training on 3/13/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About SharedMemesTableViewController.swift
 TV to handle presentation of shared Meme's. Provides functionality for presenting MemeEditorVC, Deleting
 and moving Memes in tv
*/

import UIKit

class SharedMemesTableViewController: UITableViewController {

    // ref to app delegate..Meme store is defined in appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    // ref to newMeme bbi
    var newMemeBbi: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // view title
        navigationItem.titleView = titleViewForOrientation(UIDevice.current.orientation)
        
        // "+" button to create new Meme
        newMemeBbi = UIBarButtonItem(barButtonSystemItem: .add,
                                     target: self,
                                     action: #selector(createNewMeme))
        
        navigationItem.leftBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem = newMemeBbi
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // show tabBar, reload table
        tabBarController?.tabBar.isHidden = false
        tableView.reloadData()
        
        //navigationItem.leftBarButtonItem = editButtonItem
        editButtonItem.isEnabled = appDelegate.memeStore.count > 0
        
        // observer for orientation change...used to update titleView with correct image size
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(orientationChanged),
                                               name: .UIDeviceOrientationDidChange,
                                               object: nil)
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        // disable newMemeBbi when editing
        newMemeBbi.isEnabled = !editing
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

// tableView data source functions
extension SharedMemesTableViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // count of rows in tv
        return appDelegate.memeStore.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // retrieve cell, Meme. Set cell text and image
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableCellID")!
        let meme = appDelegate.memeStore[indexPath.row]
        cell.textLabel?.text = meme.topText
        cell.detailTextLabel?.text = meme.bottomText
        cell.imageView?.image = meme.memedImage
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        
        if appDelegate.memeStore.count > 1 {
            return true
        }
        
        return false
    }
}

// tableView delegate functions
extension SharedMemesTableViewController {
    
    // handle invoking MemeEditorVC to view Meme
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // retrieve meme. Invoke MemeEditorVC, set meme, push...need to hide tabBar...
        let meme = appDelegate.memeStore[indexPath.row]
        let controller = storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        controller.meme = meme
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    // handle deleting Meme
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
            
            // delete meme from store and update tv
            appDelegate.memeStore.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
            
            // test for no Memes..take out of editing mode and disable editDoneItem
            if appDelegate.memeStore.count == 0 {
                setEditing(false, animated: true)
                editButtonItem.isEnabled = false
            }
        }
    }
    
    // handle moving Meme's
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        
        // swap Memes
        let meme = appDelegate.memeStore.remove(at: sourceIndexPath.row)
        appDelegate.memeStore.insert(meme, at: destinationIndexPath.row)
    }
}

// misc helper functions
extension SharedMemesTableViewController {
    
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

