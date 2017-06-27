//
//  NeuralNetwork.swift
//  MnistNetwork
//
//  Created by Andy Best on 27/06/2017.
//  Copyright © 2017 Andy Best. All rights reserved.
//

import Foundation
import AppKit
import Quartz

extension Double {
    static func random(_ range: Range<Double>) -> Double {
        return Double(arc4random()) / Double(UINT32_MAX) * abs(range.lowerBound - range.upperBound) + min(range.lowerBound, range.upperBound)
    }
    
    func roundedTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

struct SigmoidActivation {
    static var sigmoid: [Double] = {
        return Array(0..<200).map {
            let x = (Double($0) / 20.0) - 5.0
            return 2.0 / (1.0 + exp(-2.0 * x)) - 1.0
        }
    }()
    
    static func lookup(_ x: Double) -> Double {
        let i = Int(floor((x + 5.0) * 20.0))
        return sigmoid[i < 0 ? 0 : i > 199 ? 199 : i]
    }
}

class Neuron {
    var inputs: [(Neuron, weight: Double)]
    var output: Double
    
    var error: Double = 0
    var learningRate: Double = 0.01
    
    init(output: Double) {
        inputs = [(Neuron, weight: Double)]()
        self.output = output
    }
    
    init(inputs: [Neuron]) {
        output = 0.0
        self.inputs = inputs.map { input -> (Neuron, weight: Double) in
            return (input, weight: Double.random(-1.0..<1.0))
        }
    }
    
    func setOutput(_ val: Double) {
        self.output = val
    }
    
    func setError(_ desiredValue: Double) {
        error = desiredValue - output
    }
    
    func train() {
        let delta = (1.0 - output) * (1.0 + output) * error * learningRate
        
        inputs = inputs.map {
            var (inputNeuron, weight) = $0
            inputNeuron.error += weight * error
            weight += inputNeuron.output * delta
            return (inputNeuron, weight: weight)
        }
    }
    
    func respond() {
        let sum = inputs.reduce(0.0) { result, input in
            let (inputNeuron, weight) = input
            return result + (inputNeuron.output * weight)
        }
        
        output = SigmoidActivation.lookup(sum)
    }
}

class Network {
    var inputLayer: [Neuron]
    var hiddenLayer: [Neuron]
    var outputLayer: [Neuron]
    
    var error: Double = 0
    
    var layers: [[Neuron]] {
        return [inputLayer, hiddenLayer, outputLayer]
    }
    
    init(numInputs: Int, numHidden: Int, numOutputs: Int) {
        inputLayer = [Neuron]()
        hiddenLayer = [Neuron]()
        outputLayer = [Neuron]()
        
        for _ in 0..<numInputs {
            inputLayer.append(Neuron(output: 0))
        }
        
        for _ in 0..<numHidden {
            hiddenLayer.append(Neuron(inputs: inputLayer))
        }
        
        for _ in 0..<numOutputs {
            outputLayer.append(Neuron(inputs: hiddenLayer))
        }
    }
    
    func respond(inputs: [Double]) {
        assert(inputs.count == inputLayer.count)
        
        for i in 0..<inputs.count {
            inputLayer[i].setOutput(inputs[i])
        }
        
        for neuron in hiddenLayer {
            neuron.respond()
        }
        
        for neuron in outputLayer {
            neuron.respond()
        }
    }
    
    func train(expectedOutputs: [Double]) {
        assert(expectedOutputs.count == outputLayer.count)
        
        for i in 0..<outputLayer.count {
            outputLayer[i].setError(expectedOutputs[i])
            outputLayer[i].train()
        }
        
        for neuron in hiddenLayer {
            neuron.train()
        }
    }
    
}

class NetworkVisualizerView: NSView {
    private var network: Network
    
    let neuronSize: CGFloat = 30
    let neuronSpacing: CGFloat = 10
    let layerSpacing: CGFloat = 100
    
    init(network: Network) {
        self.network = network
        super.init(frame: NSRect.zero)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func contentSize() -> CGSize {
        let numLayers = network.layers.count
        var maxLayerCount = 0
        
        for layer in network.layers {
            if layer.count > maxLayerCount {
                maxLayerCount = layer.count
            }
        }
        
        let width = (CGFloat(numLayers) * neuronSize) + (CGFloat(numLayers - 1) * layerSpacing)
        let height = (CGFloat(maxLayerCount) * neuronSize) + (CGFloat(maxLayerCount - 1) * neuronSpacing)
        
        return CGSize(width: width, height: height)
    }
    
    func drawLayer(_ layer: [Neuron], inContext ctx: CGContext) {
        ctx.saveGState()
        
        for neuron in layer {
            ctx.addEllipse(in: CGRect(x: 0, y: 0, width: neuronSize, height: neuronSize))
            ctx.strokePath()
            
            let output = String(neuron.output.roundedTo(places: 2)) as NSString
            let outputSize = output.size(withAttributes: nil)
            output.draw(at: NSPoint(x: (neuronSize / 2.0) - (outputSize.width / 2.0), y: (neuronSize / 2.0) - (outputSize.height / 2.0)), withAttributes: nil)
            
            ctx.translateBy(x: 0, y: neuronSize + neuronSpacing)
        }
        
        ctx.restoreGState()
    }
    
    override func draw(_ dirtyRect: NSRect) {
        let ctx = NSGraphicsContext.current!.cgContext
        
        ctx.saveGState()
        
        for layer in network.layers {
            drawLayer(layer, inContext: ctx)
            
            ctx.translateBy(x: layerSpacing, y: 0)
        }
        
        ctx.restoreGState()
        
    }
    
}
