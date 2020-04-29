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

    @IBOutlet weak var sceneView: ARSCNView!
    @IBOutlet weak var pickerView: UIPickerView!
    @IBOutlet weak var lblDuration: UILabel!
    @IBOutlet weak var recordingImageView: UIImageView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var recordButton: KYShutterButton!
    @IBOutlet weak var restartExperienceButton: UIButton!
    @IBOutlet weak var reviewButton: UIButton!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!
    @IBOutlet weak var videoViewContainer: AVPlayerView!
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var heightConstraint: NSLayoutConstraint!

    var isSupported = true
    var activityViewController: UIActivityViewController?
    var collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: UICollectionViewFlowLayout())

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
                bottomConstraint.constant = 0.0
                pickerView.isHidden = false
                collectionView.removeFromSuperview()
                heightConstraint.constant = 235.0
                activityViewController?.dismiss(animated: true, completion: {

                })
            } else {
                heightConstraint.constant = 280.0
                pickerView.isHidden = true
                bottomConstraint.constant = UIScreen.main.bounds.height - sceneView.frame.size.height - recordButton.frame.size.height - 158
                view.addSubview(self.collectionView)
                collectionView.frame = CGRect(x: 0.0, y: bottomConstraint.constant, width: view.frame.size.width, height: view.frame.size.height - bottomConstraint.constant)
            }
            UIView.animate(withDuration: 0.2) {
                self.view.layoutIfNeeded()
            }
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
        let view = UIView.init()
        view.frame = CGRect(x: 0, y: pickerView.frame.size.height / 2 - 25, width: 50, height: 50)
        view.layer.borderColor = Constants.Colors.blueColor.cgColor
        view.layer.cornerRadius = 5.0
        view.layer.borderWidth = 2.0
        pickerView.addSubview(view)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        configCollectionAndPicker()
        updateConstraints()
        if !ARFaceTrackingConfiguration.isSupported {
            isSupported = false
            hideComponents()
        } else {
            sceneView.allowsCameraControl = false
            sceneView.delegate = messagesViewModel.contentUpdater
            sceneView.contentMode = .scaleAspectFill
            sceneView.contentScaleFactor = 1.2
            sceneView.session.delegate = self
            sceneView.automaticallyUpdatesLighting = false
            sceneView.autoenablesDefaultLighting = false
            sceneView.antialiasingMode = .multisampling4X
            sceneView.preferredFramesPerSecond = 60
            if let camera = sceneView.pointOfView?.camera {
                camera.wantsHDR = true
                camera.wantsExposureAdaptation = true
                camera.exposureOffset = -1
                camera.minimumExposure = -1
            }
            messagesViewModel.delegate = self
            messagesViewModel.createFaceGeometry()
            messagesViewModel.createRecorder(scene: sceneView)
            messagesViewModel.selectedVirtualContent = .crown
            pickerView.selectRow(0, inComponent: 0, animated: true)
            statusViewController.restartExperienceHandler = { [unowned self] in
                self.restartExperience()
            }
        }
        resetTracking()
    }

    func hideComponents() {
        sceneView.isHidden = true
        pickerView.isHidden = true
        lblDuration.isHidden = true
        recordingImageView.isHidden = true
        recordButton.isHidden = true
        restartExperienceButton.isHidden = true
        reviewButton.isHidden = true
        downloadButton.isHidden = true
        shareButton.isHidden = true
        videoViewContainer.isHidden = true
        sendButton.isHidden = true
        pickerView.isHidden = true
        collectionView.isHidden = true
    }


    @IBAction func record(sender: KYShutterButton) {
        self.sceneView.scene.rootNode.particleSystems?.forEach { particle in
            particle.speedFactor = particle.speedFactor / 2.0
        }
        messagesViewModel.record()
    }


    @IBAction func sendAtachment(sender: AnyObject) {
        guard let url = messagesViewModel.lastUrlVideo else {
            return
        }
        if Reachability.isConnectedToNetwork() {
            self.activeConversation?.sendAttachment(url, withAlternateFilename: url.lastPathComponent, completionHandler: { [weak self] (error) in
                let alertController = UIAlertController(title: "Success", message: "Your message was sent with success.", preferredStyle: .alert)
                self?.present(alertController, animated: true, completion: nil)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5, execute: {
                    alertController.dismiss(animated: true, completion: nil)
                })
            })
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
        messagesViewModel.download()
    }

    func initAnimojiPreview() {
        messagesViewModel.initAnimojiPreview()
    }

    @IBAction func shareAction(sender: UIButton) {
        guard let url = messagesViewModel.lastUrlVideo else {
            return
        }
        requestPresentationStyle(.expanded)
        activityViewController = UIActivityViewController(
            activityItems: [url],
            applicationActivities: nil)
        present(activityViewController!, animated: true, completion: nil)
    }

    @IBAction func reviewLastVideo(sender: UIButton) {
        if videoViewContainer.isHidden == true {
            messagesViewModel.startPreview()
        }
    }

    //  override func viewDidAppear(_ animated: Bool) {
    //    super.viewDidAppear(animated)
    //    /*
    //     AR experiences typically involve moving the device without
    //     touch input for some time, so prevent auto screen dimming.
    //     */
    //    //UIApplication.shared.isIdleTimerDisabled = true
    //    resetTracking()
    //  }

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

        DispatchQueue.main.async {
            self.displayErrorMessage(title: "The AR session failed.", message: errorMessage)
        }
    }

    func sessionWasInterrupted(_ session: ARSession) {
        statusViewController.showMessage("Session interrupted", autoHide: false)
    }

    func sessionInterruptionEnded(_ session: ARSession) {

        DispatchQueue.main.async {
            self.resetTracking()
        }
    }

    /// - Tag: ARFaceTrackingSetup
    func resetTracking() {
        statusViewController.showMessage("Starting new session")
        guard ARFaceTrackingConfiguration.isSupported else { return }
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = false
        configuration.worldAlignment = .camera
        session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    // MARK: - Interface Actions

    /// - Tag: restartExperience
    func restartExperience() {
        // Disable Restart button for a while in order to give the session enough time to restart.
        self.isRestartExperienceButtonEnabled = false
        self.recordButton.isEnabled = false
        self.sendButton.isEnabled = false
        self.statusViewController.view.isHidden = false
        self.reviewButton.isEnabled = false
        self.reviewButton.isHidden = true
        self.videoViewContainer.isHidden = true
        self.pickerView.isHidden = true
        self.downloadButton.isEnabled = false
        self.downloadButton.isHidden = true
        self.shareButton.isEnabled = false
        self.shareButton.isHidden = true
        self.restartExperienceButton.setImage(UIImage(named: "ic_rescan"), for: UIControl.State.normal)
        self.messagesViewModel.restartExperience()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.isRestartExperienceButtonEnabled = true
            self.videoViewContainer.isHidden = true
            self.recordButton.isEnabled = true
            self.sendButton.isEnabled = true
            self.recordButton.isHidden = false
            self.messagesViewModel.lastUrlVideo = nil
            self.sendButton.isHidden = true
            self.reviewButton.isHidden = true
            self.videoViewContainer.isHidden = true
            self.lblDuration.isHidden = true
            self.reviewButton.isEnabled = true
            self.downloadButton.isEnabled = true
            self.pickerView.isHidden = self.presentationStyle == .expanded
            self.shareButton.isEnabled = true

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
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Conversation Handling


    override func willBecomeActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the inactive to active state.
        // This will happen when the extension is about to present UI.
        //conversation.selectedMessage?.url = nil

        //savedConversation = conversation
        //    safariViewController?.dismiss(animated: true, completion: nil)
        //    if let url = conversation.selectedMessage?.url {
        //      safariViewController = SFSafariViewController(url: url)
        //      present(safariViewController!, animated: true, completion: nil)
        //    }

    }


    override func didResignActive(with conversation: MSConversation) {
        // Called when the extension is about to move from the active to inactive state.
        // This will happen when the user dissmises the extension, changes to a different
        // conversation or quits Messages.
        if isSupported == false {
            conversation.selectedMessage?.url = nil
        }

        // Use this method to release shared resources, save user data, invalidate timers,
        // and store enough state information to restore your extension to its current state
        // in case it is terminated later.
    }



    override func didReceive(_ message: MSMessage, conversation: MSConversation) {
        // Called when a message arrives that was generated by another instance of this
        // extension on a remote device.

        // Use this method to trigger UI updates in response to the message.
    }

    override func didStartSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user taps the send button.
    }

    override func didCancelSending(_ message: MSMessage, conversation: MSConversation) {
        // Called when the user deletes the message without sending it.

        // Use this to clean up state related to the deleted message.
    }

    override func willTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        // Called before the extension transitions to a new presentation style.
        if self.isSupported == false {
            guard activeConversation != nil else { fatalError("Expected an active converstation") }
        }
    }

    override func didTransition(to presentationStyle: MSMessagesAppPresentationStyle) {
        updateConstraints()
    }

}

