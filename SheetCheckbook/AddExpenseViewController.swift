//
//  AddExpenseViewController.swift
//  T-Budget
//
//  Created by Tom Spaulding on 7/25/17.
//  Copyright © 2017 Tom Spaulding. All rights reserved.
//
import SwiftyPickerPopover
import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class AddExpenseViewController: UIViewController, UITextFieldDelegate {
    
    var receivedService = GTLRSheetsService()
    
    private let startingRowIndex = 4;
    
    @IBOutlet var HeaderBg: UIView!
    @IBOutlet var LocationTextField: UITextField!
    @IBOutlet var AmountTextField: UITextField!
    @IBOutlet var SubmitButton: UIButton!
    @IBOutlet var AccountToggle: UISegmentedControl!
    @IBOutlet var Loader: UIActivityIndicatorView!
    @IBOutlet var SuccessNotification: UIView!
    @IBOutlet var BudgetField: UILabel!
    
    @IBAction func SubmitTap(_ sender: Any) {
        let locationString = LocationTextField.text;
        let amountString = AmountTextField.text;
        
        if(locationString == nil || amountString == nil || locationString!.isEmpty || amountString!.isEmpty){
            showAlert(title: "Missing Date", message: "Please provide location and amount")
        }
        else {
            if(AccountToggle.selectedSegmentIndex == 0){
                sendCreditExpenseToGoogleSheet();
            }
            else {
                sendCheckingExpenseToGoogleSheet();
            }
        }
    }
    
    @IBAction func BudgetFieldTap(_ sender: Any) {
        StringPickerPopover(title: "StringPicker", choices: ["None", "Gas", "Groceries"])
            .setSelectedRow(0)
            .setDoneButton(action: { (popover, selectedRow, selectedString) in
                self.BudgetField.text = selectedString;
            })
            .setCancelButton(action: { v in self.BudgetField.text = "None" }
            )
            .appear(originView: BudgetField, baseViewController: self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HeaderBg.setGradientBackground(colorOne: Colors.darkOrange, colorTwo: Colors.lightOragne);
        SuccessNotification.setGradientBackground(colorOne: Colors.darkOrange, colorTwo: Colors.lightOragne);
        
        SubmitButton.layer.cornerRadius = 5;
        SubmitButton.layer.borderWidth = 1;
        SubmitButton.layer.borderColor = UIColor.black.cgColor;
        
        Loader.isHidden = true;
        
        LocationTextField.delegate = self;
        
        AmountTextField.delegate = self;
        AmountTextField.keyboardType = UIKeyboardType.decimalPad;
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func sendCreditExpenseToGoogleSheet() {
        let spreadsheetId = "1fqEk4yeKqjJR6zQPGlu8ZYrOPx_Y7T8vp17hin3HaFY"
        let range = "Checking!F4:G4";
        
        let locationValue = LocationTextField.text;
        let amountValue = AmountTextField.text;
        
        let valueRange = GTLRSheets_ValueRange.init();
        valueRange.values = [[locationValue!, amountValue!]];
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: valueRange, spreadsheetId: spreadsheetId, range: range)
        query.valueInputOption = "USER_ENTERED";
        receivedService.executeQuery(query, delegate: self, didFinish: #selector(addExpenseCompletion(ticket:finishedWithObject:error:)));
    }
    
    func sendCheckingExpenseToGoogleSheet() {
        let spreadsheetId = "1fqEk4yeKqjJR6zQPGlu8ZYrOPx_Y7T8vp17hin3HaFY"
        let range = "Checking!C4:D4";
        
        let locationValue = LocationTextField.text;
        let amountValue = AmountTextField.text;
        
        let valueRange = GTLRSheets_ValueRange.init();
        valueRange.values = [[locationValue!, amountValue!]];
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesAppend.query(withObject: valueRange, spreadsheetId: spreadsheetId, range: range)
        query.valueInputOption = "USER_ENTERED";
        receivedService.executeQuery(query, delegate: self, didFinish: #selector(addExpenseCompletion(ticket:finishedWithObject:error:)));
    }
    
    func addExpenseCompletion(ticket: GTLRServiceTicket,
                              finishedWithObject result : GTLRSheets_ValueRange,
                              error : NSError?) {
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        if(BudgetField.text != "None"){
            updateBudgetValues();
        } else {
            clearFields();
            endLoader();
            showSuccessNotif();
        }
    }
    
    func updateBudgetValues() {
        let range = getRangeDependingOnBudgetString();
        
        let spreadsheetId = "1fqEk4yeKqjJR6zQPGlu8ZYrOPx_Y7T8vp17hin3HaFY"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range:String(describing: range))
        receivedService.executeQuery(query, delegate: self, didFinish: #selector(sendUpdatedBudgetToGoogleSheet(ticket:finishedWithObject:error:)))
    }
    
    func sendUpdatedBudgetToGoogleSheet(ticket: GTLRServiceTicket, finishedWithObject result : GTLRSheets_ValueRange, error : NSError?) {
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        if(result.values != nil) {
            let rows = result.values!
            
            if(rows.isEmpty) {
                return
            }
            
            for row in rows {
                let currentBudgetValue = row[0];
                let currentBudgetValueString = String(describing: currentBudgetValue);
                let subractValue = AmountTextField.text!;
                
                let newValue = Float(currentBudgetValueString)! - Float(subractValue)!;
                let valueRange = GTLRSheets_ValueRange.init();
                valueRange.values = [[newValue]];
                
                let spreadsheetId = "1fqEk4yeKqjJR6zQPGlu8ZYrOPx_Y7T8vp17hin3HaFY"
                let range = getRangeDependingOnBudgetString();
                let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: valueRange, spreadsheetId: spreadsheetId, range: range)
                query.valueInputOption = "USER_ENTERED";
                receivedService.executeQuery(query, delegate: self, didFinish: #selector(updateedBudgetComplete(ticket:finishedWithObject:error:)));
            }
        }
    }
    
    func updateedBudgetComplete(ticket: GTLRServiceTicket,
                                finishedWithObject result : GTLRSheets_ValueRange,
                                error : NSError?) {
        clearFields();
        endLoader();
        showSuccessNotif();
    }
    
    func getRangeDependingOnBudgetString() -> String {
        var range = "";
        if(BudgetField.text == "Gas") {
            range = "Checking!K17"
        }
        if(BudgetField.text == "Groceries") {
            range = "Checking!K18"
        }
        
        return range;
    }
    
    func showLoader(){
        Loader.startAnimating();
        Loader.isHidden = false;
    }
    
    func endLoader() {
        Loader.isHidden = true;
        Loader.stopAnimating();
    }
    
    func showSuccessNotif() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.SuccessNotification.alpha = 1;
            self.SuccessNotification.frame.origin.y -= self.SuccessNotification.frame.height;
        });
        
        //Auto hide the success notification
        let when = DispatchTime.now() + 2 // Wait 1 second
        DispatchQueue.main.asyncAfter(deadline: when) {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.SuccessNotification.alpha = 0;
                self.SuccessNotification.frame.origin.y += self.SuccessNotification.frame.height;
            });
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if(textField.tag == 1) {
            let aSet = NSCharacterSet(charactersIn:"0123456789.").inverted
            let compSepByCharInSet = string.components(separatedBy: aSet)
            let numberFiltered = compSepByCharInSet.joined(separator: "")
            return string == numberFiltered
        } else {
            return true;
        }
    }
    
    func textFieldShouldReturn(_ scoreText: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
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
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func clearFields() {
        AmountTextField.text = "";
        LocationTextField.text = "";
        BudgetField.text = "";
    }
}
