//
//  CustomView.swift
//  ArKitImessage
//
//  Created by Fabricio Oliveira on 3/15/18.
//  Copyright © 2018 Apple. All rights reserved.
//

import Foundation
import UIKit
import Photos

class AVPlayerView: UIView {
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
}
