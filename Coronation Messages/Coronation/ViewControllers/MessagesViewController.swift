//
//  MessagesViewController.swift
//  ArKitImessage
//
//  Created by Fabricio Oliveira on 12/19/17.
//  Copyright © 2017 Apple. All rights reserved.
//

import UIKit
import Messages
import ARKit
import SceneKit
import Foundation
import Photos
import KYShutterButton

class MessagesViewController: MSMessagesAppViewController, ARSessionDelegate {

    @IBOutlet weak var compactStackView: UIStackView!
    @IBOutlet weak var compactView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var recordingImageView: UIImageView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var recordButton: KYShutterButton!
    @IBOutlet weak var videoViewContainer: AVPlayerView!

    @IBOutlet weak var restartExperienceButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var previewImageView: UIImageView!
    
    @IBOutlet weak var holdToRecordLabel: UILabel!
    var isSupported = true
    var activityViewController: UIActivityViewController?

    private var isPictureMode: Bool {
        return !previewImageView.isHidden
    }

    var isRestartExperienceButtonEnabled: Bool {
        get { return restartExperienceButton.isEnabled }
        set { restartExperienceButton.isEnabled = newValue }
    }

    var statusViewController: StatusViewController!

    // MARK: Properties

    /// Convenience accessor for the session owned by ARSCNView.
    var session: ARSession {
        return sceneView.session
    }

    var messagesViewModel = MessagesViewModel()

    private var impactFeedbackgenerator: UIImpactFeedbackGenerator?

