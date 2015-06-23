//
//  SearchResultCell.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 8/6/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import UIKit

protocol SearchResultCellDelegate {
    func searchResultCell(searchResultCell: SearchResultCell!, downloadButtonPressed downloadButton: UIButton!)
    func searchResultCell(searchResultCell: SearchResultCell!, stopButtonPressed stopButton: ProgressButton!)
}

enum SearchResultCellState {
    case Normal
    case Progress
    case Complete
}

class SearchResultCell: UITableViewCell, ProgressButtonDelegate {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var artistLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var bitrateLabel: UILabel!

    @IBOutlet weak var progressButton: ProgressButton!
    @IBOutlet weak var downloadButton: UIButton!
    
    var delegate: SearchResultCellDelegate?
    
    var state: SearchResultCellState! = .Normal {
        didSet {
            if state == .Normal {
                progressButton.hidden = true
                downloadButton.hidden = false
            } else if state == .Progress {
                progressButton.hidden = false
                downloadButton.hidden = true
            } else if state == .Complete {
                progressButton.hidden = true
                downloadButton.hidden = true
            }
        }
    }
    
    func configure() {
        self.titleLabel.text = nil
        self.artistLabel.text = nil
        self.durationLabel.text = nil
        self.bitrateLabel.text = nil

        self.progressButton.configure()
        self.progressButton.delegate = self
        self.progressButton.progress = 0.0
        
        self.state = .Normal
        
        self.titleLabel.textColor = UIColor.blackColor()
        self.artistLabel.textColor = UIColor.darkGrayColor()
        self.durationLabel.textColor = UIColor.darkGrayColor()
        self.bitrateLabel.textColor = UIColor.darkGrayColor()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        self.configure()
    }

    override func prepareForReuse() {
        self.configure()
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        if (selected) {
            let color = tintColor
            self.titleLabel.textColor = color
            self.artistLabel.textColor = color
            self.durationLabel.textColor = color
            self.bitrateLabel.textColor = color
        } else {
            self.titleLabel.textColor = UIColor.blackColor()
            self.artistLabel.textColor = UIColor.darkGrayColor()
            self.durationLabel.textColor = UIColor.darkGrayColor()
            self.bitrateLabel.textColor = UIColor.darkGrayColor()
        }
    }

    @IBAction func downloadButtonPressed(sender: AnyObject) {
        self.state = .Progress
        
        self.delegate?.searchResultCell(self, downloadButtonPressed: downloadButton)
    }

    @IBAction func progressButtonPressed(sender: AnyObject) {
        self.state = .Normal

        self.delegate?.searchResultCell(self, stopButtonPressed: progressButton)
    }

    // MARK: - ProgressButtonDelegate
    
    func progressButton(progressButton: ProgressButton, didUpdateProgress progress: Double) {
        if progress >= 1.0 {
            self.state = .Complete
        }
    }
}
