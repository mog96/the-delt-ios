//
//  AuxPlayerView.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/18/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

class AuxPlayerView: UIView {

    @IBOutlet weak var thumbnailArtworkImageView: UIImageView!
    @IBOutlet weak var thumbnailPreviousButton: UIButton!
    @IBOutlet weak var thumbnailPlayButton: UIButton!
    @IBOutlet weak var thumbnailNextButton: UIButton!
    @IBOutlet weak var thumbnailControlsViewHeight: NSLayoutConstraint!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var playbackProgressView: UIProgressView!
    @IBOutlet weak var previousButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    @IBOutlet weak var timeElapsedLabel: UILabel!
    @IBOutlet weak var timeRemainingLabel: UILabel!
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var artistAlbumNameLabel: UILabel!
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
}
