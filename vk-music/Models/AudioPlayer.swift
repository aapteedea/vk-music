//
//  AudioPlayer.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 9/20/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer

let AudioPlayerDidStartPlayingNotification = "AudioPlayerDidStartPlayingNotification"

class AudioPlayer: NSObject, STKAudioPlayerDelegate, PlayerViewControllerDelegate {
    
    static let sharedAudioPlayer = AudioPlayer()
    
    var _stk_audioPlayer: STKAudioPlayer
    var currentlyPlayingURL: NSURL?
    var currentTrack: Audio? {
        didSet {
            PlayerViewController.sharedInstance.updateTackInfo()
        }
    }
    var playlist: Playlist?

    override init() {
        self._stk_audioPlayer = STKAudioPlayer(options: STKAudioPlayerOptions(
            flushQueueOnSeek: true,
            enableVolumeMixer: false,
            equalizerBandFrequencies: (50, 100, 200, 400, 800, 1600, 2600, 16000, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
            readBufferSize: 0,
            bufferSizeInSeconds: 0,
            secondsRequiredToStartPlaying: 0.0,
            gracePeriodAfterSeekInSeconds: 0.0,
            secondsRequiredToStartPlayingAfterBufferUnderun: 0.0)
        )
        super.init()
        
        // Init audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        } catch let error as NSError {
            NSLog("\(error)")
        }

        // Playback controls
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()        
        
        self._stk_audioPlayer.delegate = self
        PlayerViewController.sharedInstance.delegate = self

        // Register for notifications
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "routeDidChange:", name:AVAudioSessionRouteChangeNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self, name: AVAudioSessionRouteChangeNotification, object: nil)
    }
    
    // MARK: - Public methods
    
    func play (audio: Audio, force: Bool = false) {
        if let URL = audio.fileURL {
            playAudio(fromURL: URL, force: force)
        } else if let URL = audio.remoteURL {
            playAudio(fromURL: URL, force: force)
        }
        self.currentTrack = audio        
    }
    
    func pause() {
        self._stk_audioPlayer.pause()
        PlayerViewController.sharedInstance.configureControlButtons()
    }
    
    func resume() {
        self._stk_audioPlayer.resume()
        PlayerViewController.sharedInstance.configureControlButtons()
    }
    
    func togglePlayPause() {
        switch (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) {
        case
            STKAudioPlayerState.Ready,
            STKAudioPlayerState.Paused,
            STKAudioPlayerState.Stopped,
            STKAudioPlayerState.Error,
            STKAudioPlayerState.Disposed:
            self.resume()
        case
            STKAudioPlayerState.Ready,
            STKAudioPlayerState.Paused:
            self.pause()
        default: break
        }
    }
    
    func previousTrack (userAction: Bool = false) {
        // if more than 4 sec played, replay current track
        if self._stk_audioPlayer.progress < 4 {
            if let audio = self.playlist!.previousTrack() {
                self.play(audio)
            } else {
                self._stk_audioPlayer.stop()
            }
        } else {
            self._stk_audioPlayer.seekToTime(0)
        }
    }
    
    func nextTrack (userAction: Bool = false) {
        if let audio = self.playlist!.nextTrack() {
            self.play(audio)
        } else {
            self._stk_audioPlayer.stop()            
        }
    }
    
    func updatePlayingInfo () {
        let songInfo = NSMutableDictionary()
        
        if let title = self.currentTrack?.title {
            songInfo.setObject(title, forKey: MPMediaItemPropertyTitle)
        }
        
        if let artist = self.currentTrack?.artist {
            songInfo.setObject(artist, forKey: MPMediaItemPropertyArtist)
        }
        
//        if let duration = self.currentTrack?.duration {
//            songInfo.setObject("\(duration)", forKey: MPMediaItemPropertyPlaybackDuration)
//        }
        
        if let albumArt = self.currentTrack?.albumArt {
            songInfo.setObject(MPMediaItemArtwork(image: albumArt), forKey: MPMediaItemPropertyArtwork)
        }
        
//        var elapsedTime = self._stk_audioPlayer.duration - self._stk_audioPlayer.progress
//        NSLog("\(self._stk_audioPlayer.duration) \(self._stk_audioPlayer.progress)")
//        NSLog("\(elapsedTime)")
//        songInfo.setObject(elapsedTime, forKey: MPNowPlayingInfoPropertyElapsedPlaybackTime)
//        
//        //        MPMediaItemPropertyAlbumTitle
        
        MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo.copy() as? [String: AnyObject]
    }
    
    // MARK: - Private methods
    
    private func playAudio (fromURL URL: NSURL, force: Bool = false) {
        if (URL != self.currentlyPlayingURL || force == true) {
            self._stk_audioPlayer.playURL(URL)
            self.currentlyPlayingURL = URL
        }
        if (URL == self.currentlyPlayingURL && self._stk_audioPlayer.state == .Paused) {
            self.resume()
        }
        if (self._stk_audioPlayer.state == .Stopped) {
            self._stk_audioPlayer.seekToTime(0)
            self.resume()
        }
    }
    
    // MARK: - STKAudioPlayerDelegate
    
    func audioPlayer(audioPlayer: STKAudioPlayer, didStartPlayingQueueItemId queueItemId: NSObject) {
        self.updatePlayingInfo()

        NSNotificationCenter.defaultCenter().postNotificationName(AudioPlayerDidStartPlayingNotification, object: nil)
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer, didFinishBufferingSourceWithQueueItemId queueItemId: NSObject) {
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer, stateChanged state: STKAudioPlayerState, previousState: STKAudioPlayerState) {
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer, didFinishPlayingQueueItemId queueItemId: NSObject,
        withReason stopReason: STKAudioPlayerStopReason, andProgress progress: Double, andDuration duration: Double) {
            switch (stopReason) {
            case .Eof:
                self.nextTrack()
            default: break
            }
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer, unexpectedError errorCode: STKAudioPlayerErrorCode) {
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer, logInfo line: String) {
        
    }
    
    func audioPlayer(audioPlayer: STKAudioPlayer, didCancelQueuedItems queuedItems: [AnyObject]) {
        
    }
    
    // MARK: - PlayerViewControllerDelegate
    
    func playerViewControllerPlayPauseButtonPressed(playerViewController: PlayerViewController!) {
        switch (self._stk_audioPlayer.state) {
        case
            STKAudioPlayerState.Ready,
            STKAudioPlayerState.Paused,
            STKAudioPlayerState.Stopped,
            STKAudioPlayerState.Error,
            STKAudioPlayerState.Disposed:
            self._stk_audioPlayer.resume()
        case
            STKAudioPlayerState.Playing,
            STKAudioPlayerState.Buffering:
            self._stk_audioPlayer.pause()
        default: break
        }
    }

    func playerViewControllerPauseButtonPressed(playerViewController: PlayerViewController!) {
        
    }
    
    func playerViewControllerPreviousTackButtonPressed(playerViewController: PlayerViewController!) {
        self.previousTrack(true)
    }
    
    func playerViewControllerNextTackButtonPressed(playerViewController: PlayerViewController!) {
        self.nextTrack(true)
    }
    
    func playerViewController(playerViewController: PlayerViewController!, progressSliderValueChanged value: Float) {
        let time = self._stk_audioPlayer.duration * Double(value)
        self._stk_audioPlayer.seekToTime(time)
    }
    
    // MARK: - Notifications
    
    func routeDidChange(notification: NSNotification!) {
        guard
            let routeChangeReasonValue = notification.userInfo?[AVAudioSessionRouteChangeReasonKey] as? UInt,
            let routeChangeReason = AVAudioSessionRouteChangeReason(rawValue: routeChangeReasonValue)
            else { return }
        
        switch routeChangeReason {
        case .OldDeviceUnavailable:
            self.pause()
        default: break
        }
    }
    
}
