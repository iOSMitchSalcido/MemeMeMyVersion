//
//  MemeEditorViewController.swift
//  MemeMeMyVersion
//
//  Created by Online Training on 3/6/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController {

    // ref to view objects
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    // bbi's
    var cameraBbi: UIBarButtonItem!
    var shareBbi: UIBarButtonItem!
    var trashBbi: UIBarButtonItem!
    
    // default image..ref maintained to steer view configuration
    var defaultImage: UIImage?
    
    // ref to a Meme
    var meme: Meme!
    
    // lazily load available image sources. Return an array of tuple's. SourceType
    // is used to steer image source selection. String is message to show in alertController
    lazy var availableSourceTypes: [(UIImagePickerControllerSourceType, String)] = {
        var sources = [(UIImagePickerControllerSourceType, String)]()
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            sources.append((.camera, "Camera"))
        }
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
            sources.append((.photoLibrary, "Photo Library"))
        }
        if UIImagePickerController.isSourceTypeAvailable(.savedPhotosAlbum) {
            sources.append((.savedPhotosAlbum, "Saved Photos Album"))
        }
        return sources
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
         Config textFields, delegate, text, alignment
         */
        topTextField.delegate = self
        bottomTextField.delegate = self
        
        let memeTextAttrib: [String: AnyObject] = [NSStrokeColorAttributeName: UIColor.white,
                                                   NSStrokeWidthAttributeName: NSNumber(value: 0.0),
                                                   NSForegroundColorAttributeName: UIColor.white,
                                                   NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!]
        topTextField.defaultTextAttributes = memeTextAttrib
        bottomTextField.defaultTextAttributes = memeTextAttrib
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        
        // create bbi's and place on bars
        cameraBbi = UIBarButtonItem(barButtonSystemItem: .camera,
                                    target: self,
                                    action: #selector(cameraBbiPressed(_:)))
        shareBbi = UIBarButtonItem(barButtonSystemItem: .action,
                                   target: self,
                                   action: #selector(shareBbiPressed(_:)))
        trashBbi = UIBarButtonItem(barButtonSystemItem: .trash,
                                   target: self,
                                   action: #selector(trashBbiPressed(_:)))
        let flexBbi = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                      target: nil,
                                      action: nil)
        toolbarItems = [cameraBbi, flexBbi, trashBbi]
        navigationItem.rightBarButtonItem = shareBbi
        navigationController?.setToolbarHidden(false, animated: false)
        
        // get default image, place in imageView
        defaultImage = UIImage(named: "CreateMeme")
        imageView.image = defaultImage
        
        // enable camera bbi
        cameraBbi.isEnabled = availableSourceTypes.count > 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // start keyboard notification and configure bbi enable states
        beginKeyboardNotifications()
        configureMemeView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // end keyboard notifications
        endKeyboardNotifications()
    }
    
    func configureMemeView() {
        
        /*
         This function is used to steer the enabled states of bbi's and also touch enable
         response of textFields depending on image that currently is in imageView
         */
        if imageView.image == defaultImage {
            
            // default image is showing. disable/hide textFields. Disable share/trash bbi's
            topTextField.isHidden = true
            bottomTextField.isHidden = true
            topTextField.isUserInteractionEnabled = false
            bottomTextField.isUserInteractionEnabled = false
            shareBbi.isEnabled = false
            trashBbi.isEnabled = false
        }
        else if let meme = meme, imageView.image == meme.memedImage {
           
            // meme image is showing. Disable/hide textFields. Enable share/trash bbi's
            topTextField.isHidden = true
            bottomTextField.isHidden = true
            topTextField.isUserInteractionEnabled = false
            bottomTextField.isUserInteractionEnabled = false
            shareBbi.isEnabled = true
            trashBbi.isEnabled = true
        }
        else {
            
            // picture from camera or photo's album is showning. Enable text editing, sharing, and trash
            topTextField.isHidden = false
            bottomTextField.isHidden = false
            topTextField.isUserInteractionEnabled = true
            bottomTextField.isUserInteractionEnabled = true
            shareBbi.isEnabled = true
            trashBbi.isEnabled = true
        }
    }
    
    func cameraBbiPressed(_ sender: UIBarButtonItem) {
        
        /*
         Function to invoke imagePickerVC. tests availableSources array, and if more then one source
         type is available (camera + photo's library, for example), then an alertVC (action) is presented
         with selection of sources. If only one source type is available, then simply invoke imagePickerVC
         using that source
        */
        
        // create imagePickerVC, set delegate
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        // test for more than one source
        if availableSourceTypes.count > 1 {
            
            // more than one source type is availble. Create AlertVC (action) with actions for each source type
            let alert = UIAlertController(title: "Select Photo Source",
                                          message: nil,
                                          preferredStyle: .actionSheet)
            
            for source in availableSourceTypes {
                
                // availableSourceTypes is array of tuples (SourceType, String).... String is title to be
                // used in action button
                let action = UIAlertAction(title: source.1,
                                           style: .default) {
                                            (action) in
                                            
                                            // Completion..set source type and presentVC
                                            imagePicker.sourceType = source.0
                                            self.present(imagePicker, animated: true, completion: nil)
                }
                alert.addAction(action)
            }
            
            // last button in alert is cancel
            let cancel = UIAlertAction(title: "Cancel",
                                       style: .cancel,
                                       handler: nil)
            alert.addAction(cancel)
            
            // show alert
            present(alert, animated: true, completion: nil)
        }
        else {
            
            // only one source type..show imagePickerVC
            imagePicker.sourceType = (availableSourceTypes.last?.0)!
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func trashBbiPressed(_ sender: UIBarButtonItem) {
        
        // Trash. Create alert to delete image
        let alert = UIAlertController(title: "Delete Picture ?",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let proceed = UIAlertAction(title: "Delete",
                                    style: .default) {
                                        (action) in
                                        
                                        // completion, set to defaultImage, config bbi's
                                        self.imageView.image = self.defaultImage
                                        self.configureMemeView()
        }
        let cancel = UIAlertAction(title: "Cancel",
                                   style: .cancel,
                                   handler: nil)
        
        alert.addAction(proceed)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
    
    func shareBbiPressed(_ sender: UIBarButtonItem) {
  
        var items: [Any] = ["Check out my Meme !"]
        var completion: (() -> Void)? = nil
        if let meme = meme, imageView.image == meme.memedImage {
            items.append(meme)
        }
        else {
            let memedImage = screenShot()
            items.append(memedImage)
            completion = { () in
                
                self.meme = Meme(topText: self.topTextField.text!,
                            bottomText: self.bottomTextField.text!,
                            originalImage: self.imageView.image!,
                            memedImage: memedImage)
            }
        }
        
        let activityVC = UIActivityViewController(activityItems: items, applicationActivities: nil)
        present(activityVC, animated: true, completion: completion)
    }
    
    // function to create an image from current view
    func screenShot() -> UIImage {
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let image: UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return image
    }
}

// delegate functions for ImagePickerVC
extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // image has been selected
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // dismiss imagePickerVC
        dismiss(animated: true) {
            
            // get image and config bbi's
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                self.imageView.image = image
            }
            else {
                self.imageView.image = self.defaultImage
            }
            
            self.configureMemeView()
        }
    }
    
    // cancel, do nothing
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true) {
        }
    }
}

