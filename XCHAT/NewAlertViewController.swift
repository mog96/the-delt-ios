//
//  NewAlertViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 12/23/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import MBProgressHUD
import MediaPlayer
import MobileCoreServices
import Parse

@objc protocol NewAlertViewControllerDelegate {
    func refreshData(completion: @escaping (() -> ()))
}

class NewAlertViewController: UIViewController, UINavigationControllerDelegate {
    
    @IBOutlet weak var subjectTextView: UITextView!
    @IBOutlet weak var messageTextView: UITextView!
    @IBOutlet weak var photoImageView: UIImageView!
    
    var chooseMediaAC: UIAlertController!
    
    var delegate: NewAlertViewControllerDelegate?
    
    var photo: UIImage?
    var video: PFFile?

    override func viewDidLoad() {
        super.viewDidLoad()

        self.chooseMediaAC = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        self.chooseMediaAC.addAction(UIAlertAction(title: "CLICK", style: .destructive, handler: { _ in      // FIXME: Using .Destructive to get red text color is a little hacky...
            self.presentImagePicker(usingPhotoLibrary: false)
        }))
        self.chooseMediaAC.addAction(UIAlertAction(title: "CHOOSE", style: .destructive, handler: { _ in
            self.presentImagePicker(usingPhotoLibrary: true)
        }))
        self.chooseMediaAC.addAction(UIAlertAction(title: "CANCEL", style: .cancel, handler: { _ in
            self.chooseMediaAC.dismiss(animated: true, completion: nil)
        }))
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Helpers

extension NewAlertViewController {
    func postAlert() {
        print("POSTING")
        
        // User forgets to enter alert subject.
        if self.subjectTextView.text == "" {
            let alert = UIAlertController(title: "Add Alert Subject", message: "Whatchu tryna say bro.", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            
        } else {
            let alert = PFObject(className: "Alert")
            
            alert["subject"] = self.subjectTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            if self.messageTextView.text.characters.count > 0 {
                alert["message"] = self.messageTextView.text
            }
            // alert["createdBy"] = PFUser.current()!.username!
            alert["author"] = PFUser.current()!
            alert["authorName"] = PFUser.current()!["name"]
            
            if self.photo != nil {
                let imageData = UIImageJPEGRepresentation(self.photo!, 100)
                let imageFile = PFFile(name: "image.jpeg", data: imageData!)
                alert["image"] = imageFile
                
                if self.video != nil {
                    alert["video"] = self.video
                }
            }
            
            let currentHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
            currentHUD.label.text = "Posting Alert..."
            alert.saveInBackground { (result: Bool, error: Error?) -> Void in
                if error != nil {
                    currentHUD.hide(animated: true)
                    print(error!.localizedDescription)
                    let alertVC = UIAlertController(title: "Unable to Post Alert", message: "Please try again.", preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alertVC, animated: true, completion: nil)
                } else {
                    self.delegate?.refreshData(completion: {
                        currentHUD.hide(animated: true)
                        self.dismiss(animated: true, completion: nil)
                    })
                }
            }
        }
    }
}


// MARK: - Image Picker Controller

extension NewAlertViewController: UIImagePickerControllerDelegate {
    fileprivate func presentImagePicker(usingPhotoLibrary photoLibrary: Bool) {
        let imagePickerVC = UIImagePickerController()
        imagePickerVC.delegate = self
        imagePickerVC.allowsEditing = true
        imagePickerVC.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
        if photoLibrary {
            imagePickerVC.sourceType = .photoLibrary
            imagePickerVC.navigationBar.tintColor = UIColor.red
            imagePickerVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: imagePickerVC, action: nil)
        } else {
            imagePickerVC.sourceType = .camera
        }
        self.present(imagePickerVC, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let currentHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        // Photo.
        if info[UIImagePickerControllerMediaType] as! String == kUTTypeImage as String {
            currentHUD.label.text = "Loading Photo..."
            self.photo = info[UIImagePickerControllerEditedImage] as? UIImage
        // Video.
        } else {
            currentHUD.label.text = "Rendering Video..."
            let videoUrl = info[UIImagePickerControllerMediaURL] as! URL
            let videoData = try? Data(contentsOf: videoUrl)
            self.video = PFFile(name: "video.mp4", data: videoData!)
            
            // Set video thumbnail image.
            let asset = AVAsset(url: videoUrl)
            let generator: AVAssetImageGenerator = AVAssetImageGenerator(asset: asset)
            let time = CMTimeMake(1, 1)
            let imageRef = try! generator.copyCGImage(at: time, actualTime: nil)
            self.photo = UIImage(cgImage: imageRef)
        }
        currentHUD.hide(animated: true)
        self.photoImageView.image = self.photo
        picker.dismiss(animated: true, completion: nil)
    }
}


// MARK: - Actions

extension NewAlertViewController {
    @IBAction func onCancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCameraButtonTapped(_ sender: Any) {
        self.present(self.chooseMediaAC, animated: true, completion: nil)
    }
    
    @IBAction func onPostButtonTapped(_ sender: Any) {
        self.postAlert()
    }
}
