//
//  CaptionViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/24/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

// Communicates to presenter the caption entered for the given photo.
protocol CaptionViewControllerDelegate {
    func captionViewController(didEnterCaption caption: String?)
}

class CaptionViewController: UIViewController {
    
    var photo: UIImage!
    var delegate: CaptionViewControllerDelegate?

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var captionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setPlaceholderText()
        self.photoImageView.image = self.photo
        self.photoImageView.clipsToBounds = true
        self.captionTextView.delegate = self
        
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        captionTextView.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        self.view.endEditing(true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - TextView

extension CaptionViewController: UITextViewDelegate {
    func setPlaceholderText() {
        captionTextView.text = "Why is this dope?"
        captionTextView.textColor = UIColor.lightGray
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.textColor == UIColor.lightGray {
            captionTextView.text = ""
            captionTextView.textColor = UIColor.black
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if captionTextView.text!.characters.count == 0 {
            setPlaceholderText()
            captionTextView.resignFirstResponder()
        }
    }
}


// MARK: - Actions

extension CaptionViewController {
    @IBAction func onPostButtonTapped(_ sender: AnyObject) {
        captionTextView.resignFirstResponder()
        
        // Avoids sending delegate placeholder text.
        if captionTextView.text.characters.count > 0 {
            delegate?.captionViewController(didEnterCaption: captionTextView.text)
        } else {
            delegate?.captionViewController(didEnterCaption: nil)
        }
        
        dismiss(animated: true, completion: { () -> Void in
            
            // code
        })
    }
    
    @IBAction func onCancelButtonTapped(_ sender: AnyObject) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onScreenTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
}
