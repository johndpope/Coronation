//
//  Kodak.swift
//  ARKitFaceExample
//
//  Created by Fabricio Oliveira on 2/1/18.
//  Copyright © 2018 Apple. All rights reserved.
//

/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 The RobotHead node.
 */

import Foundation
import SceneKit
import ARKit

class CustomModel: SCNReferenceNode, VirtualFaceContent {
    
    private var nodeMesh: SCNNode?
    
    required init(dictionary: [String : Any]) {
        
        guard let resource = dictionary["resource"] as? String, let mesh = dictionary["mesh"] as? String , let scaleModel = dictionary["scale"] as? Float else {
            fatalError("missing expected bundle resource")
        }
        guard let url = Bundle.main.url(forResource: resource, withExtension: "scn", subdirectory: "Models.scnassets")
            else { fatalError("missing expected bundle resource") }
        super.init(url: url)!
        self.load()
        guard let childMesh = self.childNode(withName: mesh, recursively: true) else {
            fatalError("missing expected bundle resource")
        }
        self.nodeMesh = childMesh
        self.scale.x *= scaleModel
        self.scale.y *= scaleModel
        self.scale.z *= scaleModel
        self.nodeMesh?.morpher?.calculationMode = .normalized
        self.nodeMesh?.morpher?.unifiesNormals = true
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }
    
