//
//  ViewController.swift
//  PassCodeView
//
//  Created by Jagtap, Amol on 11/16/16.
//  Copyright © 2016 Amol Jagtap. All rights reserved.
//

import UIKit

class ViewController: UIViewController, PasscodeViewDelegate {
    
//    @IBOutlet weak var passcodeView: PasscodeView!
    
    @IBOutlet weak var passcodeView: PasscodeView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        passcodeView.delegate = self
        print("Passcode \(passcodeView.text)")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        passcodeView.becomeFirstResponder()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    func passcodeView(view: PasscodeView, didPressedKey text: String) {
        print("input text:\(text)")
    }
    
}


