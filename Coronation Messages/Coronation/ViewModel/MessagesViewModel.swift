//
//  MessagesViewModel.swift
//  ArKitImessage
//
//  Created by Fabricio Oliveira on 3/15/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import ARKit

protocol MessagesProtocol {
    func modelChanged()
    func trackingStatus(tracked: Bool)
    func durationChanged(duration: CMTime)
    func recordStarted()
    func recordFinished()
    func animojiDownloaded()
    func previewConfigFinished(player: AVPlayer)
    func previewStarted()
    func didRenderScene()
}

class MessagesViewModel: NSObject {
    var modelFactory = ModelFactory()
    var recorder: SceneKitVideoRecorder?
    var isRecording = false
    var lastUrlVideo: URL?
    var delegate: MessagesProtocol?
    let contentUpdater = VirtualContentUpdater()
    var player: AVPlayer?

    var selectedVirtualContent: VirtualContentType = .crown {
        didSet {
            contentUpdater.virtualFaceNode = modelFactory.getModel(type: selectedVirtualContent)
            delegate?.modelChanged()
        }
    }
    
    override init() {
        super.init()
        contentUpdater.delegate = self
    }
    
    
    func createFaceGeometry() {
        modelFactory.createFaceGeometry()
    }
    
    func createRecorder(scene: ARSCNView) {
        let option = SceneKitVideoRecorder.Options(timeScale: 1000,
                                                   videoSize: CGSize(width: 1080, height: 1920),
                                                   fps: 60,
                                                   outputUrl: URL(fileURLWithPath: NSTemporaryDirectory() + "output.mov"),
                                                   audioOnlyUrl: URL(fileURLWithPath: NSTemporaryDirectory() + "audio.m4a"),
                                                   videoOnlyUrl: URL(fileURLWithPath: NSTemporaryDirectory() + "video.mov"),
                                                   fileType: AVFileType(rawValue: AVFileType.mov.rawValue),
                                                   codec: AVVideoCodecType.h264.rawValue,
                                                   deleteFileIfExists: true,
                                                   useMicrophone: true,
                                                   antialiasingMode: .multisampling4X)
        recorder = try! SceneKitVideoRecorder(withARSCNView: scene, options: option)
        recorder?.delegate = self
    }
    
    private func startRecording() {
        self.isRecording = true
        _ = self.recorder?.startWriting()
        delegate?.recordStarted()
    }
    
   private func finishRecording() {
        self.isRecording = false
        delegate?.recordFinished()
    }

    func record() {
        if self.isRecording == false {
            startRecording()
        } else {
            stopRecord()
        }
    }
    
   private func stopRecord() {
        recorder?.finishWriting().onSuccess { [weak self] url in
            self?.lastUrlVideo = url
            self?.finishRecording()
        }
    }
    
    func initAnimojiPreview() {
        guard let videoUrl = self.lastUrlVideo else {return}
        self.player = AVPlayer(url: videoUrl)
        guard let player = self.player else {
            return
        }
        NotificationCenter.default.addObserver(self, selector: #selector(MessagesViewModel.playerItemDidReachEnd), name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: player.currentItem)
        self.delegate?.previewConfigFinished(player: player)
    }
    
    @objc func playerItemDidReachEnd() {
        let duration : Int64 = 0
        let preferredTimeScale : Int32 = 1
        let seekTime : CMTime = CMTimeMake(value: duration, timescale: preferredTimeScale)
        player?.seek(to: seekTime)
        player?.play()
    }
    
    func startPreview() {
        self.player?.play()
        self.delegate?.previewStarted()
    }
    
    func restartExperience() {
        self.player?.pause()
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: self.player?.currentItem)
    }
    
    func download() {
        guard let url = lastUrlVideo else {
            return
        }
        PhotosUtil.saveVideo(at: url, andThen: { (path) in
            self.lastUrlVideo = path
            DispatchQueue.main.async { [weak self] in
                self?.delegate?.animojiDownloaded()
            }
        })
    }
   
}

extension MessagesViewModel: ContentUpdaterDelegate {
    func trackingStatus(tracked: Bool) {
        delegate?.trackingStatus(tracked: tracked)
    }

    func didRenderScene() {
        delegate?.didRenderScene()
    }
}

extension MessagesViewModel: RecorderProtocol {
    func durationChanged(duration: CMTime) {
        DispatchQueue.main.async {
            self.delegate?.durationChanged(duration: duration)
        }
        let totalSeconds = CMTimeGetSeconds(duration)
        let seconds:Int = Int(totalSeconds.truncatingRemainder(dividingBy: 60))
        if seconds >= 60 {
            self.stopRecord()
        }
    }
}
