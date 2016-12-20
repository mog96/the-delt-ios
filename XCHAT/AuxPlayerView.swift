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
    
    @IBOutlet weak var thumbnailControlsTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var panGestureRecognizer: UIPanGestureRecognizer!
    
    var previousButtons = [UIButton]()
    var playButtons = [UIButton]()
    var nextButtons = [UIButton]()
    
    var originalOrigin: CGPoint!
    
    override func awakeFromNib() {
        self.playButtons = [self.thumbnailPlayButton, self.playButton]
        self.previousButtons = [self.thumbnailPreviousButton, self.previousButton]
        self.nextButtons = [self.thumbnailNextButton, self.nextButton]
        
        let playbackButtons = self.playButtons + self.previousButtons + self.nextButtons
        for playbackButton in playbackButtons {
            playbackButton.setNeedsLayout()
            playbackButton.layoutIfNeeded()
            playbackButton.layer.cornerRadius = playbackButton.frame.width / 2
            playbackButton.clipsToBounds = true
        }
        
        for pb in self.playButtons {
            // pb. // START HERE< assign action to each button
        }
    }
}


// MARK: - Helpers

extension AuxPlayerView {
    func showAuxPlayerView() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            self.frame.origin = CGPoint(x: 0, y: -self.thumbnailControlsViewHeight.constant)
            }, completion: { (finished: Bool) -> Void in
                // Completion.
        })
    }
    
    func hideAuxPlayerView() {
        UIView.animate(withDuration: 0.7, delay: 0, usingSpringWithDamping: 1.0, initialSpringVelocity: 0, options: [], animations: { () -> Void in
            self.frame.origin = CGPoint(x: 0, y: self.superview!.frame.height - self.thumbnailControlsViewHeight.constant)
            }, completion: { (finished: Bool) -> Void in
                // Completion.
        })
    }
}


// MARK: - Actions

extension AuxPlayerView {
    
    @IBAction func onThumbnailControlsTapped(_ sender: AnyObject) {
        self.showAuxPlayerView()
    }
    
    // Assumes this view has superview.
    @IBAction func onPanGesture(_ sender: AnyObject) {
        print("PANNED")
        
        let translation = sender.translation(in: self.superview)
        let velocity = sender.velocity(in: self.superview)
        
        if sender.state == UIGestureRecognizerState.began {
            self.originalOrigin = self.frame.origin
            
        } else if sender.state == UIGestureRecognizerState.changed {
            let newY = self.originalOrigin.y + translation.y
            let offsetNewY = newY + self.thumbnailControlsViewHeight.constant
            if offsetNewY >= 0 && newY <= self.superview!.frame.height  {
                self.frame.origin.y = newY
            }
            
        } else if sender.state == UIGestureRecognizerState.ended {
            if velocity.y < 0 {
                self.showAuxPlayerView()
                self.superview?.endEditing(true)
            } else {
                self.hideAuxPlayerView()
            }
        }
    }
    
    func onPlayButtonTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
}