// delegate function for textFields
extension MemeEditorViewController: UITextFieldDelegate {
    
    // done editing
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// handle keyboard notifications, shifting to reveal bottomTextView when editing
extension MemeEditorViewController {
    
    // add notifications for showing/hiding keyboard presented by textField editing
    func beginKeyboardNotifications() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillShow(_:)),
                                               name: .UIKeyboardWillShow,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)),
                                               name: .UIKeyboardWillHide,
                                               object: nil)
    }
    
    // end notifications for showing/hiding keyboard
    func endKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIKeyboardWillShow,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIKeyboardWillHide,
                                                  object: nil)
    }
    
    // action function for showing keyboard
    func keyboardWillShow(_ notification: Notification) {
        
        // test for bottomTextField. Verify not already shifted, then shift view up
        // so bottomTextField stays visible when keyboard is visible
        if bottomTextField.isEditing {
            let yShift: CGFloat = (view.superview?.frame.origin.y)!
            if yShift == 0 {
                view.superview?.frame.origin.y -= keyboardShift(notification)
            }
        }
    }
    
    // action function for hiding keyboard
    func keyboardWillHide(_ notification: Notification) {

        // test for keyboard shifted. If shifted, then shift back to original position
        let yShift: CGFloat = (view.superview?.frame.origin.y)!
        if yShift < CGFloat(0.0) {
            view.superview?.frame.origin.y += -1.0 * yShift
        }
    }
    
    // function to compute desired keyboard shift.
    func keyboardShift(_ notification: Notification) -> CGFloat {
        
        // get keyboard height, return height less half textField height..seems like asthetic value
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardFrame.cgRectValue.size.height - bottomTextField.frame.size.height / 2.0
    }
}
