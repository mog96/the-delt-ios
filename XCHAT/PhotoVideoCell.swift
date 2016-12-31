//
//  PhotoVideoCell.swift
//  XCHAT
//
//  Created by Mateo Garcia on 3/15/16.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
import Parse
import ParseUI

@objc protocol PhotoVideoCellDelegate {
    func presentVideoDetailViewController(videoFile file: PFFile)
    func updateFaved(_ photo: NSMutableDictionary?, didUpdateFaved faved: Bool)
}

class PhotoVideoCell: UITableViewCell {
    
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var videoPlayerView: UIView!
    var doubleTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet weak var playButton: UIButton!
    
    var photo: NSMutableDictionary?
    var videoPlayer: MPMoviePlayerController?
    var videoUrl: URL?
    var faved = false
    var doubleTapped = false
    
    weak var delegate: PhotoVideoCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    override func prepareForReuse() {
        self.photoImageView.image = nil
        self.videoPlayer = nil
        self.faved = false
        self.doubleTapped = false
        self.playButton.isHidden = true
    }
}


// MARK: - Setup

extension PhotoVideoCell {
    func setUpCell(_ photo: NSMutableDictionary?) {
        self.photo = photo
        self.videoPlayer = nil
        
        self.doubleTapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoVideoCell.onControlsViewDoubleTapped))
        self.doubleTapGestureRecognizer.numberOfTapsRequired = 2
        self.doubleTapGestureRecognizer.delegate = self
        self.controlsView.addGestureRecognizer(self.doubleTapGestureRecognizer)
        
        if let photo = photo {
            
            // Video.
            if let file = photo.value(forKey: "videoFile") as? PFFile {
                let pfImageView = PFImageView()
                
                // Temp image.
                pfImageView.image = UIImage(named: "ROONEY")
                
                // Load thumbnail image.
                pfImageView.file = photo.value(forKey: "imageFile") as? PFFile
                pfImageView.load { (image: UIImage?, error: Error?) -> Void in
                    if let error = error {
                        // Log details of the failure
                        print("Error: \(error) \(error.localizedDescription)")
                        
                    } else {
                        self.photoImageView.image = image
                    }
                }
                
                // Enable cell tap.
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoVideoCell.onControlsViewTapped))
                tapGestureRecognizer.delegate = self
                tapGestureRecognizer.require(toFail: self.doubleTapGestureRecognizer)
                self.controlsView.addGestureRecognizer(tapGestureRecognizer)
                
                self.videoUrl = URL(string: file.url!)!
                self.playButton.isHidden = false
                
                // Photo.
            } else if let file = photo.value(forKey: "imageFile") as? PFFile {
                print("IMAGE URL:", file.url)
                
                let pfImageView = PFImageView()
                
                // JUST FOR LOLZ
                pfImageView.image = UIImage(named: "ROONEY")
                
                pfImageView.file = file
                pfImageView.load { (image: UIImage?, error: Error?) -> Void in
                    if let error = error {
                        // Log details of the failure
                        print("Error: \(error) \(error.localizedDescription)")
                        
                    } else {
                        self.photoImageView.image = image
                    }
                }
            }
            
            if let favedBy = photo.value(forKey: "favedBy") as? [String] {
                if let username = PFUser.current()?.username {
                    
                    print("IS FAVED: \(favedBy.contains(username))")
                    
                    self.faved = favedBy.contains(username)
                    
                    print("SETTING FAVED: \(self.faved)")
                }
            }
            
        } else {
            
            // Error.
            self.photoImageView.backgroundColor = UIColor.red
        }
    }
}


// MARK: - Video Player

extension PhotoVideoCell {
    func addVideoPlayer(contentUrl: URL, containerView: UIView, preview: UIImageView?) {
        self.videoPlayer = MPMoviePlayerController(contentURL: contentUrl)
        self.videoPlayer!.view.frame = CGRect(x: 0, y: 0, width: containerView.frame.width, height: containerView.frame.height)
        
        self.videoPlayer!.controlStyle = .none
        self.videoPlayer!.scalingMode = MPMovieScalingMode.aspectFit
        self.videoPlayer!.contentURL = contentUrl
        self.videoPlayer!.backgroundView.backgroundColor = UIColor.clear
        self.videoPlayer!.shouldAutoplay = true
        
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoSizeAvailable", name: MPMovieNaturalSizeAvailableNotification, object: self.videoPlayer)
        NotificationCenter.default.addObserver(self, selector: #selector(PhotoVideoCell.videoFinished), name: NSNotification.Name.MPMoviePlayerPlaybackDidFinish, object: self.videoPlayer)
        
        containerView.addSubview(self.videoPlayer!.view)
        self.videoPlayer!.view.autoPinEdgesToSuperviewEdges()
        
        // Disable pinch gesture.
        for view in self.videoPlayer!.view.subviews {
            for gestureRecognizer in view.gestureRecognizers! {
                if gestureRecognizer.isKind(of: UIPinchGestureRecognizer.self) {
                    view.removeGestureRecognizer(gestureRecognizer)
                }
            }
        }
    }
    
    func videoSizeAvailable() {
        print("SIZE AVILABLE")
    }
    
    func removeVideoPlayer() {
        
        print("REMOVING PLAYER")
        
        self.videoFinished()
        self.videoPlayer = nil
        if let recognizers = self.controlsView.gestureRecognizers {
            for recognizer in recognizers {
                controlsView.removeGestureRecognizer(recognizer)
            }
        }
    }
    
    func videoFinished() {
        self.photoImageView.isHidden = false
        self.videoPlayer?.stop()
        self.videoPlayer?.currentPlaybackTime = 0
        self.playButton.isHidden = false
        self.playButton.isSelected = false
    }
}


// MARK: - Actions

extension PhotoVideoCell {
    @IBAction func onPlayButtonTapped(_ sender: Any) {
        self.onControlsViewTapped()
    }
    
    func onControlsViewTapped() {
        if self.photoImageView.isHidden {
            self.videoFinished()
            
        } else {
            self.playButton.isSelected = true
            UIView.transition(with: self.playButton, duration: 1, options: .transitionCrossDissolve, animations: { 
                self.playButton.isHidden = true
            }) { _ in
                
            }
            if self.videoPlayer == nil {
                self.addVideoPlayer(contentUrl: self.videoUrl!, containerView: self.videoPlayerView, preview: self.photoImageView)
            }
            
            print("PLAYING VIDEO WITH URL", self.videoUrl!)
            
            self.videoPlayer?.play()
            self.photoImageView.isHidden = true
        }
    }
    
    func onControlsViewDoubleTapped() {
        print("COOL")
        if !self.doubleTapped {
            self.delegate?.updateFaved(self.photo, didUpdateFaved: !self.faved)
            doubleTapped = true
        }
    }
}
