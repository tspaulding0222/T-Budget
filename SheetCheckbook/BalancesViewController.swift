//
//  BalancesViewController.swift
//  T-Budget
//
//  Created by Tom Spaulding on 7/27/17.
//  Copyright © 2017 Tom Spaulding. All rights reserved.
//

import UIKit

class BalancesViewController: UIViewController {

    @IBOutlet var HeaderBf: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HeaderBf.setGradientBackground(colorOne: Colors.darkOrange, colorTwo: Colors.lightOragne);

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}
