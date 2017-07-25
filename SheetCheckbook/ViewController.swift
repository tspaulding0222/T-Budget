import GoogleAPIClientForREST
import GoogleSignIn
import UIKit

class ViewController: UIViewController, GIDSignInDelegate, GIDSignInUIDelegate {
    
    
    // If modifying these scopes, delete your previously saved credentials by
    // resetting the iOS simulator or uninstall the app.
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]
    
    private let service = GTLRSheetsService()
    let signInButton = GIDSignInButton()
    
    private let leftBarWidth = 139;
    private let leftBarOpen = false;
   
    @IBOutlet var sa_output: UILabel!
    @IBOutlet var output: UITextView!
    @IBOutlet var loader: UIActivityIndicatorView!
    @IBOutlet var HeaderBg: UIView!
    @IBOutlet var LeftBar: UIView!
    
    @IBAction func refreshButtonTap(_ sender: Any) {
        print("Refresh Tapped");
        
        output.text = "";
        sa_output.text = "";
        
        loader.isHidden = false
        loader.startAnimating();
        
        listSpendingAllowance();
        listBudgets();
    }
    
    @IBAction func MenuTap(_ sender: Any) {
        animateMenu();
    }
    
    @IBAction func AddExpenseTap(_ sender: Any) {
        animateMenu();
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        output.textContainerInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0);
        
        // Make the navigation bar translucent
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.view.backgroundColor = .clear
        
        HeaderBg.setGradientBackground(colorOne: Colors.darkOrange, colorTwo: Colors.lightOragne);
        LeftBar.setGradientBackground(colorOne: Colors.darkOrange, colorTwo: Colors.middleOrange);
        loader.startAnimating();
        
        // Configure Google Sign-in.
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        GIDSignIn.sharedInstance().signInSilently()
        
        // Add the sign-in button.
        signInButton.center = self.view.center;
        view.addSubview(signInButton);
        if (GIDSignIn.sharedInstance().hasAuthInKeychain()) {
            self.signInButton.isHidden = true;
        }
    }
    
    func animateMenu() {
        if(self.LeftBar.frame.origin.x.isEqual(to: 0)){
            UIView.animate(withDuration: 0.2, delay:0, options: .curveEaseInOut, animations: {
                self.LeftBar.frame.origin.x -= CGFloat(self.leftBarWidth);
            });
        }
        else {
            UIView.animate(withDuration: 0.2, delay:0, options: .curveEaseInOut, animations: {
                self.LeftBar.frame.origin.x += CGFloat(self.leftBarWidth);
            });
        }
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
              withError error: Error!) {
        if let error = error {
            showAlert(title: "Authentication Error", message: error.localizedDescription)
            self.service.authorizer = nil
        } else {
            self.signInButton.isHidden = true;
            self.service.authorizer = user.authentication.fetcherAuthorizer()
            listSpendingAllowance();
            listBudgets();
        }
    }
    
    func listSpendingAllowance() {
        let spreadsheetId = "1fqEk4yeKqjJR6zQPGlu8ZYrOPx_Y7T8vp17hin3HaFY"
        let range = "Checking!J14"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displaySpendingAllowanceWithTicket(ticket:finishedWithObject:error:))
        )
    }
    
    // Process the response and display output
    func displaySpendingAllowanceWithTicket(ticket: GTLRServiceTicket,
                                        finishedWithObject result : GTLRSheets_ValueRange,
                                        error : NSError?) {
        
        loader.stopAnimating();
        loader.isHidden = true;
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        var majorsString = "";
        let rows = result.values!
        
        if rows.isEmpty {
            sa_output.text = "No data found."
            return
        }
        
        for row in rows {
            let budgetValue = row[0];
            let budgetValueString = String(describing: budgetValue);
            let budgetValueNum = Double(budgetValueString);
            
            if(budgetValueNum?.isLess(than: 0))!{
                sa_output.textColor = UIColor.red;
            }
        
            majorsString = budgetValueString;
        }
        
        sa_output.text = majorsString
    }
    
    // Display (in the UITextView) the names and majors of students in a sample
    // spreadsheet:
    // https://docs.google.com/spreadsheets/d/1BxiMVs0XRA5nFMdKvBdBZjgmUUqptlbs74OgvE2upms/edit
    func listBudgets() {
        let spreadsheetId = "1fqEk4yeKqjJR6zQPGlu8ZYrOPx_Y7T8vp17hin3HaFY"
        let range = "Checking!I4:J13"
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet
            .query(withSpreadsheetId: spreadsheetId, range:range)
        service.executeQuery(query,
                             delegate: self,
                             didFinish: #selector(displayBudgetResultsWithTicket(ticket:finishedWithObject:error:))
        )
    }
    
    // Process the response and display output
    func displayBudgetResultsWithTicket(ticket: GTLRServiceTicket,
                                 finishedWithObject result : GTLRSheets_ValueRange,
                                 error : NSError?) {
        
        loader.stopAnimating();
        loader.isHidden = true;
        
        if let error = error {
            showAlert(title: "Error", message: error.localizedDescription)
            return
        }
        
        var majorsString = ""
        let rows = result.values!
        
        if rows.isEmpty {
            output.text = "No data found."
            return
        }
        
        for row in rows {
            let name = row[0];
            let bugetValue = row[1];
            
            majorsString += "\(name) - \(bugetValue)\n\n"
        }
        
        output.text = majorsString
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