    /// - Tag: BlendShapeAnimation
    var blendShapes: [ARFaceAnchor.BlendShapeLocation: Any] = [:] {
        didSet {
            guard let eyeBlinkLeft = blendShapes[.eyeBlinkLeft] as? Float,
                let eyeSquintLeft = blendShapes[.eyeSquintLeft] as? Float,
                let eyeWideLeft = blendShapes[.eyeWideLeft] as? Float,
                let eyeLookDownLeft = blendShapes[.eyeLookDownLeft] as? Float,
                let eyeLookInLeft = blendShapes[.eyeLookInLeft] as? Float,
                let eyeLookOutLeft = blendShapes[.eyeLookOutLeft] as? Float,
                let eyeLookUpLeft = blendShapes[.eyeLookUpLeft] as? Float,
                
                let eyeWideRight = blendShapes[.eyeWideRight] as? Float,
                let eyeBlinkRight = blendShapes[.eyeBlinkRight] as? Float,
                let eyeSquintRight = blendShapes[.eyeSquintRight] as? Float,
                let eyeLookDownRight = blendShapes[.eyeLookDownRight] as? Float,
                let eyeLookInRight = blendShapes[.eyeLookInRight] as? Float,
                let eyeLookOutRight = blendShapes[.eyeLookOutRight] as? Float,
                let eyeLookUpRight = blendShapes[.eyeLookUpRight] as? Float,
            
                let jawOpen = blendShapes[.jawOpen] as? Float,
                let jawRight = blendShapes[.jawRight] as? Float,
                let jawLeft = blendShapes[.jawLeft] as? Float,
                let jawForward = blendShapes[.jawForward] as? Float,
                
                let mouthClose = blendShapes[.mouthClose] as? Float,
                let mouthFunnel = blendShapes[.mouthFunnel] as? Float,
                let mouthLeft = blendShapes[.mouthLeft] as? Float,
                let mouthRight = blendShapes[.mouthRight] as? Float,
                let mouthPucker = blendShapes[.mouthPucker] as? Float,
                let mouthFrownLeft = blendShapes[.mouthFrownLeft] as? Float,
                let mouthPressLeft = blendShapes[.mouthPressLeft] as? Float,
                let mouthPressRight = blendShapes[.mouthPressRight] as? Float,
                let mouthRollLower = blendShapes[.mouthRollLower] as? Float,
                let mouthRollUpper = blendShapes[.mouthRollUpper] as? Float,
                let mouthSmileLeft = blendShapes[.mouthSmileLeft] as? Float,
                let mouthSmileRight = blendShapes[.mouthSmileRight] as? Float,
                let mouthShrugLower = blendShapes[.mouthShrugLower] as? Float,
                let mouthShrugUpper = blendShapes[.mouthShrugUpper] as? Float,
                let mouthLowerDownLeft = blendShapes[.mouthLowerDownLeft] as? Float,
                let mouthLowerDownRight = blendShapes[.mouthLowerDownRight] as? Float,
                let mouthFrownRight = blendShapes[.mouthFrownRight] as? Float,
                let mouthDimpleLeft = blendShapes[.mouthDimpleLeft] as? Float,
                let mouthDimpleRight = blendShapes[.mouthDimpleRight] as? Float,
                let mouthStretchLeft = blendShapes[.mouthStretchLeft] as? Float,
                let mouthStretchRight = blendShapes[.mouthStretchRight] as? Float,
                let mouthUpperUpLeft = blendShapes[.mouthUpperUpLeft] as? Float,
                let mouthUpperUpRight = blendShapes[.mouthUpperUpRight] as? Float,
                
                let browDownLeft = blendShapes[.browDownLeft] as? Float,
                let browDownRight = blendShapes[.browDownRight] as? Float,
                let browInnerUp = blendShapes[.browInnerUp] as? Float,
                let browOuterUpLeft = blendShapes[.browOuterUpLeft] as? Float,
                let browOuterUpRight = blendShapes[.browOuterUpRight] as? Float,
                
                let cheekPuff = blendShapes[.cheekPuff] as? Float,
                let cheekSquintLeft = blendShapes[.cheekSquintLeft] as? Float,
                let cheekSquintRight = blendShapes[.cheekSquintRight] as? Float,
                
                let noseLeft = blendShapes[.noseSneerLeft] as? Float,
                let noseRight = blendShapes[.noseSneerRight] as? Float
                
                else { return }
            
            guard let morpher = self.nodeMesh?.morpher else {
                return
            }

            
            //LEFT EYE
            morpher.setWeight(CGFloat(eyeBlinkLeft), forTargetAt: 0)
            morpher.setWeight(CGFloat(eyeLookDownLeft), forTargetAt: 1)
            morpher.setWeight(CGFloat(eyeLookInLeft), forTargetAt: 2)
            morpher.setWeight(CGFloat(eyeLookOutLeft), forTargetAt: 3)
            morpher.setWeight(CGFloat(eyeLookUpLeft), forTargetAt: 4)
            morpher.setWeight(CGFloat(eyeSquintLeft), forTargetAt: 5)
            morpher.setWeight(CGFloat(eyeWideLeft), forTargetAt: 6)
            
            //RIGHT EYE
            morpher.setWeight(CGFloat(eyeBlinkRight), forTargetAt: 7)
            morpher.setWeight(CGFloat(eyeLookDownRight), forTargetAt: 8)
            morpher.setWeight(CGFloat(eyeLookInRight), forTargetAt: 9)
            morpher.setWeight(CGFloat(eyeLookOutRight), forTargetAt: 10)
            morpher.setWeight(CGFloat(eyeLookUpRight), forTargetAt: 11)
            morpher.setWeight(CGFloat(eyeSquintRight), forTargetAt: 12)
            morpher.setWeight(CGFloat(eyeWideRight), forTargetAt: 13)
            
            //JAW
            morpher.setWeight(CGFloat(jawForward), forTargetAt: 14)
            morpher.setWeight(CGFloat(jawLeft), forTargetAt: 15)
            morpher.setWeight(CGFloat(jawRight), forTargetAt: 16)
            
            
            morpher.setWeight(CGFloat(jawOpen), forTargetAt: 17)
    
          
            //MOUTH
            morpher.setWeight(CGFloat(mouthClose), forTargetAt: 18)
            morpher.setWeight(CGFloat(mouthFunnel), forTargetAt: 19)
            
            morpher.setWeight(CGFloat(mouthPucker), forTargetAt: 20)
            morpher.setWeight(CGFloat(mouthLeft), forTargetAt: 21)
            morpher.setWeight(CGFloat(mouthRight), forTargetAt: 22)
            morpher.setWeight(CGFloat(mouthSmileLeft), forTargetAt: 23)
            morpher.setWeight(CGFloat(mouthSmileRight), forTargetAt: 24)

            morpher.setWeight(CGFloat(mouthFrownLeft), forTargetAt: 25)
            morpher.setWeight(CGFloat(mouthFrownRight), forTargetAt: 26)

            morpher.setWeight(CGFloat(mouthDimpleLeft), forTargetAt: 27)

            morpher.setWeight(CGFloat(mouthDimpleRight), forTargetAt: 28)

            morpher.setWeight(CGFloat(mouthStretchLeft), forTargetAt: 29)
            morpher.setWeight(CGFloat(mouthStretchRight), forTargetAt: 30)

            morpher.setWeight(CGFloat(mouthRollLower), forTargetAt: 31)
            morpher.setWeight(CGFloat(mouthRollUpper), forTargetAt: 32)
            morpher.setWeight(CGFloat(mouthShrugLower), forTargetAt: 33)
            morpher.setWeight(CGFloat(mouthShrugUpper), forTargetAt: 34)

            morpher.setWeight(CGFloat(mouthPressLeft), forTargetAt: 35)

            morpher.setWeight(CGFloat(mouthPressRight), forTargetAt: 36)

            morpher.setWeight(CGFloat(mouthLowerDownLeft), forTargetAt: 37)
            morpher.setWeight(CGFloat(mouthLowerDownRight), forTargetAt: 38)
            morpher.setWeight(CGFloat(mouthUpperUpLeft), forTargetAt: 39)
            morpher.setWeight(CGFloat(mouthUpperUpRight), forTargetAt: 40)
          
            //BROWN
            

            morpher.setWeight(CGFloat(browDownLeft), forTargetAt: 41)
            morpher.setWeight(CGFloat(browDownRight), forTargetAt: 42)
            morpher.setWeight(CGFloat(browInnerUp), forTargetAt: 43)
            morpher.setWeight(CGFloat(browOuterUpLeft), forTargetAt: 44)
            morpher.setWeight(CGFloat(browOuterUpRight), forTargetAt: 45)
           
            //CHEEK
            morpher.setWeight(CGFloat(cheekPuff), forTargetAt: 46)
            morpher.setWeight(CGFloat(cheekSquintLeft), forTargetAt: 47)
            morpher.setWeight(CGFloat(cheekSquintRight), forTargetAt: 48)
           
            //NOSE
            morpher.setWeight(CGFloat(noseLeft), forTargetAt: 49)
            morpher.setWeight(CGFloat(noseRight), forTargetAt: 50)
          
        }
        
        
    }
    
    /// - Tag: ARFaceGeometryBlendShapes
    func update(withFaceAnchor faceAnchor: ARFaceAnchor) {
        blendShapes = faceAnchor.blendShapes
    }
    
}


extension BinaryFloatingPoint {
    public func rounded4(toPlaces places: Int) -> Self {
        guard places >= 0 else { return self }
        let divisor = Self((0..<places).reduce(1.0) { (accum, _) in 10.0 * accum })
        return (self * divisor).rounded() / divisor
    }
}
