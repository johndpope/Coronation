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
        nodeForContentType[.crown2] = CustomOverlayModel.self
        dictionaryForContent[.crown] = ["resource": "crown", "mesh": "crown", "scale": 1 as Float] as [String: Any]
        dictionaryForContent[.crown2] = ["resource": "crown2", "mesh": "crown2", "scale": 1 as Float] as [String: Any]
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
