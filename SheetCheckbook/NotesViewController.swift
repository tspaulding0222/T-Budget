//
//  NotesViewController.swift
//  T-Budget
//
//  Created by Tom Spaulding on 7/27/17.
//  Copyright © 2017 Tom Spaulding. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class NotesViewController: UIViewController {
    
    var receivedService = GTLRSheetsService()

    @IBOutlet var HeaderBg: UIView!
    @IBOutlet var NoteText: UITextView!
    @IBOutlet var SubmitButton: UIButton!
    @IBOutlet var ResetButton: UIButton!
    @IBOutlet var Loader: UIActivityIndicatorView!
    @IBOutlet var SuccessNotif: UIView!
    
    @IBAction func ResetTap(_ sender: Any) {
        NoteText.text = "";
        
        getNoteFromGoogleSheet();
    }
    
    @IBAction func SubmitChangesTap(_ sender: Any) {
        sendNoteChangesToGoogleSheet();
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        HeaderBg.setGradientBackground(colorOne: Colors.darkOrange, colorTwo: Colors.lightOragne);
        
        SuccessNotif.setGradientBackground(colorOne: Colors.darkOrange, colorTwo: Colors.lightOragne);
        
        NoteText.layer.cornerRadius = 5;
        NoteText.layer.borderWidth = 1;
        NoteText.layer.borderColor = UIColor.black.cgColor;
        
        SubmitButton.layer.cornerRadius = 5;
        SubmitButton.layer.borderWidth = 1;
        SubmitButton.layer.borderColor = UIColor.black.cgColor;
        
        ResetButton.layer.cornerRadius = 5;
        ResetButton.layer.borderWidth = 1;
        ResetButton.layer.borderColor = UIColor.black.cgColor;
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeDown.direction = .down
        self.view.addGestureRecognizer(swipeDown)
        
        //Looks for single or multiple taps.
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        
        //Uncomment the line below if you want the tap not not interfere and cancel other interactions.
//        tap.cancelsTouchesInView = false
        
        view.addGestureRecognizer(tap)
        
        getNoteFromGoogleSheet();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getNoteFromGoogleSheet() {
        startLoader();
        
        let spreadsheetId = "1fqEk4yeKqjJR6zQPGlu8ZYrOPx_Y7T8vp17hin3HaFY"
        let range = "Checking!C24"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        receivedService.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displaySpendingNote(ticket:finishedWithObject:error:)))
    }
    
    func displaySpendingNote(ticket: GTLRServiceTicket,
                                            finishedWithObject result : GTLRSheets_ValueRange,
                                            error : NSError?) {
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        let rows = result.values!
        
        if rows.isEmpty {
            NoteText.text = ""
            return
        }
        
        var noteTextContents = "";
        for row in rows {
            let content = row[0];
            
            noteTextContents += "\(content)";
        }
        
        NoteText.text = noteTextContents;
        
        endLoader();
    }
    
    func sendNoteChangesToGoogleSheet() {
        dismissKeyboard();
        
        let spreadsheetId = "1fqEk4yeKqjJR6zQPGlu8ZYrOPx_Y7T8vp17hin3HaFY"
        let range = "Checking!C24";
        
        let valueRange = GTLRSheets_ValueRange.init();
        valueRange.values = [[NoteText.text]];
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: valueRange, spreadsheetId: spreadsheetId, range:range)
        query.valueInputOption = "USER_ENTERED";
        receivedService.executeQuery(query, delegate: self, didFinish: #selector(submitNoteChangesCompletion(ticket:finishedWithObject:error:)));
    }
    
    func submitNoteChangesCompletion(ticket: GTLRServiceTicket,
                                     finishedWithObject result : GTLRSheets_ValueRange,
                                     error : NSError?) {
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        endLoader();
        showSuccessNotif();
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
    
    func startLoader() {
        Loader.startAnimating();
        Loader.isHidden = false;
    }
    
    func endLoader() {
        Loader.isHidden = true;
        Loader.stopAnimating();
    }
    
    func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func showSuccessNotif() {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.SuccessNotif.alpha = 1;
            self.SuccessNotif.frame.origin.y -= self.SuccessNotif.frame.height;
        });
        
        //Auto hide the success notification
        let when = DispatchTime.now() + 2 // Wait 1 second
        DispatchQueue.main.asyncAfter(deadline: when) {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.SuccessNotif.alpha = 0;
                self.SuccessNotif.frame.origin.y += self.SuccessNotif.frame.height;
            });
        }
    }

}
