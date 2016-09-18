//
//  AuxNavigationController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/18/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

class AuxNavigationController: UINavigationController {
    
    var auxPlayerView: AuxPlayerView!

    override func viewDidLoad() {
        super.viewDidLoad()

        self.auxPlayerView = NSBundle.mainBundle().loadNibNamed("AuxPlayerView", owner: self, options: nil)![0] as! AuxPlayerView
        self.auxPlayerView.frame.origin = CGPoint(x: 0, y: self.view.frame.height - self.auxPlayerView.thumbnailControlsViewHeight.constant)
        self.auxPlayerView.frame.size = CGSize(width: self.view.frame.width, height: self.view.frame.height + self.auxPlayerView.thumbnailControlsViewHeight.constant)
        self.view.addSubview(self.auxPlayerView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
