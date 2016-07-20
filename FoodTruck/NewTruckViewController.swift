//
//  NewTruckViewController.swift
//  FoodTruck
//
//  Created by AJ Bronson on 7/19/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit
import CloudKit


class NewTruckViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate, SaveTruckProtocol {
    
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var selectImageButton: UIButton!
    
    var signupController: SignupViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        TruckController.sharedController.delegate = self
        if let destinationVC = navigationController?.viewControllers[0] as? SignupViewController {
            signupController = destinationVC
        }
    }
    
    @IBAction func selectPhotoButtonTapped(sender: UIButton) {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        let alert = UIAlertController(title: "Select Photo Location", message: nil, preferredStyle: .ActionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary) {
            alert.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (_) -> Void in
                imagePicker.sourceType = .PhotoLibrary
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }))
        }
        if UIImagePickerController.isSourceTypeAvailable(.Camera) {
            alert.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (_) -> Void in
                imagePicker.sourceType = .Camera
                self.presentViewController(imagePicker, animated: true, completion: nil)
            }))
        }
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        picker.dismissViewControllerAnimated(true, completion: nil)
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectImageButton.setTitle("", forState: .Normal)
            imageView.image = image
        }
    }
    
    @IBAction func cancelButtonTapped(sender: UIBarButtonItem) {
        navigationController?.popViewControllerAnimated(true)
    }
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        guard let image = imageView.image,
            let name = nameTextField.text,
            let imageData = UIImageJPEGRepresentation(image, 0.8),
            let signupController = signupController where name.characters.count > 0 else { showAlert("Please Select Photo and Enter Truck Name"); return }
        var exists = false
        for truck in signupController.truckOptions {
            if truck.name.lowercaseString == name.lowercaseString {
                exists = true
                showAlert("This truck already exists!")
            }
        }
        if !exists {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            TruckController.sharedController.saveTruck(name, image: imageData)
            UIApplication.sharedApplication().beginIgnoringInteractionEvents()
        }
    }
    
    func truckFinishedSaving(record: CKRecord?) {
        if let record = record {
            let truck = Truck(record: record)
            if let signupController = signupController,
                let truck = truck {
                signupController.truckOptions.append(truck)
                for i in 0..<signupController.truckOptions.count {
                    if signupController.truckOptions[i].id == truck.id {
                        signupController.pickerView.selectRow(i, inComponent: 0, animated: true)
                        signupController.selectedTruck = signupController.truckOptions[i]
                    }
                }
            }
        }
        UIApplication.sharedApplication().endIgnoringInteractionEvents()
        UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        self.navigationController?.popViewControllerAnimated(true)
    }
    
    func showAlert(message: String) {
        let alert = UIAlertController(title: "Error", message: message, preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let destinationVC = segue.destinationViewController as? SignupViewController {
            destinationVC
        }
    }
}
