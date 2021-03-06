//
//  MemeEditorViewController.swift
//  Mememe 1.0
//
//  Created by Feng Zhu on 3/23/16.
//  Copyright © 2016 Feng Zhu. All rights reserved.
//

import UIKit

class MemeEditorViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var textTop: UITextField!
    @IBOutlet weak var textBottom: UITextField!
    @IBOutlet weak var barBottom: UIToolbar!
    @IBOutlet weak var barTop: UIToolbar!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    func subscribeToKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillShow), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(keyboardWillHide), name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func unsubscribeFromKeyboardNotifications() {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func keyboardWillShow(notification: NSNotification) {
        if textBottom.isFirstResponder() {
            view.frame.origin.y = -getKeyboardHeight(notification)
        }
    }
    
    func keyboardWillHide(notification: NSNotification) {
        if textBottom.isFirstResponder() {
            view.frame.origin.y = 0
        }
    }
    
    func getKeyboardHeight(notification: NSNotification) -> CGFloat {
        let userInfo = notification.userInfo!
        let keyboardSize = userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue // of CGRect
        return keyboardSize.CGRectValue().height
    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        imageView.layer.zPosition = -5;
        
        cameraButton.enabled = UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera)
        
        if (imageView.image == nil) {
            shareButton.enabled = false
        } else {
            shareButton.enabled = true
        }
        
        subscribeToKeyboardNotifications()
        
        initTextField(textTop, initText: "top")
        initTextField(textBottom, initText: "bottom")
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    func initTextField(textField: UITextField!, initText: String?) {
        textField.delegate = self

        if let text = initText {
            textField.text = text
        } else {
            print("No init string.")
        }

        let memeTextAttributes = [
            NSStrokeColorAttributeName : UIColor.blackColor(),
            NSForegroundColorAttributeName : UIColor.whiteColor(),
            NSFontAttributeName : UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
            NSStrokeWidthAttributeName : -5,
        ]
        
        textField.defaultTextAttributes = memeTextAttributes
        textField.textAlignment = .Center
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        textField.text = ""
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    

    func pickAnImage(sourceType: UIImagePickerControllerSourceType) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.sourceType = sourceType
        self.presentViewController(imagePicker, animated: true, completion: nil)
    }

    @IBAction func pickAnImageFromAlbum(sender: AnyObject) {
        pickAnImage(UIImagePickerControllerSourceType.PhotoLibrary)
    }
    
    @IBAction func pickAnImageFromCamera (sender: AnyObject) {
        pickAnImage(UIImagePickerControllerSourceType.Camera)
    }

    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            dismissViewControllerAnimated(true, completion: nil)
        }
    }
    
    
    func generateMemedImage() -> UIImage {
        
        barBottom.hidden = true
        barTop.hidden = true
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawViewHierarchyInRect(self.view.frame, afterScreenUpdates: true)
        let memedImage : UIImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        barBottom.hidden = false
        barTop.hidden = false
        
        return memedImage
    }
    
    func save(memedImage: UIImage) {
        let meme = Meme(topText: textTop.text!, bottomText: textBottom.text!, originalImg: imageView.image, memedImg: memedImage)
    }
    
    @IBAction func shareButtonClicked(sender: AnyObject) {
        let memedImage = generateMemedImage()
        
        let shareViewController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)

        self.presentViewController(shareViewController, animated: true, completion: nil)
        shareViewController.completionWithItemsHandler = { (activityType: String?, completed: Bool, returnedItems: [AnyObject]?, activityError: NSError?) in
            if completed {
                shareViewController.dismissViewControllerAnimated(true, completion: nil)
                self.save(memedImage)
            }
        }
    }
}

