//
//  DownloadsViewController.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 8/6/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import UIKit

class DownloadsViewController: TableViewController, DirectoryWatcherDelegate {

    @IBOutlet var searchBar: UISearchBar!
//    var directoryWatcher: DirectoryWatcher!
    var audioFiles: [Audio] = [Audio]() {
        didSet {
            self.playlist = Playlist(audios: audioFiles)
        }
    }
    var playlist: Playlist? {
        didSet {
            AudioPlayer.sharedAudioPlayer.playlist = playlist
        }
    }
    
    required  init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        var documentsDirectory = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0] as! String
//        directoryWatcher = DirectoryWatcher.watchFolderWithPath(documentsDirectory, delegate: self)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: "reloadData", name: NewFilesAvailableNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidStartPlaying", name: AudioPlayerDidStartPlayingNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        self.clearsSelectionOnViewWillAppear = false
        self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        self.refreshControl = UIRefreshControl()
        self.refreshControl?.addTarget(self, action: "refreshControlValueChanged:", forControlEvents: .ValueChanged)
        
        self.reloadData()
    }

    override func viewDidLayoutSubviews() {
        self.tableView.separatorInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        self.tableView.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.        
    }

    // MARK: - UITableViewDataSource

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.audioFiles.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("defaultCell", forIndexPath: indexPath) as! DefaultTableViewCell
        var file = self.audioFiles[indexPath.row]
        
        cell.artistLabel.text = file.artist
        cell.titleLabel.text = file.title

        if (file.artist == nil && file.title == nil) {
            cell.artistLabel.text = file.fileName
        }
        
        cell.durationLabel.text = Utilities.prettifyTime(Double(file.duration))
        cell.sizeLabel.text = Utilities.prettifySize(file.size)
        
        if  let albumArt = file.albumArt {
            cell.albumCoverImageView.image = albumArt
        }

        return cell
    }

    override func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        cell.separatorInset = UIEdgeInsetsMake(0.0, 2.0, 0.0, 0.0)
        cell.layoutMargins = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
    }
    
    // MARK: - UITableViewDelegate
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let track = playlist?.trackAtIndex(indexPath.row) {
            AudioPlayer.sharedAudioPlayer.playlist = self.playlist
            AudioPlayer.sharedAudioPlayer.play(track)
        }
        self.navigationController?.pushViewController(PlayerViewController.sharedInstance, animated: true)
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        var file = self.audioFiles[indexPath.row]
        
        var error: NSError?
        DataManager.removeFile(file.fileURL!, error: &error)
        if (error != nil) { NSLog("error: \(error)"); return }

        self.audioFiles = DataManager.audioFiles()
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }
    
    // MARK: - Actions
    
    override func setEditing(editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        
        self.tableView.setEditing(editing, animated: animated)
    }
    
    func refreshControlValueChanged(refreshControl: UIRefreshControl!) {
        self.reloadData()
        refreshControl.endRefreshing()
    }
    
    // MARK: - Notifications
    
    func reloadData() {
        self.audioFiles = DataManager.audioFiles()
        self.tableView.reloadData()
    }
    
    func playerDidStartPlaying() {
        var indexPath = self.tableView.indexPathForSelectedRow()
        if let indexPath = indexPath {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }

        var trackIndex: Int? = find(self.audioFiles, AudioPlayer.sharedAudioPlayer.currentTrack!)
        if let trackIndex = trackIndex {
            var indexPath = NSIndexPath(forRow: trackIndex, inSection: 0)
            self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
    }
    
    // MARK: - DirectoryWatcherDelegate
    
    func directoryDidChange(folderWatcher: DirectoryWatcher!) {
        self.reloadData()
    }
    
}
