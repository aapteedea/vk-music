//
//  PlayerViewController.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 9/20/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import UIKit
import MediaPlayer

private var _sharedPlayerViewController: PlayerViewController!

protocol PlayerViewControllerDelegate: NSObjectProtocol {
    func playerViewControllerPlayPauseButtonPressed(playerViewController: PlayerViewController!)
    func playerViewControllerPauseButtonPressed(playerViewController: PlayerViewController!)
    func playerViewControllerPreviousTackButtonPressed(playerViewController: PlayerViewController!)
    func playerViewControllerNextTackButtonPressed(playerViewController: PlayerViewController!)
    func playerViewController(playerViewController: PlayerViewController!, progressSliderValueChanged value: Float)
}

class PlayerNavigationBarView: UIView {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var fileNameLabel: UILabel!
    
}

class PlayerViewController: UIViewController {
    
    static let sharedInstance = PlayerViewController.instantiateFromStoryBoard()
    
    @IBOutlet weak var albumArtImageView: UIImageView!
    @IBOutlet weak var trackNumberLabel: UILabel!
    @IBOutlet weak var elapsedTimeLabel: UILabel!
    @IBOutlet weak var remainingTimeLabel: UILabel!
    @IBOutlet weak var progressSlider: UISlider!
    @IBOutlet weak var rewindButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var fastRewindButton: UIButton!
    @IBOutlet weak var volumeView: MPVolumeView!

    private var navigationBarView = NSBundle.mainBundle().loadNibNamed("PlayerNavigationBarView", owner: nil, options: nil)[0] as! PlayerNavigationBarView
    weak var delegate: PlayerViewControllerDelegate?
    
    // MARK: - Private Methods
    
    private class func instantiateFromStoryBoard() -> PlayerViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        return storyboard.instantiateViewControllerWithIdentifier("playerViewController") as! PlayerViewController
    }
    
    // MARK: - Public Methods
    
    func clearTrackInfo() {
        navigationBarView.titleLabel.text = nil
        navigationBarView.artistLabel.text = nil
        navigationBarView.fileNameLabel.text = nil
        
        albumArtImageView?.image = UIImage(named: "AlbumCoverPlaceHolder")
        trackNumberLabel?.text = "1 of 1"
    }
    
    func updateTackInfo () {
        clearTrackInfo()

        guard let track = AudioPlayer.sharedAudioPlayer.currentTrack else { return }
            
        if let title = track.title, let artist = track.artist {
            navigationBarView.titleLabel.text = title
            navigationBarView.artistLabel.text = artist
        } else {
            navigationBarView.fileNameLabel.text = track.fileName
        }

        if let albumArt = track.albumArt {
            albumArtImageView?.image = albumArt
        }
        
        if let index = AudioPlayer.sharedAudioPlayer.playlist?.indexOfTrack(track),
            let count = AudioPlayer.sharedAudioPlayer.playlist?.count() {
            trackNumberLabel?.text = "\(index+1) of \(count)"
        }
    }

    func updateProgress() {
        progressSlider.value = Float(AudioPlayer.sharedAudioPlayer._stk_audioPlayer.progress / AudioPlayer.sharedAudioPlayer._stk_audioPlayer.duration)
        
        let elapsed = AudioPlayer.sharedAudioPlayer._stk_audioPlayer.progress as NSTimeInterval
        elapsedTimeLabel.text = Utilities.prettifyTime(elapsed)

        let remaining = (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.duration - AudioPlayer.sharedAudioPlayer._stk_audioPlayer.progress) as NSTimeInterval
        remainingTimeLabel.text = "-\(Utilities.prettifyTime(remaining))"
    }
    
    func configureControlButtons() {
        switch (AudioPlayer.sharedAudioPlayer._stk_audioPlayer.state) {
            case
                STKAudioPlayerState.Ready,
                STKAudioPlayerState.Paused,
                STKAudioPlayerState.Stopped,
                STKAudioPlayerState.Error,
                STKAudioPlayerState.Disposed:
                playButton.setImage(UIImage(named: "UIButtonBarPlay"), forState: .Normal)
            case
                STKAudioPlayerState.Playing,
                STKAudioPlayerState.Buffering:
                playButton.setImage(UIImage(named: "UIButtonBarPause"), forState: .Normal)
            default: break
        }
    }
    
    func configure() {
        updateProgress()
        configureControlButtons()
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        edgesForExtendedLayout = .None
        navigationItem.titleView = navigationBarView
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "updateProgress", userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        tabBarController?.tabBar.hidden = true

        updateTackInfo()
        configure()
        updateProgress()
    }
    
    // MARK: - Actions
    
    @IBAction func playButtonPressed(sender: AnyObject) {
        delegate?.playerViewControllerPlayPauseButtonPressed(self)
        updateTackInfo()
        configureControlButtons()
    }

    @IBAction func rewindButtonPressed(sender: AnyObject) {
        delegate?.playerViewControllerPreviousTackButtonPressed(self)
        updateTackInfo()
        configure()
    }
    
    @IBAction func fastRewindButtonPressed(sender: AnyObject) {
        delegate?.playerViewControllerNextTackButtonPressed(self)
        updateTackInfo()
        configure()
    }
    
    @IBAction func progressSliderValueChanged(sender: UISlider) {
        delegate?.playerViewController(self, progressSliderValueChanged: sender.value)
    }

}
