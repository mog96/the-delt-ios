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
// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

// FIXME: comparison operators with optionals were removed from the Swift Standard Libary.
// Consider refactoring the code to use the non-optional operators.
fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}


// FIXME: ADD EVENT SCROLL VIEW NOT WORKING

@objc protocol NewEventViewControllerDelegate {
    func refreshCurrentEvents(completion: @escaping (() -> ()))
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
        
        self.eventDescriptionCell = self.tableView.dequeueReusableCell(withIdentifier: "EventDescriptionCell") as! EventDescriptionTableViewCell
        self.eventDescriptionCell.newEventDelegate = self
        self.startDatePickerCell = self.tableView.dequeueReusableCell(withIdentifier: "StartDatePickerCell") as! StartDatePickerTableViewCell
        self.endDatePickerCell = self.tableView.dequeueReusableCell(withIdentifier: "EndDatePickerCell") as! EndDatePickerTableViewCell
        self.startDatePickerCell.startDateDelegate = self.endDatePickerCell
    }
    
    override func viewDidAppear(_ animated: Bool) {
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
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
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        self.artworkImage = info[UIImagePickerControllerEditedImage] as? UIImage
        self.eventDescriptionCell.artworkButton.setImage(self.artworkImage, for: UIControlState())
        self.eventDescriptionCell.artworkButton.setTitle("", for: UIControlState())
        self.dismiss(animated: true, completion: nil)
    }
}


// MARK: - Actions

extension NewEventViewController {
    @IBAction func onPostButtonTapped(_ sender: AnyObject) {
        print("POSTING")
        
        // User forgets to enter name.
        if self.eventDescriptionCell.nameTextField.text == "" {
            let alert = UIAlertController(title: "Add Event Title", message: "Give your event a name!", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
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
            event["createdBy"] = PFUser.current()?.value(forKey: "username")
            
            if artworkImage != nil {
                let artworkImageData = UIImageJPEGRepresentation(artworkImage!, 100)
                let artwork = PFFile(name: "artwork.jpeg", data: artworkImageData!)
                event["artwork"] = artwork
            }
            
            let currentHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            currentHUD.label.text = "Posting Event..."
            event.saveInBackground { (result: Bool, error: Error?) -> Void in
                if error != nil {
                    currentHUD.hide(animated: true)
                    print(error!.localizedDescription)
                    let alertVC = UIAlertController(title: "Unable to Post Event", message: "Please try again.", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertVC, animated: true, completion: nil)
                } else {
                    self.delegate?.refreshCurrentEvents(completion: {
                        currentHUD.hide(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }
        }
    }
    
    @IBAction func onCancelButtonTapped(_ sender: AnyObject) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onScreenTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    @IBAction func onPanGesture(_ sender: AnyObject) {
        self.view.endEditing(true)
    }
    
    func onArtworkButtonTapped() {
        let imageVC = UIImagePickerController()
        imageVC.delegate = self
        imageVC.allowsEditing = true
        imageVC.sourceType = .photoLibrary
        present(imageVC, animated: true, completion: nil)  // FIXME: Causes warning 'Presenting view controllers on detached view controllers is discouraged'
    }
}
