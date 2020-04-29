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

    required init(dictionary: [String : Any]) {

        guard let resource = dictionary["resource"] as? String, let scaleModel = dictionary["scale"] as? Float else {
            fatalError("missing expected bundle resource")
        }
        guard let url = Bundle.main.url(forResource: resource, withExtension: "scn", subdirectory: "Models.scnassets")
            else { fatalError("missing expected bundle resource") }
        super.init(url: url)!
        load()
        scale.x *= scaleModel
        scale.y *= scaleModel
        scale.z *= scaleModel
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
        guard let occlusionNode = occlusionNode else {
            return contentNode
        }
        occlusionNode.renderingOrder = -1
        contentNode?.addChildNode(occlusionNode)
        contentNode?.addChildNode(self)
        #endif
        return contentNode
    }

    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceGeometry = occlusionNode?.geometry as? ARSCNFaceGeometry,
            let faceAnchor = anchor as? ARFaceAnchor
            else { return }
        faceGeometry.update(from: faceAnchor.geometry)
    }

    /// - Tag: ARFaceGeometryBlendShapes
    func update(withFaceAnchor faceAnchor: ARFaceAnchor) {


    }

}
