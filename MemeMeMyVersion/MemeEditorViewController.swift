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
    var shareBbi: UIBarButtonItem!
    var clearBbi: UIBarButtonItem!
    
    var defaultImage: UIImage?
    
    var meme: Meme!
    
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
                                    action: #selector(cameraBbiPressed(_:)))
        shareBbi = UIBarButtonItem(barButtonSystemItem: .action,
                                   target: nil,
                                   action: nil)
        clearBbi = UIBarButtonItem(barButtonSystemItem: .trash,
                                   target: self,
                                   action: #selector(clearBbiPressed(_:)))
        let flexBbi = UIBarButtonItem(barButtonSystemItem: .flexibleSpace,
                                      target: nil,
                                      action: nil)
        toolbarItems = [cameraBbi, flexBbi, clearBbi]
        navigationItem.rightBarButtonItem = shareBbi
        navigationController?.setToolbarHidden(false, animated: false)
        
        defaultImage = UIImage(named: "CreateMeme")
        imageView.image = defaultImage
        
        cameraBbi.isEnabled = availableSourceTypes.count > 0
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
            shareBbi.isEnabled = false
            clearBbi.isEnabled = false
        }
        else if let meme = meme, imageView.image == meme.memedImage {
           
            topTextField.isHidden = true
            bottomTextField.isHidden = true
            topTextField.isUserInteractionEnabled = false
            bottomTextField.isUserInteractionEnabled = false
            shareBbi.isEnabled = true
            clearBbi.isEnabled = true
        }
        else {
            
            topTextField.isHidden = false
            bottomTextField.isHidden = false
            topTextField.isUserInteractionEnabled = true
            bottomTextField.isUserInteractionEnabled = true
            shareBbi.isEnabled = true
            clearBbi.isEnabled = true
        }
    }
    
    func cameraBbiPressed(_ sender: UIBarButtonItem) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        
        if availableSourceTypes.count > 1 {
            
            let alert = UIAlertController(title: "Select Photo Source",
                                          message: nil,
                                          preferredStyle: .actionSheet)
            
            for source in availableSourceTypes {
                let action = UIAlertAction(title: source.1,
                                           style: .default) {
                                            (action) in
                                            imagePicker.sourceType = source.0
                                            self.present(imagePicker, animated: true, completion: nil)
                }
                alert.addAction(action)
            }
            
            let cancel = UIAlertAction(title: "Cancel",
                                       style: .cancel,
                                       handler: nil)
            alert.addAction(cancel)
            
            present(alert, animated: true, completion: nil)
        }
        else {
            imagePicker.sourceType = (availableSourceTypes.last?.0)!
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func clearBbiPressed(_ sender: UIBarButtonItem) {
        
        let alert = UIAlertController(title: "Delete Picture ?",
                                      message: nil,
                                      preferredStyle: .actionSheet)
        let proceed = UIAlertAction(title: "Delete",
                                    style: .default) {
                                        (action) in
                                        
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
}

// delegate functions for ImagePickerVC
extension MemeEditorViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        dismiss(animated: true) {
            
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
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
