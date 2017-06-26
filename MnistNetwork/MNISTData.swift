//
//  MNISTData.swift
//  MnistNetwork
//
//  Created by Andy Best on 24/06/2017.
//  Copyright © 2017 Andy Best. All rights reserved.
//

import Foundation

enum MNISTDataError: Error {
    case invalidMagicNumber
    case mismatchingLabelsAndImages
}

enum MNISTFiles: String {
    case trainingImages = "train-images.idx3-ubyte"
    case trainingLabels = "train-labels.idx1-ubyte"
    case testSetImages = "t10k-images.idx3-ubyte"
    case testSetLabels = "t10k-labels.idx1-ubyte"
}

struct MNISTImage {
    let label: Int
    let pixels: [UInt8]
    let size: (width: Int, height: Int)
    let imgId: String
}

struct MNISTData {
    let trainingImages: [MNISTImage]
    let testImages: [MNISTImage]
}

func loadMNISTData() throws -> MNISTData {
    let trainingSet: (MNISTFiles, MNISTFiles) = (.trainingImages, .trainingLabels)
    let testSet: (MNISTFiles, MNISTFiles) = (.testSetImages, .testSetLabels)
    
    let mnistData = MNISTData(trainingImages: try loadMNISTImageSet(imageFile: trainingSet.0, labelFile: trainingSet.1),
                              testImages: try loadMNISTImageSet(imageFile: testSet.0, labelFile: testSet.1))
    return mnistData
}

func loadMNISTImageSet(imageFile: MNISTFiles, labelFile: MNISTFiles) throws -> [MNISTImage] {
    let expectedMNumbers:
        [MNISTFiles: UInt32] = [
            .trainingImages: 0x00000803,
            .trainingLabels: 0x00000801,
            .testSetImages:  0x00000803,
            .testSetLabels:  0x00000801
    ]
    
    var data = try Data(contentsOf: URL(fileURLWithPath: Bundle.main.resourcePath! + "/" + imageFile.rawValue))
    
    // Swift compiler can't seem to handle all of this done on one line
    var magicNumber = (UInt32(data[0]) << 24) | (UInt32(data[1]) << 16)
    magicNumber |= (UInt32(data[2]) << 8) | UInt32(data[3])
    
    if magicNumber != expectedMNumbers[imageFile] {
        throw MNISTDataError.invalidMagicNumber
    }
    
    var numImages = (UInt32(data[4]) << 24) | (UInt32(data[5]) << 16)
    numImages |= (UInt32(data[6]) << 8) | UInt32(data[7])
    
    var imgHeight = (UInt32(data[8]) << 24) | (UInt32(data[9]) << 16)
    imgHeight |= (UInt32(data[10]) << 8) | UInt32(data[11])
    
    var imgWidth = (UInt32(data[12]) << 24) | (UInt32(data[13]) << 16)
    imgWidth |= (UInt32(data[14]) << 8) | UInt32(data[15])
    
    var dataIdx = data.index(data.startIndex, offsetBy:16)
    var imagePixels = [[UInt8]]()
    
    while dataIdx < data.count {
        let pixels = data.subdata(in: dataIdx..<(data.index(dataIdx, offsetBy: Int(imgWidth * imgHeight))))
        imagePixels.append([UInt8](pixels))
        dataIdx = data.index(dataIdx, offsetBy: Int(imgWidth * imgHeight))
    }
    
    // Get Labels
    data = try Data(contentsOf: URL(fileURLWithPath: Bundle.main.resourcePath! + "/" + labelFile.rawValue))
    magicNumber = (UInt32(data[0]) << 24) | (UInt32(data[1]) << 16)
    magicNumber |= (UInt32(data[2]) << 8) | UInt32(data[3])
    
    if magicNumber != expectedMNumbers[labelFile] {
        throw MNISTDataError.invalidMagicNumber
    }
    
    var numLabels = (UInt32(data[4]) << 24) | (UInt32(data[5]) << 16)
    numLabels |= (UInt32(data[6]) << 8) | UInt32(data[7])
    
    if numLabels != numImages {
        throw MNISTDataError.mismatchingLabelsAndImages
    }
    
    let labels = data.map {
        Int($0)
    }
    
    var images = [MNISTImage]()
    
    for i in 0..<Int(numImages) {
        images.append(MNISTImage(label: labels[i],
                                 pixels: imagePixels[i],
                                 size: (width: Int(imgWidth), height: Int(imgHeight)),
                                imgId: "\(String(describing: imageFile))_\(i)"))
    }
    
    return images
}
