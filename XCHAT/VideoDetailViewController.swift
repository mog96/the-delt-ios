//
//  VideoDetailViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 3/16/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import AVKit
import MediaPlayer
import Parse
import PureLayout

class VideoDetailViewController: UIViewController {
    
    @IBOutlet weak var videoPlayerView: UIView!
    // var videoPlayer: MPMoviePlayerController!
    var videoPlayer: AVPlayer!
    var videoPlayerLayer: AVPlayerLayer!
    var videoURL: NSURL?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        print("VIDEO URL: ", self.videoURL)
        self.addVideoPlayer()
        self.videoPlayer.play()

        /*
        // Load video.
        self.file.getDataInBackgroundWithBlock {(videoData: NSData?, error: NSError?) -> Void in
            if let error = error {
                print("Error: \(error) \(error.userInfo)")
                
            } else {
                
                print("FUCK PF")
                
                // Write file.
                let paths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
                let documentsDirectory = paths[0]
                let path = documentsDirectory + "fdis.mp4"
                videoData?.writeToFile(path, atomically: true)
                let videoUrl = NSURL(fileURLWithPath: path)
                
                // self.addVideoPlayer(contentUrl: videoUrl, containerView: self.videoPlayerView, preview: nil)
                // self.videoPlayer.play()
                
                
            }
        }
        */
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: - Video Player
    
    /*
    func addVideoPlayer() {
        self.videoPlayer = MPMoviePlayerController(contentURL: self.videoURL)
        self.videoPlayer.view.frame = CGRectMake(0, 0, self.videoPlayerView.frame.width, self.videoPlayerView.frame.height)
        
        self.videoPlayer.controlStyle = MPMovieControlStyle.Fullscreen
        self.videoPlayer.scalingMode = MPMovieScalingMode.AspectFit
        self.videoPlayer.contentURL = self.videoURL
        self.videoPlayer.backgroundView.backgroundColor = UIColor.clearColor()
        self.videoPlayer.shouldAutoplay = true
        
        print("ADDING PLAYER")
        
        // NSNotificationCenter.defaultCenter().addObserver(self, selector: "videoSizeAvailable", name: MPMovieNaturalSizeAvailableNotification, object: self.videoPlayer)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(VideoDetailViewController.videoFinished), name: MPMoviePlayerPlaybackDidFinishNotification, object: self.videoPlayer)
        
        self.videoPlayerView.addSubview(self.videoPlayer.view)
        self.videoPlayer.view.autoPinEdgesToSuperviewEdges()
        
        // Disable pinch gesture.
        for view in self.videoPlayer.view.subviews {
            for gestureRecognizer in view.gestureRecognizers! {
                if gestureRecognizer.isKindOfClass(UIPinchGestureRecognizer) {
                    view.removeGestureRecognizer(gestureRecognizer)
                }
            }
        }
    }
     
    func videoFinished() {
        self.videoPlayer.stop()
        self.videoPlayer.currentPlaybackTime = 0
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    */
    
    func addVideoPlayer() {
        self.videoPlayer = AVPlayer(URL: self.videoURL!)
        self.videoPlayerLayer = AVPlayerLayer(player: self.videoPlayer)
        self.videoPlayerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(self.videoPlayerLayer)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
