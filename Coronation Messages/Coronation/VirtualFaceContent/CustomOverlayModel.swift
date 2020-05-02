//
//  CustomOverlayModel.swift
//  King Crown Extension
//
//  Created by Fabricio Oliveira on 2020-04-29.
//  Copyright © 2020 Fabricio Oliveira. All rights reserved.
//

import Foundation
import SceneKit
import ARKit

/// For forwarding `ARSCNViewDelegate` messages to the object controlling the currently visible virtual content.
protocol VirtualContentController: ARSCNViewDelegate {
    /// The root node for the virtual content.
    var contentNode: SCNNode? { get set }

    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode?

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor)
}


class CustomOverlayModel: SCNReferenceNode, VirtualFaceContent, VirtualContentController {

    var contentNode: SCNNode?
    var occlusionNode: SCNNode?
    private var nodeMesh: SCNNode?

    required init(dictionary: [String : Any]) {
        guard let resource = dictionary["resource"] as? String, let mesh = dictionary["mesh"] as? String , let scaleModel = dictionary["scale"] as? Float else {
            fatalError("missing expected bundle resource")
        }
        guard let url = Bundle.main.url(forResource: resource, withExtension: "scn", subdirectory: "Models.scnassets")
            else { fatalError("missing expected bundle resource") }
        super.init(url: url)!
        load()
        guard let childMesh = self.childNode(withName: mesh, recursively: true) else {
            fatalError("missing expected bundle resource")
        }
        nodeMesh = childMesh
        scale.x *= scaleModel
        scale.y *= scaleModel
        scale.z *= scaleModel
        nodeMesh?.morpher?.calculationMode = .normalized
        nodeMesh?.morpher?.unifiesNormals = true
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("\(#function) has not been implemented")
    }

    /// - Tag: OcclusionMaterial
    func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
        guard let sceneView = renderer as? ARSCNView,
            anchor is ARFaceAnchor else { return nil }
        #if targetEnvironment(simulator)
        #error("ARKit is not supported in iOS Simulator. Connect a physical iOS device and select it as your Xcode run destination, or select Generic iOS Device as a build-only destination.")
        #else
        guard let device = sceneView.device, let faceGeometry = ARSCNFaceGeometry(device: device, fillMesh: true) else {
            return contentNode
        }
        faceGeometry.firstMaterial?.colorBufferWriteMask = []
        occlusionNode = SCNNode(geometry: faceGeometry)
        contentNode = SCNNode()
        guard let occlusionNode = occlusionNode, let nodeMesh = nodeMesh else {
            return contentNode
        }
        occlusionNode.renderingOrder = -1
        contentNode?.addChildNode(occlusionNode)
        contentNode?.addChildNode(nodeMesh)
        #endif
        return contentNode
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceGeometry = occlusionNode?.geometry as? ARSCNFaceGeometry,
            let faceAnchor = anchor as? ARFaceAnchor
            else { return }
        
        faceGeometry.update(from: faceAnchor.geometry)
        update(withFaceAnchor: anchor as! ARFaceAnchor)
    }

    /// - Tag: ARFaceGeometryBlendShapes
    func update(withFaceAnchor faceAnchor: ARFaceAnchor) {
        guard let faceGeometry = occlusionNode?.geometry as? ARSCNFaceGeometry,  let contentNode = contentNode else {
            return
        }
        faceGeometry.update(from: faceAnchor.geometry)
        let max = faceGeometry.boundingBox.max
        let scalar: Float = 1.35
        occlusionNode?.scale = SCNVector3Make(1.15, 1.15, 1.15)
        nodeMesh?.scale = SCNVector3Make(max.z * scalar, max.z * scalar, max.z * scalar * 1.2)
        contentNode.position.y = faceGeometry.boundingSphere.radius * 0.96
        contentNode.position.z = -faceGeometry.boundingSphere.radius / 2
    }

}
