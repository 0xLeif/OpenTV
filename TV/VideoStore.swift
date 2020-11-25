//
//  VideoStore.swift
//  TV
//
//  Created by Zach Eriksen on 11/25/20.
//

import SwiftUI
import AVKit
import Object
import SURL

class VideoPlayerStore: ObservableObject {
    @Published var videosURLs: [URL] = []
    @Published var videoPlayer: AVPlayer = AVPlayer()
    
    func fetch() {
        guard videosURLs.isEmpty else {
            return
        }
        
        "https://iptv-org.github.io/iptv/languages/eng.m3u"
            .url?
            .get(withHandler: { (data, response, error) in
                guard let videos = Object(data)._json
                        .value(as: String.self)?
                        .split(separator: "#") else {
                    return
                }
                
                var videoObjects = [Object]()
                
                for video in videos {
                    if !video.contains("EXTM3U") {
                        let videoData = video.split(separator: "\n")
                        let videoObject = Object {
                            $0.add(variable: "info", value: Object(
                                "{\(videoData.first?.replacingOccurrences(of: "EXTINF:-1 ", with: "") ?? "")}"
                            ))
                            $0.add(variable: "url", value: Object(videoData.last?.description))
                        }
                        
                        // Filter Explict Content
                        if let info = videoObject.info.value(as: String.self),
                           !info.contains("XXX") {
                            videoObjects.append(videoObject)
                        }
                    }
                }
                
                DispatchQueue.main.async {
                    self.videosURLs = Set(videoObjects
                                            .compactMap { object in
                                                URL(string: object.url.value(as: String.self) ?? "-1")
                                            })
                        .map { $0 }
                }
            })
    }
}
