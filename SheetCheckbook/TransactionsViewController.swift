//
//  TransactionsViewController.swift
//  T-Budget
//
//  Created by Tom Spaulding on 7/27/17.
//  Copyright © 2017 Tom Spaulding. All rights reserved.
//

import UIKit

class TransactionsViewController: UIViewController {
    
    @IBOutlet var HeaderBg: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HeaderBg.setGradientBackground(colorOne: Colors.darkOrange, colorTwo: Colors.lightOragne);
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
