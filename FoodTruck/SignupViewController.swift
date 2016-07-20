//
//  SignupViewController.swift
//  FoodTruck
//
//  Created by AJ Bronson on 7/19/16.
//  Copyright © 2016 DevMountain. All rights reserved.
//

import UIKit

class SignupViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var foodTruckTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet var pickerView: UIPickerView!
    
    var truckOptions = [Truck]() {
        didSet {
            truckOptions.sortInPlace({$0.name < $1.name})
        }
    }
    
    
    var selectedTruck: Truck? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTrucks()
        setupView()
        hideFields()
    }
    
    func loadTrucks() {
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        CloudKitManager.sharedManager.fetchRecordsWithType("Truck", recordFetchedBlock: nil) { (records, error) in
            if let error = error {
                print("Error fetching trucks -\(error.localizedDescription)")
            } else if let records = records {
                let trucks = records.flatMap({Truck(record: $0)})
                dispatch_async(dispatch_get_main_queue(), {
                    self.truckOptions = trucks
                    self.pickerView.reloadAllComponents()
                })
            }
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
        }
    }
    
    @IBAction func screenTapped(sender: UITapGestureRecognizer) {
        resignResponders()
    }
    
    func resignResponders() {
        foodTruckTextField.resignFirstResponder()
        firstNameTextField.resignFirstResponder()
        lastNameTextField.resignFirstResponder()
        emailTextField.resignFirstResponder()
    }

    
    @IBAction func saveButtonTapped(sender: UIBarButtonItem) {
        if segmentedControl.selectedSegmentIndex == 0 {
            //individual user
            guard let first = firstNameTextField.text, last = lastNameTextField.text where first.characters.count > 0 && last.characters.count > 0 else { showAlert(); return }
            UserController.saveUserToCloudKit(first, lastName: last, email: nil, truckReference: nil)
            //TODO: segue to map
        } else {
            //food truck
            guard let first = firstNameTextField.text, last = lastNameTextField.text, email = emailTextField.text, truck = selectedTruck where first.characters.count > 0 && last.characters.count > 0 && email.characters.count > 0 else { showAlert(); return }
            UserController.saveUserToCloudKit(first, lastName: last, email: email, truckReference: truck.reference)
            //TODO: segue to map
        }
    }
    
    @IBAction func setmentedControlChanged(sender: UISegmentedControl) {
        resignResponders()
        if sender.selectedSegmentIndex == 0 {
            hideFields()
        } else {
            foodTruckTextField.hidden = false
            emailTextField.hidden = false
        }
    }
    
    func hideFields() {
        foodTruckTextField.hidden = true
        emailTextField.hidden = true
    }
    
    func showAlert() {
        let alert = UIAlertController(title: "Error", message: "Please Enter Data For All Fields", preferredStyle: .Alert)
        let okAction = UIAlertAction(title: "OK", style: .Default, handler: nil)
        alert.addAction(okAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return truckOptions.count
        
    }
    
    //MARK: Delegates
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return truckOptions[row].name
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        foodTruckTextField.text = truckOptions[row].name
        selectedTruck = truckOptions[row]
    }
    
    func addNewTruck() {
        if let resultController = storyboard?.instantiateViewControllerWithIdentifier("newTruck") as? NewTruckViewController {
            navigationController?.pushViewController(resultController, animated: true)
        }

    }
    
    func setupView() {
        let toolBar = UIToolbar()
        toolBar.barStyle = UIBarStyle.Default
        toolBar.translucent = true
        toolBar.tintColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1)
        toolBar.sizeToFit()
        
        pickerView.showsSelectionIndicator = true
        
        let addButton = UIBarButtonItem(title: "Add", style: .Done, target: self, action: #selector(addNewTruck))
        
        toolBar.setItems([addButton], animated: false)
        toolBar.userInteractionEnabled = true
        
        foodTruckTextField.inputView = pickerView
        foodTruckTextField.inputAccessoryView = toolBar
        foodTruckTextField.delegate = self
        firstNameTextField.delegate = self
        lastNameTextField.delegate = self
        emailTextField.delegate = self
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        if textField == foodTruckTextField {
            if truckOptions.count > 0 {
                textField.text = truckOptions[pickerView.selectedRowInComponent(0)].name
                selectedTruck = truckOptions[pickerView.selectedRowInComponent(0)]
            }
        }
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

