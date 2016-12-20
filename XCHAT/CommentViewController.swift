//
//  CommentViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/24/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse
import ParseUI

// Communicates to presenter the comment entered for the given photo.
protocol CommentViewControllerDelegate {
    func commentViewController(didEnterComment comment: String)
}

class CommentViewController: UIViewController, UITextViewDelegate {

    var photo: NSMutableDictionary!
    var delegate: CommentViewControllerDelegate?
    
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var commentTextView: UITextView!
    
    
    // MARK: View Defaults
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setPlaceholderText()
        
        let pfImageView = PFImageView()
        
        pfImageView.image = UIImage(named: "ROONEY")
        
        pfImageView.file = photo?.value(forKey: "imageFile") as? PFFile
        pfImageView.load { (image: UIImage?, error: Error?) -> Void in
            if let error = error {
                // Log details of the failure
                print("Error: \(error) \(error._userInfo)")
                
            } else {
                self.photoImageView.image = image
            }
        }
        
        self.photoImageView.clipsToBounds = true
        self.commentTextView.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        commentTextView.becomeFirstResponder()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: TextView
    
    func setPlaceholderText() {
        commentTextView.text = "What do you think?"
        commentTextView.textColor = UIColor.lightGray
    }
    
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        if textView.textColor == UIColor.lightGray {
            commentTextView.text = ""
            commentTextView.textColor = UIColor.black
        }
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        if commentTextView.text!.characters.count == 0 {
            setPlaceholderText()
            commentTextView.resignFirstResponder()
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func onPostButtonTapped(_ sender: AnyObject) {
        commentTextView.resignFirstResponder()
        
        // Prevents posting of blank comments
        if commentTextView.textColor != UIColor.gray {
            delegate?.commentViewController(didEnterComment: commentTextView.text)
            dismiss(animated: true, completion: { () -> Void in
                
                // code
            })
        }
    }
    @IBAction func onCancelButtonTapped(_ sender: AnyObject) {
        commentTextView.resignFirstResponder()
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onScreenTapped(_ sender: AnyObject) {
        view.endEditing(true)
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
