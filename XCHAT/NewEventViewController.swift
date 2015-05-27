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
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var locationTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var startDatePicker: UIDatePicker!
    @IBOutlet weak var endDatePicker: UIDatePicker!
    @IBOutlet weak var artworkButton: UIButton!
    
    @IBOutlet weak var errorView: UIView!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        startDatePicker.addTarget(self, action: "onDateChanged", forControlEvents: UIControlEvents.ValueChanged)
        onDateChanged()
        
        errorView.layer.cornerRadius = 60
        errorView.clipsToBounds = true
        errorLabel.textColor = UIColor.whiteColor()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // Event Handlers
    
    func onDateChanged() {
        let calendar = NSCalendar.currentCalendar()
        var components = NSDateComponents()
        components.hour = 1
        
        var endDate = calendar.dateByAddingComponents(components, toDate: startDatePicker.date, options: nil)
        endDatePicker.setDate(endDate!, animated: true)
    }
    
    
    // MARK: Actions
    
    @IBAction func onPostButtonTapped(sender: AnyObject) {
        if count(nameTextField.text) == 0 {
            
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
            
            event["name"] = nameTextField.text
            event["startTime"] = startDatePicker.date
            event["endTime"] = endDatePicker.date
            
            if count(locationTextField.text) > 0 {
                event["location"] = locationTextField.text
            }
            if count(descriptionTextField.text) > 0 {
                event["description"] = descriptionTextField.text
            }
            
            // FIXME: IMPLEMENT CURRNET USER
            // event["author"] = PFUser.currentUser()?.username!
            
            if artworkButton.titleLabel?.text == "" {
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
