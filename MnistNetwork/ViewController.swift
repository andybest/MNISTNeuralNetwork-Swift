//
//  ViewController.swift
//  MnistNetwork
//
//  Created by Andy Best on 24/06/2017.
//  Copyright © 2017 Andy Best. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {
    
    @IBOutlet weak var scrollView: NSScrollView?
    var network: Network?
    var currentTrainingImage: Int = 0
    var visualizer: NetworkVisualizerView?
    var timer: Timer?
    
    override var acceptsFirstResponder: Bool {
        return true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        network = Network(numInputs: 784, numHidden: 196, numOutputs: 10)
        visualizer = NetworkVisualizerView(network: network!)
        let visualizerSize = visualizer!.contentSize()
        visualizer?.frame = NSRect(x: 0, y: 0, width: visualizerSize.width, height: visualizerSize.height)
        scrollView?.documentView = visualizer!
        
        /*timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { timer in
            self.timerFired()
        })*/
        
        doTraining()
    }
    
    func trainNetwork(_ times: Int = 1) {
        var label: Int = 0
        for _ in 0..<times {
            let appDelegate = (NSApplication.shared.delegate) as! AppDelegate
            
            let trainingImage = appDelegate.mnistData.trainingImages[Int(arc4random()) % appDelegate.mnistData.trainingImages.count]
            label = trainingImage.label
            
            let pixels = trainingImage.pixels.map { Double($0) / 255.0 }
            
            network?.respond(inputs: pixels)
            
            var expectedOutput = [Double](repeating: -1.0, count: 10)
            expectedOutput[trainingImage.label] = 1.0
            
            network?.train(expectedOutputs: expectedOutput)
        }
        
        var highestIdx = -1
        var highestVal = -1.0
        
        for i in 0..<network!.outputLayer.count {
            let neuron = network!.outputLayer[i]
            
            if neuron.output > highestVal {
                highestIdx = i
                highestVal = neuron.output
            }
        }
        
        print(label, highestIdx, highestVal, network!.outputLayer.map { $0.error.roundedTo(places: 2) })
    }
    
    /*override func mouseDown(with event: NSEvent) {
        trainNetwork(10)
        visualizer?.setNeedsDisplay(visualizer!.bounds)
    }
    
    override func rightMouseDown(with event: NSEvent) {
        DispatchQueue.global(qos: .default).async {
            self.trainNetwork(500)
            DispatchQueue.main.async {
                self.visualizer?.setNeedsDisplay(self.visualizer!.bounds)
            }
        }
    }*/
    
    func doTraining() {
        DispatchQueue.global(qos: .default).async {
            while true {
                self.trainNetwork(500)
                DispatchQueue.main.sync {
                    self.visualizer?.setNeedsDisplay(self.visualizer!.bounds)
                }
            }
        }
        
    }
    
    override func keyDown(with event: NSEvent) {
        
    }
    
    

    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }


}

