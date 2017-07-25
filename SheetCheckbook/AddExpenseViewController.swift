//
//  AddExpenseViewController.swift
//  T-Budget
//
//  Created by Tom Spaulding on 7/25/17.
//  Copyright © 2017 Tom Spaulding. All rights reserved.
//

import UIKit

class AddExpenseViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var HeaderBg: UIView!
    @IBOutlet var LocationTextField: UITextField!
    @IBOutlet var AmountTextField: UITextField!
    @IBOutlet var SubmitButton: UIButton!
    
    @IBAction func SubmitTap(_ sender: Any) {
        let locationString = LocationTextField.text;
        let amountString = AmountTextField.text;
        
        if(locationString == nil || amountString == nil || locationString!.isEmpty || amountString!.isEmpty){
            showAlert(title: "Missing Date", message: "Please provide location and amount")
        }
        else {
            let amountDouble = Double(amountString!);
            let amountRounded = String(format: "%.2f", amountDouble!);
            
            
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        HeaderBg.setGradientBackground(colorOne: Colors.darkOrange, colorTwo: Colors.lightOragne);
        
        SubmitButton.layer.cornerRadius = 5;
        SubmitButton.layer.borderWidth = 1;
        SubmitButton.layer.borderColor = UIColor.black.cgColor;
        
        AmountTextField.delegate = self;
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
        let compSepByCharInSet = string.components(separatedBy: aSet)
        let numberFiltered = compSepByCharInSet.joined(separator: "")
        return string == numberFiltered
    }
    

    // Helper for showing an alert
    func showAlert(title : String, message: String) {
        let alert = UIAlertController(
            title: title,
            message: message,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        present(alert, animated: true, completion: nil)
    }
}
