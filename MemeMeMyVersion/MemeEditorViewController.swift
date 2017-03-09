//
//  MemeEditorViewController.swift
//  MemeMeMyVersion
//
//  Created by Online Training on 3/6/17.
//  Copyright © 2017 Mitch Salcido. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    var cameraBbi: UIBarButtonItem!
    var albumBbi: UIBarButtonItem!
    var shareBbi: UIBarButtonItem!
    
    var defaultImage: UIImage?
    
    var meme: Meme!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        cameraBbi = UIBarButtonItem(barButtonSystemItem: .camera,
                                    target: self,
                                    action: #selector(getPicture(_:)))
        albumBbi = UIBarButtonItem(title: "Photos",
                                   style: .plain,
                                   target: self,
                                   action: #selector(getPicture(_:)))
        shareBbi = UIBarButtonItem(barButtonSystemItem: .action,
                                   target: nil,
                                   action: nil)
        let flexBbi = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                      target: nil,
                                      action: nil)
        toolbarItems = [flexBbi, cameraBbi, flexBbi, albumBbi, flexBbi]
        navigationItem.rightBarButtonItem = shareBbi
        navigationController?.setToolbarHidden(false, animated: false)
        
        defaultImage = UIImage(named: "CreateMeme")
        imageView.image = defaultImage
        
        cameraBbi.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        albumBbi.isEnabled = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        beginKeyboardNotifications()
        configureMemeView()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        endKeyboardNotifications()
    }
    
    func configureMemeView() {
        
        if imageView.image == defaultImage {
            
            topTextField.isHidden = true
            bottomTextField.isHidden = true
            topTextField.isUserInteractionEnabled = false
            bottomTextField.isUserInteractionEnabled = false
        }
        else if let meme = meme, imageView.image == meme.memedImage {
           
            topTextField.isHidden = true
            bottomTextField.isHidden = true
            topTextField.isUserInteractionEnabled = false
            bottomTextField.isUserInteractionEnabled = false
        }
        else {
            
            topTextField.isHidden = false
            bottomTextField.isHidden = false
            topTextField.isUserInteractionEnabled = true
            bottomTextField.isUserInteractionEnabled = true
        }
    }
    
    func getPicture(_ sender: UIBarButtonItem) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if sender == cameraBbi {
            imagePicker.sourceType = .camera
        }
        else if sender == albumBbi {
            imagePicker.sourceType = .photoLibrary
        }
        
        present(imagePicker, animated: true, completion: nil)
    }
}

// delegate functions for ImagePickerVC
extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        dismiss(animated: true) {
            
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                print("got an image")
                self.imageView.image = image
            }
            else {
                self.imageView.image = self.defaultImage
            }
            
            self.configureMemeView()
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
     
        dismiss(animated: true) {
            print("didCancel....")
        }
    }
}

// delegate function for textFields
extension MemeEditorViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// handle keyboard notifications, shifting to reveal bottomTextView when editing
extension MemeEditorViewController {
    
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
    
    func endKeyboardNotifications() {
        
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIKeyboardWillShow,
                                                  object: nil)
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIKeyboardWillHide,
                                                  object: nil)
    }
    
    func keyboardWillShow(_ notification: Notification) {
        
        if bottomTextField.isEditing {
            let yShift: CGFloat = (view.superview?.frame.origin.y)!
            if yShift == 0 {
                view.superview?.frame.origin.y -= keyboardShift(notification)
            }
        }
    }
    
    func keyboardWillHide(_ notification: Notification) {

        let yShift: CGFloat = (view.superview?.frame.origin.y)!
        if yShift < CGFloat(0.0) {
            view.superview?.frame.origin.y += -1.0 * yShift
        }
    }
    
    func keyboardShift(_ notification: Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardFrame = userInfo?[UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardFrame.cgRectValue.size.height - bottomTextField.frame.size.height / 2.0
    }
}
