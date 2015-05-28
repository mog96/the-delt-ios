//
//  NewEventViewController.swift
//  xchat-pat
//
//  Created by Pat Boonyarittipong on 5/18/15.
//  Copyright (c) 2015 patboony. All rights reserved.
//

import UIKit

// FIXME: ADD EVENT SCROLL VIEW NOT WORKING

// TODO:
// - Add check that endDate succeed startDate
// - Reverse animate startDatePicker on endDatePicker changed?

class NewEventViewController: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var artworkImage: UIImage?
    var calendarViewController: CalendarViewController?
    
    let placeholders = ["What?", "Where?", "Describe"]
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var nameTextView: UITextView!
    @IBOutlet weak var nameTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var locationTextView: UITextView!
    @IBOutlet weak var locationTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionTextView: UITextView!
    @IBOutlet weak var descriptionTextViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var artworkButton: UIButton!
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    // var textViewHeightConstraint = NSLayoutConstraint()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        nameTextView.delegate = self
        setPlaceholderText(nameTextView)
        locationTextView.delegate = self
        setPlaceholderText(locationTextView)
        descriptionTextView.delegate = self
        setPlaceholderText(descriptionTextView)
        
        startDatePicker.addTarget(self, action: "onDateChanged", forControlEvents: UIControlEvents.ValueChanged)
        onDateChanged()
        
        errorView.layer.cornerRadius = 60
        errorView.clipsToBounds = true
        errorLabel.textColor = UIColor.whiteColor()
        
        nameTextView.becomeFirstResponder()
        
        /*
        POTENTIAL TEXT VIEW RESIZING METHOD
        textViewHeightConstraint = NSLayoutConstraint(item: nameTextView, attribute: NSLayoutAttribute.Height, relatedBy: NSLayoutRelation.Equal, toItem: nil, attribute: NSLayoutAttribute.NotAnAttribute, multiplier: 0.1, constant: 100)
        scrollView.addConstraint(textViewHeightConstraint)
        */
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: TextView Protocol Implementations
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        if textView.textColor == UIColor.lightGrayColor() {
            textView.text = ""
            textView.textColor = UIColor.blackColor()
        }
        return true
    }
    
    func textViewShouldEndEditing(textView: UITextView) -> Bool {
        if textView.text == "" {
            setPlaceholderText(textView)
        }
        return true
    }
    
    func textViewDidChange(textView: UITextView) {
        resizeTextView(textView)
        
        // User deletes all text in the TextView.
        if count(textView.text) == 0 {
            setPlaceholderText(textView)
            textView.resignFirstResponder()
        }
    }
    
    
    // MARK: TextView Helpers
    
    func setPlaceholderText(textView: UITextView) {
        if textView == nameTextView {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                textView.text = self.placeholders[0]
            })
            
        } else if textView == locationTextView {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                textView.text = self.placeholders[1]
            })
            
        } else {
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                textView.text = self.placeholders[2]
            })
        }
        textView.textColor = UIColor.lightGrayColor()
    }
    
    func resizeTextView(textView: UITextView) {
        if textView == nameTextView {
            nameTextViewHeightConstraint.constant = nameTextView.contentSize.height
        } else if textView == locationTextView {
            locationTextViewHeightConstraint.constant = locationTextView.contentSize.height
        } else if textView == descriptionTextView {
            descriptionTextViewHeightConstraint.constant = descriptionTextView.contentSize.height
        }
    }
    
    
    // MARK: Event Handlers
    
    func onDateChanged() {
        let calendar = NSCalendar.currentCalendar()
        var components = NSDateComponents()
        components.hour = 1
        
        var endDate = calendar.dateByAddingComponents(components, toDate: startDatePicker.date, options: nil)
        endDatePicker.setDate(endDate!, animated: true)
    }
    
    
    // MARK: Actions
    
    @IBAction func onPostButtonTapped(sender: AnyObject) {
        
        // User forgets to enter name.
        if nameTextView.text == placeholders[0] {
            
            // FIXME: NOT ANIMATIONG PROPERLY
            UIView.animateWithDuration(100, delay: 0, options: nil, animations: { () -> Void in
                self.errorView.hidden = false
            }, completion: { (complete: Bool) -> Void in
                UIView.animateWithDuration(10, delay: 10, options: nil, animations: { () -> Void in
                    self.errorView.hidden = true
                }, completion: nil)
            })
            
        } else {
            var event = PFObject(className: "Event")
            
            event["name"] = nameTextView.text
            
            if locationTextView.text != placeholders[1] {
                event["location"] = locationTextView.text
            }
            if descriptionTextView.text != placeholders[2] {
                event["description"] = descriptionTextView.text
            }
            
            event["startTime"] = startDatePicker.date
            event["endTime"] = endDatePicker.date
            event["ceatedBy"] = PFUser.currentUser()?.valueForKey("username")
            
            if artworkImage != nil {
                let artworkImageData = UIImageJPEGRepresentation(artworkImage, 100)
                let artwork = PFFile(name: "artwork.jpeg", data: artworkImageData)
                event["artwork"] = artwork
            }
            
            event.saveInBackgroundWithBlock { (result: Bool, error: NSError?) -> Void in
                if error != nil {
                    println(error?.description)
                } else {
                    self.dismissViewControllerAnimated(true, completion: { () -> Void in
                        self.calendarViewController?.refreshData()
                    })
                }
            }
        }
    }
    
    @IBAction func onCancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onScreenTapped(sender: AnyObject) {
        println("DETECTED")
        view.endEditing(true)
    }
    
    @IBAction func onArtworkButtonTapped(sender: AnyObject) {
        let imageVC = UIImagePickerController()
        imageVC.delegate = self
        imageVC.allowsEditing = true
        imageVC.sourceType = .PhotoLibrary
        presentViewController(imageVC, animated: true, completion: nil)  // FIXME: Causes warning 'Presenting view controllers on detached view controllers is discouraged'
    }
    
    
    // MARK: ImagePickerController
    
    // Triggered when the user finishes taking an image. Saves the chosen image to our temporary
    // uploadPhoto variable, and dismisses the image picker view controller. Once the image picker
    // view controller is dismissed (a.k.a. inside the completion handler) we modally segue to
    // show the "Location selection" screen. --Nick Troccoli
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        artworkImage = info[UIImagePickerControllerEditedImage] as? UIImage
        dismissViewControllerAnimated(true, completion: { () -> Void in
            
            self.artworkButton.setBackgroundImage(self.artworkImage, forState: UIControlState.Normal)
            self.artworkButton.setTitle("", forState: UIControlState.Normal)
        })
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
