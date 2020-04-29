//
//  ModelFactory.swift
//  ArKitImessage
//
//  Created by Fabricio Oliveira on 14/03/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import UIKit
import ARKit
import Foundation

class ModelFactory: NSObject {
    lazy var nodeForContentType = [VirtualContentType : VirtualFaceContent.Type]()
    lazy var dictionaryForContent = [VirtualContentType : [String: Any]]()

    override init() {
        super.init()
    }
    
    func createFaceGeometry() {
        nodeForContentType[.crown] = CustomOverlayModel.self
        nodeForContentType[.cashmeoutside] = CustomModel.self
        nodeForContentType[.postMalone] = CustomModel.self
        dictionaryForContent[.crown] = ["resource": "crown", "mesh": "crown", "scale": 0.038 as Float] as [String: Any]
        dictionaryForContent[.cashmeoutside] = ["resource": "catchmeoutside", "mesh": "catchmeoutside", "scale": 0.04 as Float] as [String: Any]
        dictionaryForContent[.postMalone] = ["resource": "postmalone", "mesh": "postmalone", "scale": 0.006 as Float] as [String: Any]
    }

    func getModel(type: VirtualContentType) -> VirtualFaceNode? {
        guard let model = nodeForContentType[type] else {
            return nil
        }
        guard let dictionary = dictionaryForContent[type] else {
            return nil
        }
        return model.init(dictionary: dictionary) as? VirtualFaceNode
    }
    
}
