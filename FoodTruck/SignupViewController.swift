//
//  SignupViewController.swift
//  FoodTruck
//
//  Created by AJ Bronson on 7/19/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var foodTruckTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var truckImageView: UIImageView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideFields()
    }
    
    
    @IBAction func truckImageTapped(sender: UITapGestureRecognizer) {
        print("Image section tapped")
    }
    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        if segmentedControl.selectedSegmentIndex == 0 {
            //individual user
            guard let first = firstNameTextField.text, last = lastNameTextField.text where first.characters.count > 0 && last.characters.count > 0 else { showAlert(); return }
            //TODO: save to NSUserDefaults, save to CloudKit?, segue to map
        } else {
            //food truck
            guard let first = firstNameTextField.text, last = lastNameTextField.text, email = emailTextField.text, truck = foodTruckTextField.text where first.characters.count > 0 && last.characters.count > 0 && truck.characters.count > 0 && email.characters.count > 0 else { showAlert(); return }
            //TODO: save to NSUserDefaults, save to CloudKit?, segue to map
        }
    }
    
    @IBAction func setmentedControlChanged(sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            hideFields()
        } else {
            foodTruckTextField.hidden = false
            emailTextField.hidden = false
            truckImageView.hidden = false
        }
    }
    
    func hideFields() {
        foodTruckTextField.hidden = true
        emailTextField.hidden = true
        truckImageView.hidden = true
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Error", message: "Please Enter Data For All Fields", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
}
