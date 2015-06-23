//
//  Playlist.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 12/11/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import UIKit

enum PlaylistMode: UInt {
    case RepeatNone
    case RepeatOne
    case RepeatAll
//    case Shuffle
}

class Playlist: NSObject {
    var mode: PlaylistMode = .RepeatAll
    var allTracks = [Audio]()

    var unplayedTracks = [Audio]()
    var playedTracks = [Audio]()
    
    var lastRequestedTrack: Audio?

    init(audios: [Audio]) {
        self.allTracks = audios
        self.unplayedTracks = audios
        
        super.init()
    }
    
    func count() -> Int {
        return self.allTracks.count
    }
    
    func indexOfTrack(audio: Audio?) -> Int {
        if let audio = audio {
            if let idx = self.allTracks.indexOf(audio) {
                return idx
            }
        }
        return 0
    }
    
    func trackAtIndex(idx :Int) -> Audio? {
        self.lastRequestedTrack = self.allTracks[idx]
        return self.lastRequestedTrack
    }
    
    func previousTrack() -> Audio? {
        var track: Audio?

        switch self.mode {
        case .RepeatNone:
            let idx = self.indexOfTrack(self.lastRequestedTrack) - 1
            if (idx < 0) {
                track = nil
            }
            track = self.allTracks[idx]
            
        case .RepeatOne:
            track = self.lastRequestedTrack

        case .RepeatAll:
            var idx = self.indexOfTrack(self.lastRequestedTrack) - 1
            if (idx < 0) {
                idx = self.allTracks.count - 1
            }
            track = self.allTracks[idx]
        }

        self.lastRequestedTrack = track
        return track
    }
    
    func nextTrack() -> Audio? {
        var track: Audio?
        
        switch self.mode {
        case .RepeatNone:
            let idx = self.indexOfTrack(self.lastRequestedTrack) + 1
            if (idx == self.allTracks.count) {
                track = nil
            }
            track = self.allTracks[idx]
            
        case .RepeatOne:
            track = self.lastRequestedTrack

        case .RepeatAll:
            var idx = self.indexOfTrack(self.lastRequestedTrack) + 1
            if (idx == self.allTracks.count) {
                idx = 0
            }
            track = self.allTracks[idx]
        }
        
        self.lastRequestedTrack = track
        return track
    }

}
