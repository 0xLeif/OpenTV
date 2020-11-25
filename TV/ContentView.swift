//
//  ContentView.swift
//  TV
//
//  Created by Zach Eriksen on 11/25/20.
//

import SwiftUI
import AVKit

struct ContentView: View {
    @StateObject private var videoStore = VideoPlayerStore()
    @State private var isPresentingVideo = false
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(videoStore.videosURLs, id: \.self) { url in
                    VStack {
                        Button(url.absoluteString) {
                            videoStore.videoPlayer = AVPlayer(url: url)
                            isPresentingVideo = true
                        }
                        .padding()
                        Divider()
                    }
                }
            }
        }
        .navigationBarTitle("languages/eng")
        .onAppear {
            videoStore.fetch()
        }
        .sheet(isPresented: $isPresentingVideo) {
            VideoPlayer(player: videoStore.videoPlayer)
                .onAppear { videoStore.videoPlayer.play() }
                .onDisappear { videoStore.videoPlayer.pause() }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
