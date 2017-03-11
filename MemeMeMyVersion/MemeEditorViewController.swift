//
//  MemeEditorViewController.swift
//  MemeMeMyVersion
//
//  Created by Online Training on 3/6/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//
/*
 About MemeEditorViewController.swift:
 VC implements a meme generator. Handles functionality for the user to select a pic from available
 iOS device image source (camer, photos lib, etc), and add text at the top and bottom of the field.
 
 VC also handles sharing of meme. An ActivityVC can be presented to allow the user to share the meme over
 available services (message, mail, save image, etc)
 */

import UIKit

class MemeEditorViewController: UIViewController {

    // ref to view objects
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    // bbi's
    var cameraBbi: UIBarButtonItem!
    var fontsBbi: UIBarButtonItem!
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
    
    // lazily load text attribs for use in meme. Functionality provided for user to cycle thru attribs
    // to set font
    lazy var textAttributes: [[String: AnyObject]] = {
        
        var textAttribs = [[String: AnyObject]]()
        
        // default attrib per course rubric
        var attribute = [NSStrokeColorAttributeName: UIColor.white,
                         NSStrokeWidthAttributeName: NSNumber(value: 0.0),
                         NSForegroundColorAttributeName: UIColor.white,
                         NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!]
        textAttribs.append(attribute)
        
        attribute = [NSStrokeColorAttributeName: UIColor.black,
                         NSStrokeWidthAttributeName: NSNumber(value: 0.0),
                         NSForegroundColorAttributeName: UIColor.black,
                         NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!]
        textAttribs.append(attribute)
        
        attribute = [NSStrokeColorAttributeName: UIColor.white,
                         NSStrokeWidthAttributeName: NSNumber(value: 5.0),
                         NSForegroundColorAttributeName: UIColor.white,
                         NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!]
        textAttribs.append(attribute)
        
        attribute = [NSStrokeColorAttributeName: UIColor.red,
                     NSStrokeWidthAttributeName: NSNumber(value: 0.0),
                     NSForegroundColorAttributeName: UIColor.red,
                     NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!]
        textAttribs.append(attribute)
        
        attribute = [NSStrokeColorAttributeName: UIColor.red,
                     NSStrokeWidthAttributeName: NSNumber(value: 5.0),
                     NSForegroundColorAttributeName: UIColor.red,
                     NSFontAttributeName: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!]
        textAttribs.append(attribute)
        
        return textAttribs
    }()
    
    // index to track selected font. Initialize at 0, which is default font
    var fontIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Config textFields, delegate, text, alignment
        topTextField.delegate = self
        bottomTextField.delegate = self
        topTextField.defaultTextAttributes = textAttributes[fontIndex]
        bottomTextField.defaultTextAttributes = textAttributes[fontIndex]
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
        
        // create bbi's and place on bars
        cameraBbi = UIBarButtonItem(barButtonSystemItem: .camera,
                                    target: self,
                                    action: #selector(cameraBbiPressed(_:)))
        fontsBbi = UIBarButtonItem(barButtonSystemItem: .play,
                                   target: self,
                                   action: #selector(fontsBbiPressed(_:)))
        shareBbi = UIBarButtonItem(barButtonSystemItem: .action,
                                   target: self,
                                   action: #selector(shareBbiPressed(_:)))
        trashBbi = UIBarButtonItem(barButtonSystemItem: .trash,
                                   target: self,
                                   action: #selector(trashBbiPressed(_:)))
        let flexBbi = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                      target: nil,
                                      action: nil)
        toolbarItems = [cameraBbi, flexBbi, fontsBbi, flexBbi, trashBbi]
        navigationItem.rightBarButtonItem = shareBbi
        navigationController?.setToolbarHidden(false, animated: false)
        
        // get default image, place in imageView
        defaultImage = UIImage(named: "CreateMeme")
        imageView.image = defaultImage
        
        // enable camera bbi
        cameraBbi.isEnabled = availableSourceTypes.count > 0
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
            fontsBbi.isEnabled = false
        }
        else if let meme = meme, imageView.image == meme.memedImage {
           
            // meme image is showing. Disable/hide textFields. Enable share/trash bbi's
            topTextField.isHidden = true
            bottomTextField.isHidden = true
            topTextField.isUserInteractionEnabled = false
            bottomTextField.isUserInteractionEnabled = false
            shareBbi.isEnabled = true
            trashBbi.isEnabled = true
            fontsBbi.isEnabled = false
        }
        else {
            
            // picture from camera or photo's album is showning. Enable text editing, sharing, and trash
            topTextField.isHidden = false
            bottomTextField.isHidden = false
            topTextField.isUserInteractionEnabled = true
            bottomTextField.isUserInteractionEnabled = true
            shareBbi.isEnabled = true
            trashBbi.isEnabled = true
            fontsBbi.isEnabled = true
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
                                            // allow editing if not using camera
                                            imagePicker.sourceType = source.0
                                            if source.0 == .camera {
                                                imagePicker.allowsEditing = false
                                            }
                                            else {
                                                imagePicker.allowsEditing = true
                                            }
                                            
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
    
    // delete image
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
    
    // share image/meme
    func shareBbiPressed(_ sender: UIBarButtonItem) {
  
        /*
         function to share an image or meme. Tests to see if current image is an existing meme. If not,
         then a new meme is created and image is replaced by memed image
         */
        
        // items array for activityItems
        var activityItems: [Any] = ["Check out my Meme !"]
        
        // completion passed into presentVC.
        var activityCompletion: ((UIActivityType?, Bool, [Any]?, Error?) -> Void)? = nil
        
        if let meme = meme, imageView.image == meme.memedImage {
            // image is currently meme. Simply "re-share" the meme
            activityItems.append(meme)
        }
        else {
            
            // image is currently new pic. Get screenshot (with text) and append ativityItems array
            let memedImage = screenShot()
            activityItems.append(memedImage)
            
            // activityVC completion
            activityCompletion = {
                (activityType, completed, returnedItems, activityError) in
                
                if completed {
                    /*
                     successfull share.
                     Create new meme and set to meme
                    */
                    self.meme = Meme(topText: self.topTextField.text!,
                                     bottomText: self.bottomTextField.text!,
                                     originalImage: self.imageView.image!,
                                     memedImage: memedImage)
                    
                    // set imageView to memed image, update bbi enable status
                    self.imageView.image = memedImage
                    self.configureMemeView()
                }
            }
        }
        
        // config and present activityVC
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityVC.completionWithItemsHandler = activityCompletion
        present(activityVC, animated: true, completion: nil)
    }
    
    // function to cycle thru meme text fonts
    func fontsBbiPressed(_ sender: UIBarButtonItem) {
        
        // advance to next font. Test if exceeded textAttribs count
        fontIndex += 1
        if fontIndex >= textAttributes.count {
            fontIndex = 0
        }
        
        // change textField fonts
        topTextField.defaultTextAttributes = textAttributes[fontIndex]
        bottomTextField.defaultTextAttributes = textAttributes[fontIndex]
        topTextField.textAlignment = .center
        bottomTextField.textAlignment = .center
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
            
            // get image and config bbi's. Use edited image if available
            if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
                self.imageView.image = image
            }
            else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
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