extension MessagesViewController {
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        //collectionView.animateVisibleCells()
    }
}



extension MessagesViewController: UIPickerViewDelegate, UIPickerViewDataSource {

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        pickerView.subviews.forEach({
            $0.isHidden = $0.frame.height < 1.0
        })
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return VirtualContentType.orderedValues.count
    }

    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 50.0
    }

    func pickerView(_ pickerView: UIPickerView, widthForComponent component: Int) -> CGFloat {
        return 50.0
    }

    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {

        let content = VirtualContentType(rawValue: row)!
        let imageView = UIImageView.init(image: UIImage.init(named: content.imageName))
        imageView.contentMode = .scaleAspectFit
        imageView.frame = CGRect(x: 7, y: 5, width: 36, height: 36)
        imageView.tintColor = UIColor.black
        imageView.contentMode = .scaleToFill
        return imageView
    }

    // MARK: UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        messagesViewModel.selectedVirtualContent = VirtualContentType(rawValue: row)!
        collectionView.selectItem(at: IndexPath.init(row: row, section: 0), animated: true, scrollPosition: UICollectionView.ScrollPosition.centeredVertically)
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
        cell.imageView.image = UIImage(named: content.imageName)
        cell.isSelected = indexPath.item == messagesViewModel.selectedVirtualContent.rawValue
        return cell
    }

    // MARK: - UICollectionViewDelegate

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        messagesViewModel.selectedVirtualContent = VirtualContentType(rawValue: indexPath.item)!
        pickerView.selectRow(indexPath.row, inComponent: 0, animated: true)
    }
}

