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

class AlertComposeViewController: ContentViewController, UINavigationControllerDelegate {

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

extension AlertComposeViewController {
    @IBAction func onCancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onCameraButtonTapped(_ sender: Any) {
        self.present(self.chooseMediaAC, animated: true, completion: nil)
    }
    
    @IBAction func onPhotoTapped(_ sender: Any) {
        // Present image picker again
    }
    
    @IBAction func onScreenTapped(_ sender: Any) {
        self.view.endEditing(true)
    }
}
