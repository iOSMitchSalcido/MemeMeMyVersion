//
//  SharedMemesTableViewController.swift
//  MemeMeMyVersion
//
//  Created by Online Training on 3/13/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

class SharedMemesTableViewController: UITableViewController {

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
        
        title = "MemeMe!"
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add,
                                                            target: self,
                                                            action: #selector(createNewMeme))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.isHidden = false
    }

    func createNewMeme() {
    
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

extension SharedMemesTableViewController {
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return testMemes.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemeTableCellID")!
        let meme = testMemes[indexPath.row]
        cell.textLabel?.text = meme.topText
        cell.detailTextLabel?.text = meme.bottomText
        cell.imageView?.image = meme.memedImage
        
        return cell
    }
    
    // MARK: - Table view delegate functions
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let meme = testMemes[indexPath.row]
        let controller = storyboard?.instantiateViewController(withIdentifier: "MemeEditorViewController") as! MemeEditorViewController
        controller.meme = meme
        navigationItem.titleView = nil
        tabBarController?.tabBar.isHidden = true
        navigationController?.pushViewController(controller, animated: true)
    }
}
