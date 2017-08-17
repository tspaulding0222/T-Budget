//
//  BillsViewController.swift
//  T-Budget
//
//  Created by Tom Spaulding on 7/27/17.
//  Copyright © 2017 Tom Spaulding. All rights reserved.
//
import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class BillsViewController: UIViewController {
    
    var receivedService = GTLRSheetsService()
    var currentYInScrollView = 0;
    var labelViewHeight = 25;
    
    @IBOutlet var HeaderBg: UIView!
    @IBOutlet var Container: UIView!
    @IBOutlet var MiddleContainer: UIView!
    @IBOutlet var EndContainer: UIView!
    @IBOutlet var Loader: UIActivityIndicatorView!
    @IBOutlet var ScrollView: UIScrollView!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        endLoader();
        
        HeaderBg.setGradientBackground(colorOne: Colors.darkOrange, colorTwo: Colors.lightOragne);
        
        getMonthlyBillsFromGoogleSheet();
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func getMonthlyBillsFromGoogleSheet() {
        showLoader();
        
        let spreadsheetId = "1fqEk4yeKqjJR6zQPGlu8ZYrOPx_Y7T8vp17hin3HaFY"
        let range = "Checking!I4:L29"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range:range)
        receivedService.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayMontlyBillsToView(ticket:finishedWithObject:error:)))
    }
    
    func displayMontlyBillsToView(ticket: GTLRServiceTicket,
                                  finishedWithObject result : GTLRSheets_ValueRange,
                                  error : NSError?){
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        if(result.values != nil) {
            let rows = result.values!
            
            if rows.isEmpty {
                return
            }
            
            for row in rows {
                let rowName = row[0]
                let rowDay = row[1]
                let rowValue = row[3]
                
                createMonthlyBillView(name: String(describing: rowName), day: String(describing: rowDay), value: String(describing: rowValue));
            }
        } else {
            createMonthlyBillView(name: "", day: "", value: "");
        }
        
        // Set the height of the scroll view
        ScrollView.contentSize = CGSize(width: ScrollView.frame.width, height: CGFloat(currentYInScrollView));
        
        endLoader();
    }
    
    func createMonthlyBillView(name: String, day: String, value: String) {
        createMonthlyBillViewStart(billText: name)
        createMonthlyBillViewMiddle(billText: day)
        createMonthlyBillViewEnd(billText: value)
        
        currentYInScrollView = currentYInScrollView + labelViewHeight
    }
    
    func createMonthlyBillViewStart(billText: String) {
        let labelView = UILabel(frame: CGRect(x: 0, y:currentYInScrollView, width: Int(self.view.frame.width), height: labelViewHeight));
        labelView.textColor = UIColor.white;
        labelView.text = billText;
        labelView.font = labelView.font.withSize(13)
        
        Container.addSubview(labelView)
    }
    
    func createMonthlyBillViewMiddle(billText: String) {
        let labelView = UILabel(frame: CGRect(x: 0, y:currentYInScrollView, width: Int(self.view.frame.width), height: labelViewHeight));
        labelView.textColor = UIColor.white;
        labelView.text = billText;
        labelView.font = labelView.font.withSize(13)
        
        MiddleContainer.addSubview(labelView)
    }
    
    func createMonthlyBillViewEnd(billText: String) {
        let labelView = UILabel(frame: CGRect(x: 0, y:currentYInScrollView, width: Int(self.view.frame.width), height: labelViewHeight));
        labelView.textColor = UIColor.white;
        labelView.text = billText;
        labelView.font = labelView.font.withSize(13)
        
        EndContainer.addSubview(labelView)
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