    override func viewDidLoad() {
        super.viewDidLoad()
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(recording(gesture:)))
        longPress.minimumPressDuration = 1.0
        recordButton.addGestureRecognizer(longPress)
        impactFeedbackgenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedbackgenerator?.prepare()
        updateConstraints()
        configCollectionAndPicker()
        if !ARFaceTrackingConfiguration.isSupported {
            isSupported = false
            hideComponents()
        } else {
            let configuration = ARFaceTrackingConfiguration()
            configuration.isLightEstimationEnabled = true
            configuration.worldAlignment = .camera
            let session = ARSession()
            sceneView.session = session
            session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            sceneView.allowsCameraControl = false
            sceneView.delegate = messagesViewModel.contentUpdater
            sceneView.contentMode = .scaleAspectFit
            sceneView.contentScaleFactor = 1.2
            sceneView.session.delegate = self
            sceneView.automaticallyUpdatesLighting = true
            sceneView.autoenablesDefaultLighting = true
            sceneView.antialiasingMode = .multisampling4X
            sceneView.preferredFramesPerSecond = 60
            sceneView.backgroundColor = .clear
            //            if let camera = sceneView.pointOfView?.camera {
            //                camera.wantsHDR = true
            //                camera.wantsExposureAdaptation = true
            //                camera.exposureOffset = -1
            //                camera.minimumExposure = -1
            //            }
            messagesViewModel.delegate = self
            messagesViewModel.createFaceGeometry()
            messagesViewModel.selectedVirtualContent = .crown
            statusViewController.restartExperienceHandler = { [weak self] in
                self?.restartExperience()
            }
        }
        resetTracking()
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "statusSegue" {
            self.statusViewController = segue.destination as? StatusViewController
        }
    }

    override func viewDidDisappear(_ animated: Bool) {

    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
    }

    func updateConstraints() {
        if isSupported == true {
            if presentationStyle == .compact {
                activityViewController?.dismiss(animated: true, completion: {

                })
            }
            collectionView.isHidden = self.presentationStyle == .compact
            recordButton.isHidden = self.presentationStyle == .compact
            holdToRecordLabel.isHidden = self.presentationStyle == .compact
        }
    }

    func configCollectionAndPicker() {
        collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.backgroundColor = UIColor.clear
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        collectionView.setCollectionViewLayout(layout, animated: true)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        messagesViewModel.createRecorder(scene: sceneView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2, execute: {
            self.requestPresentationStyle(.expanded)
        })
    }

    func hideComponents() {
        sceneView.isHidden = true
        lblDuration.isHidden = true
        recordingImageView.isHidden = true
        recordButton.isHidden = true
        holdToRecordLabel.isHidden = true
        restartExperienceButton.isHidden = true
        reviewButton.isHidden = true
        downloadButton.isHidden = true
        shareButton.isHidden = true
        videoViewContainer.isHidden = true
        previewImageView.isHidden = true
        sendButton.isHidden = true
        collectionView.isHidden = true
    }


    @IBAction func record(sender: KYShutterButton) {
        previewImageView.image = sceneView.snapshot()
        pictureTaken()
    }


    @objc func recording(gesture: UILongPressGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began {
            impactFeedbackgenerator?.impactOccurred()
            impactFeedbackgenerator?.prepare()
            messagesViewModel.record()
        } else if gesture.state == UIGestureRecognizer.State.ended {
            messagesViewModel.record()
        }
    }

    @IBAction func sendAtachment(sender: AnyObject) {

        if Reachability.isConnectedToNetwork() {
            if isPictureMode {
                let message = MSMessage()
                let layout = MSMessageTemplateLayout()
                layout.image = previewImageView.image
                message.layout = layout
                self.activeConversation?.send(message, completionHandler: { [weak self] (error) in
                    let alertController = UIAlertController(title: "Success", message: "Your message was sent with success.", preferredStyle: .alert)
                    self?.present(alertController, animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        alertController.dismiss(animated: true, completion: nil)
                    })
                })
            } else {
                guard let url = messagesViewModel.lastUrlVideo else {
                    return
                }
                self.activeConversation?.sendAttachment(url, withAlternateFilename: url.lastPathComponent, completionHandler: { [weak self] (error) in
                    let alertController = UIAlertController(title: "Success", message: "Your message was sent with success.", preferredStyle: .alert)
                    self?.present(alertController, animated: true, completion: nil)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                        alertController.dismiss(animated: true, completion: nil)
                    })
                })
            }
        } else {
            let alertController = UIAlertController(title: "Warning", message: "Check your internet connection.", preferredStyle: .alert)
            present(alertController, animated: true, completion: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                alertController.dismiss(animated: true, completion: nil)
            })

        }
    }

    // MARK: Messaging
    func composeMessage(session: MSSession? = nil, url: URL) -> MSMessage? {
        let layout = MSMessageTemplateLayout()
        let components = URLComponents()
        let message = MSMessage(session: session ?? MSSession())
        layout.mediaFileURL = url
        message.url = components.url!
        message.layout = layout
        return message
    }

    @IBAction func download(sender: UIButton) {
        if let image = previewImageView.image, isPictureMode {
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
        } else {
            messagesViewModel.download()
        }
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            let ac = UIAlertController(title: "Save error", message: error.localizedDescription, preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        } else {
            let ac = UIAlertController(title: "Saved!", message: "Your image has been saved to your photos.", preferredStyle: .alert)
            ac.addAction(UIAlertAction(title: "OK", style: .default))
            present(ac, animated: true)
        }
    }

    func initAnimojiPreview() {
        messagesViewModel.initAnimojiPreview()
    }

    @IBAction func openUpAction(_ sender: Any) {
        requestPresentationStyle(.expanded)
    }

    @IBAction func shareAction(sender: UIButton) {
        if isPictureMode {
            requestPresentationStyle(.expanded)
            activityViewController = UIActivityViewController(
                activityItems: [previewImageView.image as AnyObject],
                applicationActivities: nil)
            present(activityViewController!, animated: true, completion: nil)
        } else {
            guard let url = messagesViewModel.lastUrlVideo else {
                return
            }
            requestPresentationStyle(.expanded)
            activityViewController = UIActivityViewController(
                activityItems: [url],
                applicationActivities: nil)
            present(activityViewController!, animated: true, completion: nil)
        }
    }


    @IBAction func reviewLastVideo(sender: UIButton) {
        if videoViewContainer.isHidden == true {
            messagesViewModel.startPreview()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        session.pause()
    }

    // MARK: - Setup
    /// - Tag: CreateARSCNFaceGeometry
    @IBAction func restartExperience(_ sender: UIButton) {
        self.restartExperience()
    }

    // MARK: - ARSessionDelegate
    func session(_ session: ARSession, cameraDidChangeTrackingState camera: ARCamera) {
        print(camera.trackingState)
    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        guard error is ARError else { return }

        let errorWithInfo = error as NSError
        let messages = [
            errorWithInfo.localizedDescription,
            errorWithInfo.localizedFailureReason,
            errorWithInfo.localizedRecoverySuggestion
        ]
        let errorMessage = messages.compactMap({ $0 }).joined(separator: "\n")

        DispatchQueue.main.async { [weak self] in
            self?.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }

    func sessionWasInterrupted(_ session: ARSession) {
        statusViewController.showMessage("Session interrupted", autoHide: false)
    }

    func sessionInterruptionEnded(_ session: ARSession) {
        DispatchQueue.main.async { [weak self] in
            self?.resetTracking()
        }
    }

    /// - Tag: ARFaceTrackingSetup
    func resetTracking() {
        statusViewController.showMessage("Starting new session")
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        configuration.worldAlignment = .camera
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    // MARK: - Interface Actions

    /// - Tag: restartExperience
    func restartExperience() {
        // Disable Restart button for a while in order to give the session enough time to restart.
        isRestartExperienceButtonEnabled = false
        recordButton.isEnabled = false
        sendButton.isEnabled = false
        sendButton.isHidden = true
        statusViewController.view.isHidden = false
        reviewButton.isEnabled = false
        reviewButton.isHidden = true
        videoViewContainer.isHidden = true
        previewImageView.isHidden = true
        downloadButton.isEnabled = false
        downloadButton.isHidden = true
        shareButton.isEnabled = false
        shareButton.isHidden = true
        restartExperienceButton.setImage(UIImage(named: "ic_rescan"), for: UIControl.State.normal)
        messagesViewModel.restartExperience()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) { [weak self] in
            guard let `self` = self else {
                return
            }
            self.isRestartExperienceButtonEnabled = true
            self.videoViewContainer.isHidden = true
            self.previewImageView.isHidden = true
            self.recordButton.isEnabled = true
            self.sendButton.isEnabled = true
            self.recordButton.isHidden = false
            self.holdToRecordLabel.isHidden = false
            self.messagesViewModel.lastUrlVideo = nil
            self.sendButton.isHidden = true
            self.reviewButton.isHidden = true
            self.videoViewContainer.isHidden = true
            self.previewImageView.isHidden = true
            self.lblDuration.isHidden = true
            self.reviewButton.isEnabled = true
            self.downloadButton.isEnabled = true
            self.shareButton.isEnabled = true
            self.collectionView.isHidden = self.presentationStyle != .expanded
        }
        resetTracking()
    }


    // MARK: - Error handling

    func displayErrorMessage(title: String, message: String) {

        // Present an alert informing about the error that has occurred.
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let restartAction = UIAlertAction(title: "Restart Session", style: .default) { _ in
            alertController.dismiss(animated: true, completion: nil)
            self.resetTracking()
        }
        alertController.addAction(restartAction)
        present(alertController, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Conversation Handling
    override func didResignActive(with conversation: MSConversation) {
        if isSupported == false {
            conversation.selectedMessage?.url = nil
        }
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        if self.isSupported == false {
            guard activeConversation != nil else { fatalError("Expected an active converstation") }
        }
        restartExperience()
        UIView.animate(withDuration: 0.2) {
            self.compactView.alpha = presentationStyle == .expanded ? 0.0:1.0
        }
    }

    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        updateConstraints()
        UIView.animate(withDuration: 0.2) {
            self.compactStackView.alpha = presentationStyle == .expanded ? 0.0:1.0
        }
    }

}

extension MessagesViewController: UICollectionViewDataSource, UICollectionViewDelegate {

    // MARK: - UICollectionViewDataSource

    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {

    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return VirtualContentType.orderedValues.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as? CollectionViewCell else {
            fatalError("Expected `\(CollectionViewCell.self)` type for reuseIdentifier 'CollectionViewCell'. Check the configuration in Main.storyboard.")
        }
        let content = VirtualContentType(rawValue: indexPath.item)!
        cell.imageView.contentMode = .scaleAspectFit
        cell.imageView.image = UIImage(named: content.imageName)?.withRenderingMode(.alwaysTemplate)
        cell.isSelected = indexPath.item == messagesViewModel.selectedVirtualContent.rawValue
        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        messagesViewModel.selectedVirtualContent = VirtualContentType(rawValue: indexPath.item)!
        impactFeedbackgenerator?.impactOccurred()
        impactFeedbackgenerator?.prepare()
    }
}

extension MessagesViewController: UICollectionViewDelegateFlowLayout {


    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
    }
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
}

extension MessagesViewController: MessagesProtocol {

    func didRenderScene() {
        DispatchQueue.main.async {  [weak self] in
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.sceneView.alpha = 1.0
            }
        }
    }

    func durationChanged(duration: CMTime) {
        DispatchQueue.main.async {
            self.lblDuration.text = duration.durationText
        }
    }

    func animojiDownloaded() {
        let alert = UIAlertController(title: "Success",
                                      message: "MymixEmoji saved on your library",
                                      preferredStyle: .alert)
        self.present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            alert.dismiss(animated: true, completion: nil)
        }
    }

    func recordStarted() {
        restartExperienceButton.isHidden = true
        reviewButton.isHidden = true
        downloadButton.isHidden = true
        collectionView.isHidden = true
        shareButton.isHidden = true
        lblDuration.isHidden = false
        lblDuration.text = "00:00"
        holdToRecordLabel.isHidden = true
        recordingImageView.isHidden = false
        recordButton.buttonState = .recording
        sendButton.isHidden = true
        recordButton.isHidden = false
        restartExperienceButton.setImage(UIImage(named: "ic_rescan"), for: UIControl.State.normal)
    }

    func recordFinished() {
        self.holdToRecordLabel.isHidden = true
        self.previewImageView.isHidden = true
        self.recordButton.buttonState = .normal
        self.lblDuration.isHidden = true
        self.lblDuration.text = "00:00"
        self.recordingImageView.isHidden = true
        self.restartExperienceButton.isHidden = false
        self.reviewButton.isHidden = false
        self.downloadButton.isHidden = false
        self.shareButton.isHidden = false
        self.recordButton.isHidden = true
        self.sendButton.isHidden = false
        self.initAnimojiPreview()
    }

    func previewConfigFinished(player: AVPlayer) {
        guard let castedLayer = videoViewContainer.layer as? AVPlayerLayer else {
            return
        }
        castedLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        castedLayer.player = player
    }

    func pictureTaken() {
        previewImageView.isHidden = false
        recordingImageView.isHidden = true
        recordButton.buttonState = .normal
        lblDuration.isHidden = true
        lblDuration.text = "00:00"
        recordingImageView.isHidden = true
        restartExperienceButton.isHidden = false
        reviewButton.isHidden = true
        downloadButton.isHidden = false
        shareButton.isHidden = false
        recordButton.isHidden = true
        holdToRecordLabel.isHidden = true
        sendButton.isHidden = false
    }

    func previewStarted() {
        videoViewContainer.isHidden = false
        session.pause()
        statusViewController.view.isHidden = true
        reviewButton.isEnabled = false
        downloadButton.isEnabled = true
        shareButton.isEnabled = true
    }

    func modelChanged() {
        collectionView.reloadData()
    }
    
    func trackingStatus(tracked: Bool) {
        
        DispatchQueue.main.async { [weak self] in
            if tracked {
                self?.statusViewController.hideMessage()
            } else {
                self?.statusViewController.showMessage("Please bring your face into the view", autoHide: false)
            }
        }
    }
}
