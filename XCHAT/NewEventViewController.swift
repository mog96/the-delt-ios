//
//  NewEventViewController.swift
//  xchat-pat
//
//  Created by Pat Boonyarittipong on 5/18/15.
//  Copyright (c) 2015 patboony. All rights reserved.
//

import UIKit
import MBProgressHUD
import Parse

// FIXME: ADD EVENT SCROLL VIEW NOT WORKING

@objc protocol NewEventViewControllerDelegate {
    func refreshCurrentEvents(completion completion: (() -> ()))
}

class NewEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NewEventDelegate {
    
    var artworkImage: UIImage?
    
    @IBOutlet weak var tableView: UITableView!
    var eventDescriptionCell: EventDescriptionTableViewCell!
    var startDatePickerCell: StartDatePickerTableViewCell!
    var endDatePickerCell: EndDatePickerTableViewCell!
    
    var delegate: NewEventViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 126
        self.tableView.rowHeight = UITableViewAutomaticDimension
        
        self.eventDescriptionCell = self.tableView.dequeueReusableCellWithIdentifier("EventDescriptionCell") as! EventDescriptionTableViewCell
        self.eventDescriptionCell.newEventDelegate = self
        self.startDatePickerCell = self.tableView.dequeueReusableCellWithIdentifier("StartDatePickerCell") as! StartDatePickerTableViewCell
        self.endDatePickerCell = self.tableView.dequeueReusableCellWithIdentifier("EndDatePickerCell") as! EndDatePickerTableViewCell
        self.startDatePickerCell.startDateDelegate = self.endDatePickerCell
    }
    
    override func viewDidAppear(animated: Bool) {
        if self.eventDescriptionCell.nameTextField.text?.characters.count == 0 {
            self.eventDescriptionCell.nameTextField.becomeFirstResponder()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Table View

extension NewEventViewController {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return self.eventDescriptionCell
        case 1:
            self.startDatePickerCell.setDateToNextHour()
            return self.startDatePickerCell
        default:
            return self.endDatePickerCell
        }
    }
}


// MARK: - ImagePickerController

extension NewEventViewController {
    // Triggered when the user finishes taking an image. Saves the chosen image to our temporary
    // uploadPhoto variable, and dismisses the image picker view controller. Once the image picker
    // view controller is dismissed (a.k.a. inside the completion handler) we modally segue to
    // show the "Location selection" screen. --Nick Troccoli
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.artworkImage = info[UIImagePickerControllerEditedImage] as? UIImage
        self.eventDescriptionCell.artworkButton.setImage(self.artworkImage, forState: .Normal)
        self.eventDescriptionCell.artworkButton.setTitle("", forState: .Normal)
        self.dismissViewControllerAnimated(true, completion: nil)
    }
}


// MARK: - Actions

extension NewEventViewController {
    @IBAction func onPostButtonTapped(sender: AnyObject) {
        print("POSTING")
        
        // User forgets to enter name.
        if self.eventDescriptionCell.nameTextField.text == "" {
            let alert = UIAlertController(title: "Add Event Title", message: "Give your event a name!", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
            
        } else {
            let event = PFObject(className: "Event")
            
            event["name"] = self.eventDescriptionCell.nameTextField.text
            
            if self.eventDescriptionCell.locationTextField.text?.characters.count > 0 {
                event["location"] = self.eventDescriptionCell.locationTextField.text
            }
            if self.eventDescriptionCell.descriptionTextView.text.characters.count > 0 {
                event["description"] = self.eventDescriptionCell.descriptionTextView.text
            }
            
            event["startTime"] = self.startDatePickerCell.eventDatePicker.date
            event["endTime"] = self.endDatePickerCell.eventDatePicker.date
            event["createdBy"] = PFUser.currentUser()?.valueForKey("username")
            
            if artworkImage != nil {
                let artworkImageData = UIImageJPEGRepresentation(artworkImage!, 100)
                let artwork = PFFile(name: "artwork.jpeg", data: artworkImageData!)
                event["artwork"] = artwork
            }
            
            let currentHUD = MBProgressHUD.showHUDAddedTo(self.view, animated: true)
            currentHUD.label.text = "Posting Event..."
            event.saveInBackgroundWithBlock { (result: Bool, error: NSError?) -> Void in
                if error != nil {
                    currentHUD.hideAnimated(true)
                    print(error?.description)
                    let alertVC = UIAlertController(title: "Unable to Post Event", message: "Please try again.", preferredStyle: .Alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .Default, handler: nil))
                    self.presentViewController(alertVC, animated: true, completion: nil)
                } else {
                    self.delegate?.refreshCurrentEvents(completion: {
                        currentHUD.hideAnimated(true)
                        self.dismissViewControllerAnimated(true, completion: nil)
                    })
                }
            }
        }
    }
    
    @IBAction func onCancelButtonTapped(sender: AnyObject) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    @IBAction func onScreenTapped(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func onPanGesture(sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    func onArtworkButtonTapped() {
        let imageVC = UIImagePickerController()
        imageVC.delegate = self
        imageVC.allowsEditing = true
        imageVC.sourceType = .PhotoLibrary
        presentViewController(imageVC, animated: true, completion: nil)  // FIXME: Causes warning 'Presenting view controllers on detached view controllers is discouraged'
    }
}