extension MessagesViewController: UICollectionViewDelegateFlowLayout {


    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }


    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10.0, left: 10.0, bottom: 10.0, right: 10.0)
    }
    func collectionView(_ collectionView: UICollectionView, layout
        collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10.0
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: (collectionView.frame.width / 3) - 20, height: (collectionView.frame.width / 3) - 20)
    }
}

extension MessagesViewController: MessagesProtocol {

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
        shareButton.isHidden = true
        lblDuration.isHidden = false
        lblDuration.text = "00:00"
        recordingImageView.isHidden = false
        recordButton.buttonState = .recording
        sendButton.isHidden = true
        recordButton.isHidden = false
        pickerView.isHidden = true
        restartExperienceButton.setImage(UIImage(named: "ic_rescan"), for: UIControl.State.normal)
    }

    func recordFinished() {
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
        self.pickerView.isHidden = true
        self.initAnimojiPreview()
        self.sceneView.scene.rootNode.particleSystems?.forEach { particle in
            particle.speedFactor = particle.speedFactor * 2.0
        }
    }

    func previewConfigFinished(player: AVPlayer) {
        guard let castedLayer = videoViewContainer.layer as? AVPlayerLayer else {
            return
        }
        castedLayer.player = player
    }

    func previewStarted() {
        videoViewContainer.isHidden = false
        session.pause()
        statusViewController.view.isHidden = true
        reviewButton.isEnabled = false
        pickerView.isHidden = true
        downloadButton.isEnabled = true
        shareButton.isEnabled = true
    }

    func modelChanged() {
        pickerView.reloadAllComponents()
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
