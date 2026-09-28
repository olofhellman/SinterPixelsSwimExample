//
//  ViewController.swift
//  SinterPixelsBridge
//
//  Created by Olof Hellman on 7/12/26.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    func docName() -> String? {
        let textFieldContent = docNameTextField.stringValue
        guard textFieldContent.count > 0 else {
            return nil
        }
        return textFieldContent
    }
    
    @IBAction func makeDocument(_ sender: Any) {
        if let appDelegate = AppDelegate.shared {
            appDelegate.doMakeDocument(named: docName())
        }
    }
    
    @IBAction func makeGrid(_ sender: Any) {
        if let appDelegate = AppDelegate.shared {
            appDelegate.doMakeGrid(docName: docName())
        }
    }
    
    @IBOutlet weak var docNameTextField: NSTextField!
}

