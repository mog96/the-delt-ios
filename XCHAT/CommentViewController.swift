//
//  CommentViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 5/24/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

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
        
        pfImageView.file = photo?.valueForKey("imageFile") as? PFFile
        pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
            if let error = error {
                // Log details of the failure
                print("Error: \(error) \(error.userInfo)")
                
            } else {
                self.photoImageView.image = image
            }
        }
        
        self.photoImageView.clipsToBounds = true
        self.commentTextView.delegate = self
    }
    
    override func viewDidAppear(animated: Bool) {
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
        commentTextView.textColor = UIColor.lightGrayColor()
    }
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView.textColor == UIColor.lightGrayColor() {
            commentTextView.text = ""
            commentTextView.textColor = UIColor.blackColor()
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        if commentTextView.text!.characters.count == 0 {
            setPlaceholderText()
            commentTextView.resignFirstResponder()
        }
    }
    
    
    // MARK: Actions
    
    @IBAction func onPostButtonTapped(sender: AnyObject) {
        commentTextView.resignFirstResponder()
        
        // Prevents posting of blank comments
        if commentTextView.textColor != UIColor.grayColor() {
            delegate?.commentViewController(didEnterComment: commentTextView.text)
            dismissViewControllerAnimated(true, completion: { () -> Void in
                
                // code
            })
        }
    }
    @IBAction func onCancelButtonTapped(sender: AnyObject) {
        commentTextView.resignFirstResponder()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onScreenTapped(sender: AnyObject) {
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
