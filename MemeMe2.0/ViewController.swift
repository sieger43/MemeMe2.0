//
//  ViewController.swift
//  MemeMe2.0
//
//  Created by John Berndt on 12/10/18.
//  Copyright © 2018 Siegersoft. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageViewOutlet: UIImageView!
    let pickerController = UIImagePickerController()
    
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    
    let memeDelegate = MemeTextFieldDelegate()
    
    var theMeme: Meme?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.pickerController.delegate = self
        
        self.toolbarItems?[1] = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.camera, target: self, action:(#selector(ViewController.pickAnImageFromCamera(_:))))
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.action, target: self, action:(#selector(ViewController.launchActivityView(_:))))
        self.navigationItem.leftBarButtonItem?.isEnabled = false
        
        setupTextField(tf: topTextField)
        topTextField.delegate = memeDelegate
        setupTextField(tf: bottomTextField)
        bottomTextField.delegate = self
        
        theMeme = nil
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.toolbarItems?[1].isEnabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerController.SourceType.camera)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }

    func setupTextField(tf: UITextField) {
        tf.defaultTextAttributes = [
            NSAttributedString.Key.strokeColor : UIColor.black,
            NSAttributedString.Key.foregroundColor : UIColor.white,
            NSAttributedString.Key.font : UIFont(name: "HelveticaNeue-CondensedBlack", size:40)!,
            NSAttributedString.Key.strokeWidth : -3.0 as AnyObject
        ]
        tf.textColor = UIColor.white
        tf.tintColor = UIColor.white
        tf.textAlignment = .center
    }
    
    @IBAction func pickAnImageFromCamera(_ sender: AnyObject) {
        chooseImageFromCameraOrPhoto(source: UIImagePickerController.SourceType.camera)
    }
    
    @IBAction func pickAnImage(_ sender: AnyObject) {
        chooseImageFromCameraOrPhoto(source: UIImagePickerController.SourceType.photoLibrary)
    }
    
    func chooseImageFromCameraOrPhoto(source: UIImagePickerController.SourceType) {
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.allowsEditing = true
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    @IBAction func launchActivityView(_ sender: AnyObject) {
        if(imageViewOutlet != nil){

            let memedImage = generateMemedImage()
            let activityController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
            
            activityController.completionWithItemsHandler = { activity, success, items, error in
                if success {
                    self.dismiss(animated: true, completion: nil)
                }
            }
            
            present(activityController, animated: true, completion: nil)

        }
    }
    
    @IBAction func cancelTheMeme(_ sender: AnyObject) {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        self.imageViewOutlet.image = nil
        self.topTextField.text = nil
        self.bottomTextField.text = nil
        self.theMeme = nil
        
        self.dismiss(animated: true, completion: nil)
    }
    
    func generateMemedImage() -> UIImage {
        self.navigationController?.isNavigationBarHidden = true
        self.navigationController?.isToolbarHidden = true

        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame,
            afterScreenUpdates: true)
        let memedImageOriginal : UIImage =
        UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        let origData = memedImageOriginal.pngData()
        let memedImage = UIImage(data: origData!)
        
        
        self.navigationController?.isToolbarHidden = false
        self.navigationController?.isNavigationBarHidden = false
        
        let meme = Meme( topText: self.topTextField.text, bottomText: self.bottomTextField.text,
                         originalImage: self.imageViewOutlet.image, memedImage: memedImage)
        
        let object = UIApplication.shared.delegate
        let appDelegate = object as! AppDelegate
        appDelegate.memes.append(meme)
        
        return memedImage!
    }
    
    func imagePickerController(_ _picker: UIImagePickerController,
        didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]){

        let info = Dictionary(uniqueKeysWithValues: info.map {key, value in (key.rawValue, value)})
        
        if let image = info[UIImagePickerController.InfoKey.originalImage.rawValue] as? UIImage {
            self.imageViewOutlet.image = image
            self.navigationItem.leftBarButtonItem?.isEnabled = true
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func subscribeToKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(ViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name:
            UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name:
                UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        if self.view.frame.origin.y == 0 {
            view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }

    @objc func keyboardWillHide(_ notification: Notification) {
        if self.view.frame.origin.y != 0 {
            view.frame.origin.y += getKeyboardHeight(notification)
        }
    }
    
    func getKeyboardHeight(_ notification: Notification) -> CGFloat {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIResponder.keyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.cgRectValue.height
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        subscribeToKeyboardNotifications()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        unsubscribeFromKeyboardNotifications()
        return false
    }
}
