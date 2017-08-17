//
//  Common.swift
//  T-Budget
//
//  Created by Tom Spaulding on 8/17/17.
//  Copyright © 2017 Tom Spaulding. All rights reserved.
//

import Foundation
import UIKit

class Common: NSObject {
    static func showLoader(Loader: UIActivityIndicatorView) {
        Loader.startAnimating();
        Loader.isHidden = false;
    }
    
    static func hideLoader(Loader: UIActivityIndicatorView) {
        Loader.stopAnimating();
        Loader.isHidden = true;
    }
    
    static func showAlert(title : String, message: String, controller: UIViewController) {
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
        controller.present(alert, animated: true, completion: nil)
    }
    
    static func dismissKeyboard(view: UIView){
        view.endEditing(true);
    }
    
    static func showSuccessNotif(SuccessNotif: UIView) {
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            SuccessNotif.alpha = 1;
            SuccessNotif.frame.origin.y -= SuccessNotif.frame.height;
        });
        
        //Auto hide the success notification
        let when = DispatchTime.now() + 2 // Wait 1 second
        DispatchQueue.main.asyncAfter(deadline: when) {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                SuccessNotif.alpha = 0;
                SuccessNotif.frame.origin.y += SuccessNotif.frame.height;
            });
        }
    }
    
}
