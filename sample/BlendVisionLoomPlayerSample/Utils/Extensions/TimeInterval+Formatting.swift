//
//  TimeInterval+Formatting.swift
//  BlendVisionLoomPlayerSample
//
//  Created by chantil on 2022/1/19.
//  Copyright © 2022 KKStream Limited. All rights reserved.
//

import Foundation

extension TimeInterval {
    func formattedString() -> String {
        if isNaN {
            return "00:00:00"
        }

        let duration   = Int(self)
        let hours      = Int(duration / 3600)
        let minutes    = ((duration - hours * 3600) / 60)
        let seconds    = (duration - hours * 3600 - minutes * 60)

        if hours > 0 {
            return String(format: "%02ld:%02ld:%02ld", hours, minutes, seconds)
        } else {
            return String(format: "%02ld:%02ld", minutes, seconds)
        }
    }
}
