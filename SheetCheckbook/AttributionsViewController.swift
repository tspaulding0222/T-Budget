//
//  AttributionsViewController.swift
//  T-Budget
//
//  Created by Tom Spaulding on 7/27/17.
//  Copyright © 2017 Tom Spaulding. All rights reserved.
//

import UIKit

class AttributionsViewController: UIViewController {
    
    @IBOutlet var HeaderBg: UIView!
    
    @IBAction func icons9Tap(_ sender: Any) {
        let icons8Url = NSURL(string: "https://icons8.com/")! as URL
        UIApplication.shared.open(icons8Url, options: [:], completionHandler: nil)
    }
    
    @IBAction func GoogleApiTap(_ sender: Any) {
        let googleUrl = NSURL(string: "https://developers.google.com/sheets/api/")! as URL
        UIApplication.shared.open(googleUrl, options: [:], completionHandler: nil)
    }

    @IBAction func stickypodPickerTap(_ sender: Any) {
        let googleUrl = NSURL(string: "https://github.com/hsylife/SwiftyPickerPopover")! as URL
        UIApplication.shared.open(googleUrl, options: [:], completionHandler: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        HeaderBg.setGradientBackground(colorOne: Colors.darkOrange, colorTwo: Colors.lightOragne);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
