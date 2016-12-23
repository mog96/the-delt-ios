//
//  NewAlertViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 12/23/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

class NewAlertViewController: UIViewController {
    
    @IBOutlet weak var subjectTextView: UITextView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var photoImageView: UIImageView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Actions

extension NewAlertViewController {
    @IBAction func onCancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCameraButtonTapped(_ sender: Any) {
        // UIImagePicker
    }
    
    @IBAction func onPostButtonTapped(_ sender: Any) {
        // Post.
    }
}
