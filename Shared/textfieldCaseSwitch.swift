//
//  textfieldCaseSwitch.swift
//  WordleSolver
//
//  Created by Gregory Li on 4/1/22.
//

import SwiftUI
import UIKit

class textfieldCaseSwitch: UIViewController, UITextFieldDelegate {

    @IBOutlet weak var someTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        someTextField.delegate = self
        someTextField.tag = 0
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
          // Try to find next responder
          if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
             nextField.becomeFirstResponder()
          } else {
             // Not found, so remove keyboard.
             textField.resignFirstResponder()
          }
          // Do not add a line break
          return false
       }

}
