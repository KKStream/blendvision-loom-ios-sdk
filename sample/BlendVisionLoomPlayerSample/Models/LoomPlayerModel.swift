//
//  LoomPlayerModel.swift
//  BlendVisionLoomPlayerSample
//
//  Created by chantil on 2021/9/2.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import Foundation

import BlendVisionLoomPlayer

class LoomPlayerModel {
    var context: PlayerContext = PlayerContext(barItems: [])
    var contents: [VideoContent] = [
        VideoContent(id: "",
                     title: "Basic Streaming (16x9)",
                     startTime: 0,
                     source: VideoContent.Source(url: URL(string: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_16x9/bipbop_16x9_variant.m3u8")!,
                                                 thumbnailUrl: URL(string: "http://")!),
                     drm: nil)
    ]
    var startIndex: Int = 0
}
