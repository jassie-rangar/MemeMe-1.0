//
//  ViewController.swift
//  MemeMe-1.0
//
//  Created by Jaskirat Singh on 21/06/17.
//  Copyright © 2017 jassie. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UIImagePickerControllerDelegate,UITextFieldDelegate,UINavigationControllerDelegate {

    //MARK: IBOutlets
    @IBOutlet weak var navigationBar: UINavigationBar!
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var topTextField: UITextField!
    @IBOutlet weak var bottomTextField: UITextField!
    @IBOutlet weak var cameraButton: UIBarButtonItem!
    @IBOutlet weak var shareButton: UIBarButtonItem!
    
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: IBAction(Picking Image using Album Button)
    @IBAction func pickAnImageFromAlbum(_ sender: Any) {
        pickAnImageFromAlbumOrCamera(source: UIImagePickerControllerSourceType.photoLibrary)
        
    }
    
    //MARK: IBAction(Picking Image using Camera Button)
    @IBAction func pickAnImageFromCamera(_ sender: Any) {
        pickAnImageFromAlbumOrCamera(source: UIImagePickerControllerSourceType.camera)
    }
    
    //MARK: Defining the source type for picking an Image
    func pickAnImageFromAlbumOrCamera(source:UIImagePickerControllerSourceType){
        let pickerController = UIImagePickerController()
        pickerController.delegate = self
        pickerController.sourceType = source
        present(pickerController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        cameraButton.isEnabled = UIImagePickerController.isSourceTypeAvailable(.camera)
        subscribeToKeyboardNotifications()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    //MARK: Receiving an Image using Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            imageView.image = image
            imageView.contentMode = .scaleAspectFit
            shareButton.isEnabled = true
        }
        dismiss(animated: true, completion: nil)
    }
    
    //MARK: dissmissing the imagePickerController method
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: setting the initial text of textfields
    override func viewDidLoad() {
        super.viewDidLoad()
        setText(textField: topTextField, string: "TOP")
        setText(textField: bottomTextField, string: "BOTTOM")
        shareButton.isEnabled = false
    }
    
    //MARK: is called when view is loading
    func setText(textField: UITextField, string: String){
        textField.text = string
        textField.defaultTextAttributes = memeMeTextAttributes
        textField.textAlignment = .center
        textField.delegate = self
        textField.borderStyle = .none
    }
    
    //MARK: setting font style and color
    let memeMeTextAttributes:[String:Any] = [
        NSAttributedStringKey.strokeColor.rawValue: UIColor.black ,
        NSAttributedStringKey.foregroundColor.rawValue: UIColor.white,
        NSAttributedStringKey.font.rawValue: UIFont(name: "HelveticaNeue-CondensedBlack", size: 40)!,
        NSAttributedStringKey.strokeWidth.rawValue: -3.0
    ]
    
   //MARK: textField Delegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //MARK: begin editing in textField
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.text == "TOP" || textField.text == "BOTTOM"{
        textField.text = ""
        }
    }

    //Mark: Subscription to keyboard notifications
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: .UIKeyboardWillHide, object: nil)

    }
    
    //MARK: Unsubscribtion to keyboard notifications
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
    }
    
    //MARK: code to adjust the the hieght of keyboard and image frame
    @objc func keyboardWillShow(_ notification:Notification) {
        if bottomTextField.isFirstResponder{
        view.frame.origin.y -= getKeyboardHeight(notification)
        }
    }
    
    //MARK: code to place the frame to original position
    @objc func keyboardWillHide(notification: NSNotification) {
        if bottomTextField.isFirstResponder {
            self.view.frame.origin.y = 0
        }
    }
    
    //MARK: code to calculate hieght of keyboard
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }

    //MARK: to Hide/Unhide toolbar/navbar
    func toggleToolBarVisibility(hide: Bool) {
        navigationBar.isHidden = hide
        toolbar.isHidden = hide
    }
    
    //MARK: memedImage genrator
    func generateMemedImage() -> UIImage {
        
        toggleToolBarVisibility(hide: true) // hide nav and tool bar
        
        // Render view to an image
        UIGraphicsBeginImageContext(self.view.frame.size)
        view.drawHierarchy(in: self.view.frame, afterScreenUpdates: true)
        let memedImage:UIImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        toggleToolBarVisibility(hide: false) // unhide nav and tool bar
        
        return memedImage
    }
    
    //MARK: saving the memedImmage
    func save(memedImage: UIImage) {
        // Create the meme
        let meme = MemeMe(topText: topTextField.text!, bottomText: bottomTextField.text!, originalImage: imageView.image!, memedImage: memedImage)
    }
    
    //MARK: Sharing Action method
    @IBAction func activityViewController(_ sender: Any) {
        let memedImage = generateMemedImage()
        let shareController = UIActivityViewController(activityItems: [memedImage], applicationActivities: nil)
        present(shareController, animated: true, completion: nil)
        shareController.completionWithItemsHandler = {activity, completed, items, error -> Void in
            if completed{
                self.save(memedImage: memedImage)
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
 
    //MARK: refreshing the app Action method
    @IBAction func cancel(_ sender: Any) {
        topTextField.text = "TOP"
        bottomTextField.text = "BOTTOM"
        imageView.image = nil
        shareButton.isEnabled = false
    }
    
}
