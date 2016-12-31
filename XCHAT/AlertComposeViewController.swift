//
//  AlertComposeViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 12/25/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import MBProgressHUD
import MediaPlayer
import MobileCoreServices
import Parse

@objc protocol AlertComposeViewControllerDelegate {
    @objc optional func refreshData(completion: @escaping (() -> ()))
    @objc optional func refreshData(savedObject object: AnyObject?, completion: @escaping (() -> ()))
}

class AlertComposeViewController: ContentViewController, UINavigationControllerDelegate {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var photoImageViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoImageViewLeadingHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var photoImageViewTrailingSpaceConstraint: NSLayoutConstraint!
    
    @IBOutlet var screenTapGestureRecognizer: UITapGestureRecognizer!
    @IBOutlet var photoTapGestureRecognizer: UITapGestureRecognizer!
    
    var chooseMediaAC: UIAlertController!
    var imagePickerVC: UIImagePickerController!
    
    var photo: UIImage?
    var video: PFFile?
    
    var delegate: AlertComposeViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.photoImageView.layer.cornerRadius = 3
        self.photoImageView.clipsToBounds = true
        
        self.screenTapGestureRecognizer.delegate = self
        self.photoTapGestureRecognizer.delegate = self
        
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
        
        self.imagePickerVC = UIImagePickerController()
        self.imagePickerVC.delegate = self
        // self.imagePickerVC.allowsEditing = true
        self.imagePickerVC.mediaTypes = [kUTTypeImage as String, kUTTypeMovie as String]
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

// MARK: - Image Picker Controller

extension AlertComposeViewController: UIImagePickerControllerDelegate {
    fileprivate func presentImagePicker(usingPhotoLibrary photoLibrary: Bool) {
        if photoLibrary {
            self.imagePickerVC.sourceType = .photoLibrary
            self.imagePickerVC.navigationBar.tintColor = UIColor.red
            self.imagePickerVC.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .stop, target: imagePickerVC, action: nil)
        } else {
            self.imagePickerVC.sourceType = .camera
        }
        self.present(self.imagePickerVC, animated: true) {
            UIApplication.shared.setStatusBarStyle(.default, animated: true)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let currentHUD = MBProgressHUD.showAdded(to: self.view, animated: true)
        // Photo.
        if info[UIImagePickerControllerMediaType] as! String == kUTTypeImage as String {
            currentHUD.label.text = "Loading Photo..."
            self.photo = info[UIImagePickerControllerOriginalImage] as? UIImage // UIImagePickerControllerEditedImage
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
        
        let aspectRatio = self.photo!.size.width / self.photo!.size.height
        let newHeight = (UIScreen.main.bounds.width - (self.photoImageViewLeadingHeightConstraint.constant + self.photoImageViewTrailingSpaceConstraint.constant)) / aspectRatio
        UIView.animate(withDuration: 1, animations: {
            self.photoImageView.image = self.photo
            self.photoImageViewHeightConstraint.constant = newHeight
        })
        picker.dismiss(animated: true) {
            UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        }
    }
}


extension AlertComposeViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return true
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}


// MARK: - Actions

extension AlertComposeViewController {
    @IBAction func onCancelButtonTapped(_ sender: Any) {
        self.view.endEditing(true)
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCameraButtonTapped(_ sender: Any) {
        self.present(self.chooseMediaAC, animated: true, completion: nil)
    }
    
    @IBAction func onPhotoTapped(_ sender: Any) {
        print("PHOTO TAPPED")
        self.presentImagePicker(usingPhotoLibrary: true)
    }
    
    @IBAction func onScreenTapped(_ sender: Any) {
        print("SCREEN TAPPED")
        self.view.endEditing(true)
    }
}
