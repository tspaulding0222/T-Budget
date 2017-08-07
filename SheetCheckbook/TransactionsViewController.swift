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
    
    var checkingString: String? = nil;
    var creditString: String? = nil;
    
    @IBOutlet var HeaderBg: UIView!
    @IBOutlet var ScrollView: UIScrollView!
    @IBOutlet var Loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        endLoader();
        
        HeaderBg.setGradientBackground(colorOne: Colors.darkOrange, colorTwo: Colors.lightOragne);
        
        ScrollView.showsVerticalScrollIndicator = false
        
        getCheckingTransactions();
        getCreditTransactions();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getCheckingTransactions() {
        showLoader();
        
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
            endLoader();
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        createLabelHeaderView(headerText: "Checking");
        

        if(result.values != nil){
            let rows = result.values!
            
            if rows.isEmpty {
                return
            }
            
            for row in rows {
                let name = row[0];
                let value = row[1];
                
                let tempString = "\(name) - \(value)\n\n";
                createTransactionTextView(transText: tempString);
            }
        } else {
            createTransactionTextView(transText: "No Checking Transactions Found");
        }
        
        endLoader();
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
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        createLabelHeaderView(headerText: "Credit");
    
        if(result.values != nil) {
            let rows = result.values!
            
            if rows.isEmpty {
                return
            }
            
            for row in rows {
                let name = row[0];
                let value = row[1];
                
                let tempString = "\(name) - \(value)\n\n";
                createTransactionTextView(transText: tempString);
            }
        }
        else {
            createTransactionTextView(transText: "No Credit Transactions Found");
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
    
    func createTransactionTextView(transText: String){
        let labelView = UILabel(frame: CGRect(x: 0, y: currentYInScrollView, width: Int(self.ScrollView.frame.width), height: 20));
        labelView.textColor = UIColor.white;
        labelView.text = transText;
        labelView.font = labelView.font.withSize(12);
        
        currentYInScrollView = currentYInScrollView + Int(labelView.frame.height) + tomPadding;
        ScrollView.contentSize = CGSize(width: ScrollView.frame.width, height: CGFloat(currentYInScrollView));
        
        ScrollView.addSubview(labelView);
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
    
    func showLoader(){
        Loader.startAnimating();
        Loader.isHidden = false;
    }
    
    func endLoader() {
        Loader.isHidden = true;
        Loader.stopAnimating();
    }
}
