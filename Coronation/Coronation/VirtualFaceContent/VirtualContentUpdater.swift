/*
 See LICENSE folder for this sample’s licensing information.

 Abstract:
 An `ARSCNViewDelegate` which addes and updates the virtual face content in response to the ARFaceTracking session.
 */

import SceneKit
import ARKit

protocol ContentUpdaterDelegate {
    func trackingStatus(tracked: Bool)
    func didRenderScene()
}


class VirtualContentUpdater: NSObject, ARSCNViewDelegate {
    
    // MARK: Configuration Properties
    
    /**
     Developer setting to display a 3D coordinate system centered on the tracked face.
     See `axesNode`.
     - Tag: ShowCoordinateOrigin
     */
    let showsCoordinateOrigin = false
    
    // MARK: Properties
    var delegate: ContentUpdaterDelegate?
    
    var faceAnchor: ARFaceAnchor?
    
    /// The virtual content that should be displayed and updated.
    var virtualFaceNode: VirtualFaceNode? {
        didSet {
            guard let _ = virtualFaceNode as? VirtualContentController else {
                setupFaceNodeContent()
                return
            }
            setupFaceNodeContentController()
        }
    }
    /**
     A reference to the node that was added by ARKit in `renderer(_:didAdd:for:)`.
     - Tag: FaceNode
     */
    private var faceNode: SCNNode?
    
    /// A 3D coordinate system node.
    private let axesNode = loadedContentForAsset(named: "coordinateOrigin")

    /// - Tag: FaceContentSetup
    private func setupFaceNodeContent() {
        guard let node = faceNode else { return }
        
        // Remove all the current children.
        for child in node.childNodes {
            child.removeFromParentNode()
        }

        if let content = virtualFaceNode {
            node.addChildNode(content)
        }
        
        if showsCoordinateOrigin {
            node.addChildNode(axesNode)
        }
    }

    private func setupFaceNodeContentController() {
        guard let node = faceNode else { return }
        for child in node.childNodes {
            child.removeFromParentNode()
        }
        if showsCoordinateOrigin {
            node.addChildNode(axesNode)
        }
    }

    func renderer(_ renderer: SCNSceneRenderer, didRemove node: SCNNode, for anchor: ARAnchor) {

    }

    func renderer(_ renderer: SCNSceneRenderer, willRenderScene scene: SCNScene, atTime time: TimeInterval) {
     
        
    }

    func renderer(_ renderer: SCNSceneRenderer, didRenderScene scene: SCNScene, atTime time: TimeInterval) {
        delegate?.didRenderScene()
    }

    /// - Tag: ARNodeTracking
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        faceNode = node
        guard let faceAnchor = anchor as? ARFaceAnchor else { return }
        self.faceAnchor = faceAnchor
        if let nodeController = virtualFaceNode as? VirtualContentController {
            if node.childNodes.isEmpty, let contentNode = nodeController.renderer(renderer, nodeFor: faceAnchor) {
                node.addChildNode(contentNode)
            }
        } else {
            setupFaceNodeContent()
        }
    }

    /// - Tag: ARFaceGeometryUpdate
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        guard let faceAnchor = anchor as? ARFaceAnchor else {
            return
        }
        self.faceAnchor = faceAnchor
        faceNode?.isHidden = !faceAnchor.isTracked
        if let nodeController = virtualFaceNode as? VirtualContentController {
            if node.childNodes.isEmpty, let contentNode = nodeController.renderer(renderer, nodeFor: faceAnchor) {
                node.addChildNode(contentNode)
            }
            guard anchor == faceAnchor,
                let contentNode = nodeController.contentNode,
                contentNode.parent == node
                else { return }
            nodeController.renderer(renderer, didUpdate: contentNode, for: anchor)
        } else {
            virtualFaceNode?.update(withFaceAnchor: faceAnchor)
        }
        delegate?.trackingStatus(tracked: faceAnchor.isTracked)
    }

}
