//
//  BalancesViewController.swift
//  T-Budget
//
//  Created by Tom Spaulding on 7/27/17.
//  Copyright © 2017 Tom Spaulding. All rights reserved.
//

import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class BalancesViewController: UIViewController {
    
    var receivedService = GTLRSheetsService()
    let tomPadding = 7
    var currentYLocation = 0;

    @IBOutlet var HeaderBf: UIView!
    @IBOutlet var Container: UIView!
    @IBOutlet var Loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Common.hideLoader(Loader: Loader);
        
        HeaderBf.setGradientBackground(colorOne: Colors.darkOrange, colorTwo: Colors.lightOragne);

        getBalancesFromGoogleSheet();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getBalancesFromGoogleSheet() {
        Common.showLoader(Loader: Loader);
        
        let spreadsheetId = "1fqEk4yeKqjJR6zQPGlu8ZYrOPx_Y7T8vp17hin3HaFY"
        let range = "Checking!A2:A18"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        receivedService.executeQuery(query,
                                     delegate: self,
                                     didFinish: #selector(getBalancesComplete(ticket:finishedWithObject:error:)))
    }
    
    func getBalancesComplete(ticket: GTLRServiceTicket,
                             finishedWithObject result : GTLRSheets_ValueRange,
                             error : NSError?) {
        if let error = error {
            Common.showAlert(title: "Error", message: error.localizedDescription, controller: self);
            return
        }
        
        if(result.values != nil) {
            let rows = result.values!
            
            if rows.isEmpty {
                return
            }
            
            for row in rows {
                if(row.count > 0) {
                    let value = row[0]
                    
                    createBalanceView(displayText: String(describing: value))
                }
            }
        }
        
        Common.hideLoader(Loader: Loader);
    }
    
    func createBalanceView(displayText: String) {
        let labelView = UILabel(frame: CGRect(x: 0, y: currentYLocation, width: Int(Container.frame.width), height: 20))
        labelView.textColor = UIColor.white;
        labelView.text = displayText;
        labelView.font = labelView.font.withSize(14);
        
        currentYLocation = currentYLocation + Int(labelView.frame.height);
        
        Container.addSubview(labelView);
    }
}
