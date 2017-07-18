//
//  TomUITextView.swift
//  T-Budget
//
//  Created by Tom Spaulding on 7/18/17.
//  Copyright © 2017 Tom Spaulding. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable class UITextViewFixed: UITextView {
    override func layoutSubviews() {
        super.layoutSubviews()
        setup()
    }
    func setup() {
        textContainerInset = UIEdgeInsets.zero
        textContainer.lineFragmentPadding = 0
    }
}
