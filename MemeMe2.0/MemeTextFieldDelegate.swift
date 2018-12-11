//
//  MemeTextFieldDelegate.swift
//  MemeMe2.0
//
//  Created by John Berndt on 12/10/18.
//  Copyright © 2018 Siegersoft. All rights reserved.
//

import UIKit
import Foundation

class MemeTextFieldDelegate : NSObject, UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to:nil, from:nil, for:nil)
        return false
    }

}
