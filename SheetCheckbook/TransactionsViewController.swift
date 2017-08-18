//
//  TransactionsViewController.swift
//  T-Budget
//
//  Created by Tom Spaulding on 7/27/17.
//  Copyright © 2017 Tom Spaulding. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class TransactionsViewController: UIViewController {
    
    var receivedService = GTLRSheetsService()
    let tomPadding = 7;
    
    var currentYInScrollView = 0;
    var startingCellYIndex = 4;
    var transactionToDelete = "";
    var labelViewToDelete = UILabel();
    
    var labelViewCheckingTag = 1;
    var labelViewCreditTag = 2;
    
    var checkingString: String? = nil;
    var creditString: String? = nil;
    
    @IBOutlet var HeaderBg: UIView!
    @IBOutlet var ScrollView: UIScrollView!
    @IBOutlet var Loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Common.hideLoader(Loader: Loader);
        
        HeaderBg.setGradientBackground(colorOne: Colors.darkOrange, colorTwo: Colors.lightOragne);
        
        ScrollView.showsVerticalScrollIndicator = false
        
        getCheckingTransactions();
        getCreditTransactions();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getCheckingTransactions() {
        Common.showLoader(Loader: Loader)
        
        let spreadsheetId = "1fqEk4yeKqjJR6zQPGlu8ZYrOPx_Y7T8vp17hin3HaFY"
        let range = "Checking!C4:D21"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        receivedService.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(getTransactionsComplete(ticket:finishedWithObject:error:)))
    }
    
    func getTransactionsComplete(ticket: GTLRServiceTicket,
                                 finishedWithObject result : GTLRSheets_ValueRange,
                                 error : NSError?){
        if let error = error {
            Common.hideLoader(Loader: Loader)
            Common.showAlert(title: "Error", message: error.localizedDescription, controller: self)
            return
        }
        
        createLabelHeaderView(headerText: "Checking");
        

        if(result.values != nil){
            let rows = result.values!
            
            if rows.isEmpty {
                return
            }
            
            for row in rows {
                //TODO: Check Array Indices
                let name = row[0];
                let value = row[1];
                
                let tempString = "\(name) - \(value)\n\n";
                createTransactionTextView(transText: tempString, labelViewTag: labelViewCheckingTag);
            }
        } else {
            createTransactionTextView(transText: "No Checking Transactions Found", labelViewTag: labelViewCheckingTag);
        }
        
        Common.hideLoader(Loader: Loader)
    }
    
    func getCreditTransactions() {
        let spreadsheetId = "1fqEk4yeKqjJR6zQPGlu8ZYrOPx_Y7T8vp17hin3HaFY"
        let range = "Checking!F4:G21"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        receivedService.executeQuery(query,
                                     delegate: self,
                                     didFinish: #selector(getCreditTransactionsComplete(ticket:finishedWithObject:error:)))
    }
    
    func getCreditTransactionsComplete(ticket: GTLRServiceTicket,
                                 finishedWithObject result : GTLRSheets_ValueRange,
                                 error : NSError?){
        if let error = error {
            Common.showAlert(title: "Error", message: error.localizedDescription, controller: self)
            return
        }
        
        createLabelHeaderView(headerText: "Credit");
    
        if(result.values != nil) {
            let rows = result.values!
            
            if rows.isEmpty {
                return
            }
            
            for row in rows {
                //TODO: Check Array Indices
                let name = row[0];
                let value = row[1];
                
                let tempString = "\(name) - \(value)\n\n";
                createTransactionTextView(transText: tempString, labelViewTag: labelViewCreditTag);
            }
        }
        else {
            createTransactionTextView(transText: "No Credit Transactions Found", labelViewTag: labelViewCreditTag);
        }
    }
    
    func createLabelHeaderView(headerText: String) {
        let labelView = UILabel(frame: CGRect(x: 0, y: currentYInScrollView, width: Int(self.ScrollView.frame.width), height: 20));
        labelView.textColor = UIColor.white;
        labelView.text = headerText;
        labelView.font = UIFont.boldSystemFont(ofSize: 17);
        
        currentYInScrollView = currentYInScrollView + Int(labelView.frame.height) + tomPadding;
        ScrollView.contentSize = CGSize(width: ScrollView.frame.width, height: CGFloat(currentYInScrollView));
        
        ScrollView.addSubview(labelView);
    }
    
    func createTransactionTextView(transText: String, labelViewTag: Int){
        let labelView = UILabel(frame: CGRect(x: 0, y: currentYInScrollView, width: Int(self.ScrollView.frame.width), height: 20));
        labelView.textColor = UIColor.white;
        labelView.text = transText;
        labelView.tag = labelViewTag;
        labelView.font = labelView.font.withSize(12);
        
        currentYInScrollView = currentYInScrollView + Int(labelView.frame.height) + tomPadding;
        ScrollView.contentSize = CGSize(width: ScrollView.frame.width, height: CGFloat(currentYInScrollView));
        
        ScrollView.addSubview(labelView);
        
        labelView.isUserInteractionEnabled = true;
        let labelTouch = UITapGestureRecognizer(target: self, action: #selector(labelTap(_:)));
        labelView.addGestureRecognizer(labelTouch);
    }
    
    @objc func labelTap(_ sender: UITapGestureRecognizer) {
        if(sender.view != nil) {
            let view = sender.view! as! UILabel;
            let rag = view.text!
            var str = rag.trimmingCharacters(in: CharacterSet.newlines);
            
            if let dotRange = str.range(of: " -") {
                str.removeSubrange(dotRange.lowerBound..<str.endIndex)
            }
            
            labelViewToDelete = sender.view! as! UILabel;
            transactionToDelete = str;
        }
        
        let alert = UIAlertController(
            title: "Are You Sure?",
            message: "Do you really want to delete transaction from " + transactionToDelete,
            preferredStyle: UIAlertControllerStyle.alert
        )
        let ok = UIAlertAction(
            title: "OK",
            style: UIAlertActionStyle.default,
            handler: { action in self.getCurrentTransactions()}
        )
        let cancel = UIAlertAction(
            title: "Cancel",
            style: UIAlertActionStyle.default,
            handler: nil
        )
        alert.addAction(ok)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
    
    func getCurrentTransactions() {
        if(labelViewToDelete.tag == labelViewCheckingTag) {
            getCurrentCheckingTransactions();
        } else {
            getCurrentCreditTransactions();
        }
    }
    
    func getCurrentCheckingTransactions() {
        Common.showLoader(Loader: Loader)
        
        let spreadsheetId = "1fqEk4yeKqjJR6zQPGlu8ZYrOPx_Y7T8vp17hin3HaFY"
        let range = "Checking!C4:C21"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        receivedService.executeQuery(query,
                                     delegate: self,
                                     didFinish: #selector(findMatchingCheckingTransaction(ticket:finishedWithObject:error:)))
    }
    
    func findMatchingCheckingTransaction(ticket: GTLRServiceTicket,
                                         finishedWithObject result : GTLRSheets_ValueRange,
                                         error : NSError?) {
        if let error = error {
            Common.hideLoader(Loader: Loader)
            Common.showAlert(title: "Error", message: error.localizedDescription, controller: self)
            return
        }
        
        if(result.values != nil) {
            let rows = result.values!
            
            if rows.isEmpty {
                return
            }
            
            var index = startingCellYIndex;
            for row in rows {
                if(row.indices.contains(0)){
                    let transName = String(describing: row[0]);
                    
                    if(transName == transactionToDelete){
                        deleteCheckingTransactionFromGoogleSheet(index: index);
                    }
                    index += 1;
                }
            }
        }
    }
    
    func deleteCheckingTransactionFromGoogleSheet(index: Int) {
        let spreadsheetId = "1fqEk4yeKqjJR6zQPGlu8ZYrOPx_Y7T8vp17hin3HaFY"
        let range = "Checking!C" + String(index) + ":D" + String(index);
        
        let valueRange = GTLRSheets_ValueRange.init();
        valueRange.values = [["", ""]];
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: valueRange, spreadsheetId: spreadsheetId, range: range)
        query.valueInputOption = "USER_ENTERED";
        receivedService.executeQuery(query, delegate: self, didFinish: #selector(finishedDeletion(ticket:finishedWithObject:error:)));
    }
    
    func getCurrentCreditTransactions() {
        let spreadsheetId = "1fqEk4yeKqjJR6zQPGlu8ZYrOPx_Y7T8vp17hin3HaFY"
        let range = "Checking!F4:G21"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        receivedService.executeQuery(query,
                                     delegate: self,
                                     didFinish: #selector(findMatchingCreditTransaction(ticket:finishedWithObject:error:)))
    }
    
    func findMatchingCreditTransaction(ticket: GTLRServiceTicket, finishedWithObject result: GTLRSheets_ValueRange, error: NSError?) {
        if let error = error {
            Common.hideLoader(Loader: Loader)
            Common.showAlert(title: "Error", message: error.localizedDescription, controller: self);
            return
        }
        
        if(result.values != nil){
            let rows = result.values!
            
            if(rows.isEmpty) {
                return
            }
            
            var index = startingCellYIndex;
            for row in rows{
                if(row.indices.contains(0)) {
                    let transName = String(describing: row[0]);
                    
                    if(transName == transactionToDelete) {
                        
                        deleteCreditTransactionFromGoogleSheet(index: index);
                    }
                    index += 1;
                }
            }
        }
    }
    
    func deleteCreditTransactionFromGoogleSheet(index: Int) {
        let spreadsheetId = "1fqEk4yeKqjJR6zQPGlu8ZYrOPx_Y7T8vp17hin3HaFY"
        let range = "Checking!F" + String(index) + ":G" + String(index);
        
        let valueRange = GTLRSheets_ValueRange.init();
        valueRange.values = [["", ""]];
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesUpdate.query(withObject: valueRange, spreadsheetId: spreadsheetId, range: range)
        query.valueInputOption = "USER_ENTERED";
        receivedService.executeQuery(query, delegate: self, didFinish: #selector(finishedDeletion(ticket:finishedWithObject:error:)));
    }
    
    func finishedDeletion(ticket: GTLRServiceTicket,
                                finishedWithObject result : GTLRSheets_ValueRange,
                                error : NSError?) {
        labelViewToDelete.textColor = UIColor.red;
        labelViewToDelete.text = "DELETED";
        
        Common.hideLoader(Loader: Loader);
    }
}
