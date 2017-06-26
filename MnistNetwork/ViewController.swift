//
//  ViewController.swift
//  MnistNetwork
//
//  Created by Andy Best on 24/06/2017.
//  Copyright © 2017 Andy Best. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        do {
            let mnistData = try loadMNISTData()
            print(mnistData)
        } catch {
            print(error)
        }
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

