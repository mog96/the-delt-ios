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
}

class PhotoVideoCell: UITableViewCell {
    
    @IBOutlet weak var controlsView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var videoPlayerView: UIView!
    
    var videoPlayer: MPMoviePlayerController?
    var videoUrl: URL?
    
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
    }
    
    func setUpCell(_ photo: NSMutableDictionary?) {
        self.videoPlayer = nil
        
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
                
                self.videoUrl = URL(string: file.url!)!
                
                // Enable cell tap.
                let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(PhotoVideoCell.onControlsViewTapped))
                self.controlsView.addGestureRecognizer(tapGestureRecognizer)
                
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
            
        } else {
            
            // Error.
            self.photoImageView.backgroundColor = UIColor.red
        }
    }
    
    
    // MARK: - Actions
    
    func onControlsViewTapped() {
        if self.photoImageView.isHidden {
            self.videoFinished()
            
        } else {
            if self.videoPlayer == nil {
                self.addVideoPlayer(contentUrl: self.videoUrl!, containerView: self.videoPlayerView, preview: self.photoImageView)
            }
            
            print("PLAYING VIDEO WITH URL", self.videoUrl!)
            
            self.videoPlayer?.play()
            self.photoImageView.isHidden = true
        }
    }
    
    
    // MARK: - Video Player
    
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
    }
    
}
