//
//  NewEventViewController.swift
//  xchat-pat
//
//  Created by Pat Boonyarittipong on 5/18/15.
//  Copyright (c) 2015 patboony. All rights reserved.
//

import UIKit
import Parse

// FIXME: ADD EVENT SCROLL VIEW NOT WORKING

// TODO:
// - Add check that endDate succeed startDate
// - Reverse animate startDatePicker on endDatePicker changed?

class NewEventViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, NewEventDelegate {
    
    var artworkImage: UIImage?
    var calendarViewController: CalendarViewController?
    
    @IBOutlet weak var tableView: UITableView!
    var eventDescriptionCell: EventDescriptionTableViewCell!
    var startDatePickerCell: StartDatePickerTableViewCell!
    var endDatePickerCell: EndDatePickerTableViewCell!
    
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Table View
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            return self.eventDescriptionCell
        case 1:
            return self.startDatePickerCell
        default:
            return self.endDatePickerCell
        }
    }
    
    
    // MARK: Actions
    
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
            
            if self.eventDescriptionCell.locationTextField.text != "" {
                event["location"] = self.eventDescriptionCell.locationTextField.text
            }
            if self.eventDescriptionCell.descriptionTextView.text != self.eventDescriptionCell.descriptionTextViewPlaceholder {
                event["description"] = self.eventDescriptionCell.descriptionTextView.text
            }
            
            event["startTime"] = self.startDatePickerCell.eventDatePicker.date
            event["endTime"] = self.endDatePickerCell.eventDatePicker.date
            event["ceatedBy"] = PFUser.currentUser()?.valueForKey("username")
            
            if artworkImage != nil {
                let artworkImageData = UIImageJPEGRepresentation(artworkImage!, 100)
                let artwork = PFFile(name: "artwork.jpeg", data: artworkImageData!)
                event["artwork"] = artwork
            }
            
            event.saveInBackgroundWithBlock { (result: Bool, error: NSError?) -> Void in
                if error != nil {
                    print(error?.description)
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
        self.view.endEditing(true)
    }
    
    func onArtworkButtonTapped() {
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        self.artworkImage = info[UIImagePickerControllerEditedImage] as? UIImage
        dismissViewControllerAnimated(true, completion: { () -> Void in
            
            self.eventDescriptionCell.artworkButton.setBackgroundImage(self.artworkImage, forState: UIControlState.Normal)
            self.eventDescriptionCell.artworkButton.setTitle("", forState: UIControlState.Normal)
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
