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
    
    @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer!
    @IBOutlet weak var thumbnailControlsTapGestureRecognizer: UITapGestureRecognizer!
    
    var originalOrigin: CGPoint!
    
    override func awakeFromNib() {
        let playbackButtons = [self.thumbnailPreviousButton, self.thumbnailPlayButton, self.thumbnailNextButton,
                               self.previousButton, self.playButton, self.nextButton]
        for playbackButton in playbackButtons {
            playbackButton.setNeedsLayout()
            playbackButton.layoutIfNeeded()
            playbackButton.layer.cornerRadius = playbackButton.frame.width / 2
            playbackButton.clipsToBounds = true
        }
    }
}


// MARK: - Helpers

extension AuxPlayerView {
    func showAuxPlayerView() {
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            self.frame.origin = CGPoint(x: 0, y: -self.thumbnailControlsViewHeight.constant)
            }, completion: { (finished: Bool) -> Void in
                // Completion.
        })
    }
    
    func hideAuxPlayerView() {
        UIView.animateWithDuration(0.7, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            self.frame.origin = CGPoint(x: 0, y: self.superview!.frame.height - self.thumbnailControlsViewHeight.constant)
            }, completion: { (finished: Bool) -> Void in
                // Completion.
        })
    }
}


// MARK: - Actions

extension AuxPlayerView {
    
    // Assumes this view has superview.
    @IBAction func onPanGesture(sender: AnyObject) {
        print("PANNED")
        
        let translation = sender.translationInView(self.superview)
        let velocity = sender.velocityInView(self.superview)
        
        if sender.state == UIGestureRecognizerState.Began {
            self.originalOrigin = self.frame.origin
            
        } else if sender.state == UIGestureRecognizerState.Changed {
            let newY = self.originalOrigin.y + translation.y
            let offsetNewY = newY + self.thumbnailControlsViewHeight.constant
            if offsetNewY >= 0 && newY <= self.superview!.frame.height  {
                self.frame.origin.y = newY
            }
            
        } else if sender.state == UIGestureRecognizerState.Ended {
            if velocity.y < 0 {
                self.showAuxPlayerView()
                self.superview?.endEditing(true)
            } else {
                self.hideAuxPlayerView()
            }
        }
    }
    
    @IBAction func onThumbnailControlsTapped(sender: AnyObject) {
        self.showAuxPlayerView()
    }
}
