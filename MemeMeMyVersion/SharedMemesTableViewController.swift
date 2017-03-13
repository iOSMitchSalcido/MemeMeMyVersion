//
//  SharedMemesTableViewController.swift
//  MemeMeMyVersion
//
//  Created by Online Training on 3/13/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

class SharedMemesTableViewController: UITableViewController {

    // ref to app delegate..Meme store is defined in appDelegate
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // view title
        title = "MemeMe!"
        
        // "+" button to create new Meme
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(createNewMeme))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // show tabBar, reload table
        tabBarController?.tabBar.isHidden = false
        tableView.reloadData()
    }

    // create a new Meme
    func createNewMeme() {
    
        // invoke MemeEditorVC in a navController, present
        let controller = storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        let nc = UINavigationController(rootViewController: controller)
        present(nc, animated: true, completion: nil)
    }
    
    /*
    // TODO: !! Problems when pushing..abruptly shifts on an odd way...need to investigate
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
    */
}

// dataSource and Delegate functions for tableView
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // retrieve meme. Invoke MemeEditorVC, set meme, push...need to hide tabBar...
        let meme = appDelegate.memeStore[indexPath.row]
        let controller = storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        controller.meme = meme
        navigationItem.titleView = nil
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(controller, animated: true)
    }
}
