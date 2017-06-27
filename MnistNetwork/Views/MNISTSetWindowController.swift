//
//  MNISTSetWindowController.swift
//  MnistNetwork
//
//  Created by Andy Best on 27/06/2017.
//  Copyright © 2017 Andy Best. All rights reserved.
//

import Foundation
import AppKit

class MNISTSetWindowController: NSWindowController, NSTableViewDelegate, NSTableViewDataSource {
    
    @IBOutlet weak var segmentControl: NSSegmentedControl?
    @IBOutlet weak var tableView: NSTableView?
    
    @IBOutlet weak var setImage: NSImageView?
    @IBOutlet weak var setLabel: NSTextField?
    
    convenience init() {
        self.init(windowNibName: NSNib.Name("MNISTSetWindow"))
    }
    
    override func windowDidLoad() {
        super.windowDidLoad()
        
        tableView?.delegate = self
        tableView?.dataSource = self
    }
    
    func currentMNISTSet() -> [MNISTImage] {
        let appDelegate: AppDelegate = NSApplication.shared.delegate as! AppDelegate
        let mnistData = appDelegate.mnistData
        
        if segmentControl?.selectedSegment == 0 {
            return mnistData.trainingImages
        } else {
            return mnistData.testImages
        }
    }
    
    @IBAction func segmentedControlChangedValue(sender: AnyObject) {
        tableView?.reloadData()
    }
    
    // MARK: NSTableViewDataSource, NSTableViewDelegate
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return currentMNISTSet().count
    }
    
    func tableView(_ tableView: NSTableView, objectValueFor tableColumn: NSTableColumn?, row: Int) -> Any? {
        let image = currentMNISTSet()[row]
        return image.imgId
    }
    
    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView!.selectedRow >= currentMNISTSet().count || tableView!.selectedRow < 0 {
            return
        }
        
        let image = currentMNISTSet()[tableView?.selectedRow ?? 0]
        setLabel?.stringValue = "Image label: \(image.label)"
        setImage?.image = imageFromMNISTImage(image)
    }
}
