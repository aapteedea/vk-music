//
//  DefaultTableViewCell.swift
//  vk-music
//
//  Created by Danylo Kostyshyn on 9/22/14.
//  Copyright (c) 2014 kostyshyn. All rights reserved.
//

import UIKit

class DefaultTableViewCell: UITableViewCell {

    @IBOutlet var albumCoverImageView: UIImageView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var artistLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var sizeLabel: UILabel!
    
    func configure() {
        albumCoverImageView.image = UIImage(named: "AlbumCoverPlaceHolder")
        titleLabel.text = nil
        artistLabel.text = nil
        durationLabel.text = nil
        sizeLabel.text = nil
        
        titleLabel.textColor = UIColor.blackColor()
        artistLabel.textColor = UIColor.darkGrayColor()
        durationLabel.textColor = UIColor.darkGrayColor()
        sizeLabel.textColor = UIColor.darkGrayColor()
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        configure()
    }
    
    override func prepareForReuse() {
        configure()
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        if (selected) {
            let color = tintColor
            titleLabel.textColor = color
            artistLabel.textColor = color
            durationLabel.textColor = color
            sizeLabel.textColor = color
        } else {
            titleLabel.textColor = UIColor.blackColor()
            artistLabel.textColor = UIColor.darkGrayColor()
            durationLabel.textColor = UIColor.darkGrayColor()
            sizeLabel.textColor = UIColor.darkGrayColor()
        }
        
    }

}
