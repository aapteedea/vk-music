//
//  SearchViewController.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 8/6/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import UIKit

class SearchViewController: TableViewController, UISearchBarDelegate, SearchResultCellDelegate {

    @IBOutlet var searchBar: UISearchBar!
    var songs: [Audio] = [Audio]() {
        didSet {
            self.playlist = Playlist(audios: songs)
        }
    }
    var playlist: Playlist? {
        didSet {
            AudioPlayer.sharedAudioPlayer.playlist = playlist
        }
    }

    required  init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "playerDidStartPlaying", name: AudioPlayerDidStartPlayingNotification, object: nil)
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.clearsSelectionOnViewWillAppear = false        
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
        return songs.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("searchResultCell", forIndexPath: indexPath) as! SearchResultCell
        cell.delegate = self

        var song = self.songs[indexPath.row]
        cell.titleLabel.text = song.title
        cell.artistLabel.text = song.artist
        cell.durationLabel.text = Utilities.prettifyTime(Double(song.duration))
        
        if (song.size > 0) {
            cell.bitrateLabel.text = "\(song.bitrate)k"
        } else {
            DataFetcher.audioInfo(song.remoteURL!, successBlock: { (size) -> Void in
                song.size = size
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
                })
            })
        }
        
        if let operation = song.downloadOperation {
            switch operation.downloadTask.state {
            case .Running:
                cell.state = .Progress
                cell.progressButton.setProgress(downloadProgressOfOperation: song.downloadOperation!)
            case .Completed:
                cell.state = .Complete
            default:
                cell.state = .Normal
            }
        }
        
        return cell
    }
    
    // MARK: - UITableVideDelegate
        
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if let track = playlist?.trackAtIndex(indexPath.row) {
            AudioPlayer.sharedAudioPlayer.playlist = self.playlist
            AudioPlayer.sharedAudioPlayer.play(track)
        }
        self.navigationController?.pushViewController(PlayerViewController.sharedInstance, animated: true)
    }

    // MARK: - UISearchBarDelegate
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        
        DataFetcher.searchAudio(searchBar.text, successBlock: { (songs) -> Void in
            self.songs = songs
            self.tableView.reloadData()
        })

        searchBar.resignFirstResponder()
    }
            
    // MARK: - SearchResultCellDelegate
    
    func searchResultCell(searchResultCell: SearchResultCell!, downloadButtonPressed downloadButton: UIButton!) {
        if let index = tableView.indexPathForCell(searchResultCell)?.row {
            var song = self.songs[index]
            var vkID = song.vkDictionary!.objectForKey("id") as! Int
            var fileName = "\(song.title!) - \(song.artist!)_\(vkID).mp3"

            song.downloadOperation = DownloadManager.sharedManager.startDownload(song.remoteURL!, suggestedFilename: fileName)
            searchResultCell.progressButton?.setProgress(downloadProgressOfOperation: song.downloadOperation!)
        }
    }

    func searchResultCell(searchResultCell: SearchResultCell!, stopButtonPressed stopButton: ProgressButton!) {
        if let indexPath = tableView.indexPathForCell(searchResultCell) {
            var song = self.songs[indexPath.row]
            if let operation = song.downloadOperation {
                operation.cancel()
                self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .None)
            }
        }
    }

    // MARK: - Notifications
    
    func playerDidStartPlaying() {
        var indexPath = self.tableView.indexPathForSelectedRow()
        if let indexPath = indexPath {
            self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        var trackIndex: Int? = find(self.songs, AudioPlayer.sharedAudioPlayer.currentTrack!)
        if let trackIndex = trackIndex {
            var indexPath = NSIndexPath(forRow: trackIndex, inSection: 0)
            self.tableView.selectRowAtIndexPath(indexPath, animated: false, scrollPosition: .None)
        }
    }

}
