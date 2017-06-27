//
//  AppDelegate.swift
//  MnistNetwork
//
//  Created by Andy Best on 24/06/2017.
//  Copyright © 2017 Andy Best. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    public lazy var mnistData: MNISTData = {
        do {
            return try loadMNISTData()
        } catch {
            fatalError("Could not load MNIST Data")
        }
    }()
    
    var mnistSetWindowController: MNISTSetWindowController?

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        mnistSetWindowController = MNISTSetWindowController()
        mnistSetWindowController?.showWindow(self)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

