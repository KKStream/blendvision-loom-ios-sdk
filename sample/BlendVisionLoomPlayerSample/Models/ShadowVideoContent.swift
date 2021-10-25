//
//  ShadowVideoContent.swift
//  BlendVisionLoomPlayerSample
//
//  Created by chantil on 2021/8/19.
//  Copyright © 2021 KKStream Limited. All rights reserved.
//

import Foundation
import BlendVisionLoomPlayer

class ShadowVideoContent {
    var id: String = ""
    var title: String = ""
    var startTime: String = ""

    var sourceUrl: String = ""
    var sourceThumbnailUrl: String = ""

    var drmLicenseUrl: String = ""
    var drmCertificateUrl: String = ""
    var drmHeader: [String: String] = [:]

    func fill(with content: VideoContent) {
        id = content.id
        title = content.title
        startTime = "\(content.startTime)"

        sourceUrl = content.source.url.absoluteString
        sourceThumbnailUrl = content.source.thumbnailUrl.absoluteString

        drmLicenseUrl = content.drm?.licenseUrl.absoluteString ?? ""
        drmCertificateUrl = content.drm?.certificateUrl.absoluteString ?? ""
        drmHeader = content.drm?.header ?? [:]
    }

    func toVideoContent() -> VideoContent? {
        guard
            let startTime = TimeInterval(startTime),
            let sourceUrl = URL(string: sourceUrl),
            let sourceThumbnailUrl = URL(string: sourceThumbnailUrl)
        else { return nil }

        let source = VideoContent.Source(url: sourceUrl,
                                         thumbnailUrl: sourceThumbnailUrl)
        let drm: VideoContent.DRM? = {
            guard let licenseUrl = URL(string: drmLicenseUrl),
                  let certificateUrl = URL(string: drmCertificateUrl),
                  case let header = drmHeader
            else {
                return nil
            }
            return VideoContent.DRM(licenseUrl: licenseUrl, certificateUrl: certificateUrl, header: header)
        }()

        return VideoContent(id: id, title: title, startTime: startTime, source: source, drm: drm)
    }
}
