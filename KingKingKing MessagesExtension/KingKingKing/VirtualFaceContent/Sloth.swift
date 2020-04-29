/*
 See LICENSE folder for this sample’s licensing information.
 
 Abstract:
 The RobotHead node.
 */

import Foundation
import SceneKit
import ARKit

class Sloth: SCNReferenceNode, VirtualFaceContent {
    
    private var originalJawY: Float = 0
    
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
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "eyeBlink_LMesh" }) {
                morpher.setWeight(CGFloat(eyeBlinkLeft), forTargetAt: 0)
            //}
            
            //if let targetIndex =  morpher.targets.index(where: {$0.name == "eyeLookDown_LMesh" }) {
                morpher.setWeight(CGFloat(eyeLookDownLeft), forTargetAt: 1)
            //}
            
            //if let targetIndex =  morpher.targets.index(where: {$0.name == "eyeLookIn_LMesh" }) {
                morpher.setWeight(CGFloat(eyeLookInLeft), forTargetAt: 2)
            //}
            
            //if let targetIndex =  morpher.targets.index(where: {$0.name == "eyeLookOut_LMesh" }) {
                morpher.setWeight(CGFloat(eyeLookOutLeft), forTargetAt: 3)
            //}
            
            //if let targetIndex =  morpher.targets.index(where: {$0.name == "eyeLookUp_LMesh" }) {
                morpher.setWeight(CGFloat(eyeLookUpLeft), forTargetAt: 4)
           // }
            
            
            //if let targetIndex =  morpher.targets.index(where: {$0.name == "eyeSquint_LMesh" }) {
                morpher.setWeight(CGFloat(eyeSquintLeft), forTargetAt: 5)
            //}
            
            //if let targetIndex =  morpher.targets.index(where: {$0.name == "eyeWide_LMesh" }) {
                morpher.setWeight(CGFloat(eyeWideLeft), forTargetAt: 6)
           // }
            
         
            
            //RIGHT EYE

            //if let targetIndex =  morpher.targets.index(where: {$0.name == "eyeBlink_RMesh" }) {
                morpher.setWeight(CGFloat(eyeBlinkRight), forTargetAt: 7)
            //}
            
            //if let targetIndex =  morpher.targets.index(where: {$0.name == "eyeLookDown_RMesh" }) {
                morpher.setWeight(CGFloat(eyeLookDownRight), forTargetAt: 8)
            //}
            
           // if let targetIndex =  morpher.targets.index(where: {$0.name == "eyeLookIn_RMesh" }) {
                morpher.setWeight(CGFloat(eyeLookInRight), forTargetAt: 9)
            //}
            
            //if let targetIndex =  morpher.targets.index(where: {$0.name == "eyeLookOut_RMesh" }) {
                morpher.setWeight(CGFloat(eyeLookOutRight), forTargetAt: 10)
           // }
            
          //  if let targetIndex =  morpher.targets.index(where: {$0.name == "eyeLookUp_RMesh" }) {
                morpher.setWeight(CGFloat(eyeLookUpRight), forTargetAt: 11)
           // }
            
           // if let targetIndex =  morpher.targets.index(where: {$0.name == "eyeSquint_RMesh" }) {
               // morpher.setWeight(CGFloat(eyeSquintRight), forTargetAt: targetIndex)
            //}
            
            //if let targetIndex =  morpher.targets.index(where: {$0.name == "eyeWide_RMesh" }) {
                morpher.setWeight(CGFloat(eyeWideRight), forTargetAt: 12)
            //}
          
            //JAW
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "jawForwardMesh" }) {
                morpher.setWeight(CGFloat(jawForward), forTargetAt: 13)
           // }
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "jawLeftMesh" }) {
                morpher.setWeight(CGFloat(jawLeft), forTargetAt: 14)
            //}
            
           // if let targetIndex = morpher.targets.index(where: {$0.name == "jawOpenMesh" }) {
                morpher.setWeight(CGFloat(jawOpen), forTargetAt: 15)
            //}
            
           // if let targetIndex = morpher.targets.index(where: {$0.name == "jawRightMesh" }) {
                morpher.setWeight(CGFloat(jawRight), forTargetAt: 16)
           // }
            
    
            //MOUTH
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthPuckerMesh" }) {
                morpher.setWeight(CGFloat(mouthPucker), forTargetAt: 17)
            //}
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthFunnelMesh" }) {
                morpher.setWeight(CGFloat(mouthFunnel), forTargetAt: 18)
            //}
            
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthCloseMesh" }) {
                morpher.setWeight(CGFloat(mouthClose), forTargetAt: 19)
            //}
            
            // if let targetIndex = morpher.targets.index(where: {$0.name == "mouthSmile_RMesh" }) {
            morpher.setWeight(CGFloat(mouthSmileRight), forTargetAt: 20)
            //}
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthLeftMesh" }) {
                morpher.setWeight(CGFloat(mouthLeft), forTargetAt: 21)
            //}
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthRightMesh" }) {
                morpher.setWeight(CGFloat(mouthRight), forTargetAt: 22)
            //}
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthSmile_LMesh" }) {
            morpher.setWeight(CGFloat(mouthSmileLeft), forTargetAt: 23)
            //}
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthFrown_RMesh" }) {
            morpher.setWeight(CGFloat(mouthFrownRight), forTargetAt: 24)
            //}
            
            
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthFrown_LMesh" }) {
            morpher.setWeight(CGFloat(mouthFrownLeft), forTargetAt: 25)
            //}
          
           
            
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthDimple_LMesh" }) {
                morpher.setWeight(CGFloat(mouthDimpleLeft), forTargetAt: 26)
            //}
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthDimple_RMesh" }) {
                morpher.setWeight(CGFloat(mouthDimpleRight), forTargetAt: 27)
            //}
            
            
            // if let targetIndex = morpher.targets.index(where: {$0.name == "mouthStretch_RMesh" }) {
            morpher.setWeight(CGFloat(mouthStretchRight), forTargetAt: 28)
            // }
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthStretch_LMesh" }) {
            morpher.setWeight(CGFloat(mouthStretchLeft), forTargetAt: 29)
            //}
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthRollUpperMesh" }) {
            morpher.setWeight(CGFloat(mouthRollUpper), forTargetAt: 30)
            //}
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthRollLowerMesh" }) {
            morpher.setWeight(CGFloat(mouthRollLower), forTargetAt: 31)
            // }
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthShrugUpperMesh" }) {
            morpher.setWeight(CGFloat(mouthShrugUpper), forTargetAt: 32)
            //}
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthShrugLowerMesh" }) {
            morpher.setWeight(CGFloat(mouthShrugLower), forTargetAt: 33)
            //}
            
            
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthPress_LMesh" }) {
            morpher.setWeight(CGFloat(mouthPressLeft), forTargetAt: 34)
            //}
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthPress_RMesh" }) {
            morpher.setWeight(CGFloat(mouthPressRight), forTargetAt: 35)
            //}
            
            
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthLowerDown_LMesh" }) {
            morpher.setWeight(CGFloat(mouthLowerDownLeft), forTargetAt: 36)
            //}
            
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthLowerDown_RMesh" }) {
            morpher.setWeight(CGFloat(mouthLowerDownRight), forTargetAt: 37)
            //}
            
            
            
            
        
            //if let targetIndex = morpher.targets.index(where: {$0.name == "mouthUpperUp_RMesh" }) {
            morpher.setWeight(CGFloat(mouthUpperUpRight), forTargetAt: 38)
            //}
            
            
           // if let targetIndex = morpher.targets.index(where: {$0.name == "mouthUpperUp_LMesh" }) {
                morpher.setWeight(CGFloat(mouthUpperUpLeft), forTargetAt: 39)
            //}
            
            
            
          
            //BROWN
           
            //if let targetIndex =  morpher.targets.index(where: {$0.name == "browDown_LMesh" }) {
            morpher.setWeight(CGFloat(browDownLeft), forTargetAt: 40)
            //}
            
            //if let targetIndex =  morpher.targets.index(where: {$0.name == "browDown_RMesh" }) {
            morpher.setWeight(CGFloat(browDownRight), forTargetAt: 41)
            //}
            
            //if let targetIndex =  morpher.targets.index(where: {$0.name == "browInnerUpMesh" }) {
            morpher.setWeight(CGFloat(browInnerUp), forTargetAt: 42)
            // }
            
            //if let targetIndex =  morpher.targets.index(where: {$0.name == "browOuterUp_RMesh" }) {
            morpher.setWeight(CGFloat(browOuterUpRight), forTargetAt: 43)
            //}
            
            //if let targetIndex =  morpher.targets.index(where: {$0.name == "browOuterUp_LMesh" }) {
            morpher.setWeight(CGFloat(browOuterUpLeft), forTargetAt: 44)
            //}
          
            
           
            
          
            
            

            //CHEEK
            
            //if let targetIndex = morpher.targets.index(where: {$0.name == "cheekPuffMesh" }) {
                morpher.setWeight(CGFloat(cheekPuff), forTargetAt: 45)
            //
          
            //if let targetIndex =  morpher.targets.index(where: {$0.name == "cheekSquint_LMesh" }) {
                morpher.setWeight(CGFloat(cheekSquintLeft), forTargetAt: 46)
            //}
            
            //if let targetIndex =  morpher.targets.index(where: {$0.name == "cheekSquint_RMesh" }) {
                morpher.setWeight(CGFloat(cheekSquintRight), forTargetAt: 47)
            //}
            

            //NOSE
            
            //if let targetIndex =  morpher.targets.index(where: {$0.name == "noseSneer_LMesh" }) {
                morpher.setWeight(CGFloat(noseLeft), forTargetAt: 48)
            //}
            
            //if let targetIndex =  morpher.targets.index(where: {$0.name == "noseSneer_RMesh" }) {
                morpher.setWeight(CGFloat(noseRight), forTargetAt: 49)
            //}
            
            
        }

        
    }
    
    /// - Tag: ARFaceGeometryBlendShapes
    func update(withFaceAnchor faceAnchor: ARFaceAnchor) {
        blendShapes = faceAnchor.blendShapes
    }
    
}
