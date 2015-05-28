
//
//  EditableProfileViewController.swift
//  XCHAT
//
//  Created by Jim Cai on 5/21/15.
//  Copyright (c) 2015 Mateo Garcia. All rights reserved.
//

import UIKit

class EditableProfileViewController: UIViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var backgroundPhoto: UIImageView!
    @IBOutlet var backGround: UIView!
    @IBOutlet weak var nameText: UITextField!
    @IBOutlet weak var usernameText: UITextField!
    @IBOutlet weak var quoteText: UITextField!
    @IBOutlet weak var emailText: UITextField!
    @IBOutlet weak var email: UILabel!
    @IBOutlet weak var quote: UILabel!
    @IBOutlet weak var profilePicView: UIView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var realName: UILabel!
    var uploadImage: UIImage?
    var profilePicPicker: Bool = false
    
    @IBOutlet weak var realProfilePic: UIImageView!
    var currentUser = PFUser.currentUser()
    override func viewDidLoad() {
        super.viewDidLoad()
        nameText.tag = 0
        usernameText.tag = 1
        quoteText.tag = 2
        emailText.tag = 3
        
        var query = PFQuery(className: "User")
        var quote_text = currentUser?.objectForKey("quote") as? String
        var username_text = currentUser?.objectForKey("username") as? String
        var email_text = PFUser.currentUser()?.email
        var realname_text = currentUser?.objectForKey("name") as? String
        
        if let _=quote_text{
            self.quote.text = quote_text
        }else{
            self.quote.text = "Tap for your quote"
        }
        
        if let _=username_text{
            self.userName.text = username_text
        }else{
            self.userName.text = "Tap for your Username"
        }
        
        if let _=email_text{
            self.email.text = email_text
        }else{
            self.email.text = "Tap for your Email"
        }
        
        if let _=realname_text{
            self.realName.text = realname_text
        }else{
            self.realName.text = "Tap here to change your Name"
        }
        


        
        self.nameText.hidden = true
        self.usernameText.hidden = true
        self.emailText.hidden = true
        self.quoteText.hidden = true
        self.quote.hidden = false
        self.userName.hidden = false
        self.email.hidden = false
        self.realName.hidden = false
        
        
        if let photo: PFFile = PFUser.currentUser()?.objectForKey("photo") as! PFFile?{
            var pfImageView = PFImageView()
            pfImageView.image = UIImage(named: "profilePic")
            pfImageView.file = photo as? PFFile
            pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
                if error == nil {
                    self.realProfilePic.image = image
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
            
        }
        
        if let photo: PFFile = PFUser.currentUser()?.objectForKey("backgroundphoto") as! PFFile?{
            var pfImageView = PFImageView()
            pfImageView.image = UIImage(named: "back")
            println(photo)
            pfImageView.file = photo as! PFFile
            pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
                if error == nil {
                    self.backgroundPhoto.image = image
                    self.view.sendSubviewToBack(self.backgroundPhoto)
                } else {
                    // Log details of the failure
                    println("Error: \(error!) \(error!.userInfo!)")
                }
            }
            
        }
        
        
 
                // Do any additional setup after loading the view.
    }

    func textFieldDidEndEditing(textField: UITextField) {
        textField.resignFirstResponder()

        if count(quoteText.text)==0{
            currentUser?.setObject(quote.text!, forKey: "quote")
        }
        else{
            currentUser?.setObject(quoteText.text!, forKey: "quote")
        }
        if count(usernameText.text)==0{

            currentUser?.setObject(userName.text!, forKey: "username")
        }
        else{
            currentUser?.setObject(usernameText.text!, forKey: "username")
        }
        if count(nameText.text)==0{
            
            currentUser?.setObject(realName.text!, forKey: "name")
        }
        else{
            currentUser?.setObject(nameText.text!, forKey: "name")
        }
        

        currentUser?.saveInBackgroundWithBlock({ (result:Bool, error:NSError?) -> Void in
            if error != nil {
                // Print some kind of error to clients
                println("unable to send this message")
                println(error?.description)
            } else {
                self.viewDidLoad()
            }
        })

    }
 
    
    @IBAction func tapBackground(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
        self.viewDidLoad()
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        var newString = textField.text
        textField.hidden = true
        switch(textField.tag){
        case 0:
            realName.text = newString
            realName.hidden = false
            break
        case 1:
            userName.text = newString
            userName.hidden = false
            break
        case 2:
            quote.text = newString
            quote.hidden = false
            break
        case 3:
            email.text = newString
            email.hidden = false
            break
        default:
            break
        }
        
        return true

    }
    
    @IBAction func nameTapped(sender: UITapGestureRecognizer) {
        realName.hidden = true
        nameText.hidden = false
        nameText.becomeFirstResponder()
        nameText.delegate = self

    }
    
    @IBAction func usernametapped(sender: UITapGestureRecognizer) {
        userName.hidden = true
        usernameText.hidden = false
        usernameText.becomeFirstResponder()
        usernameText.delegate = self

    }
    @IBAction func pictureTapped(sender: UITapGestureRecognizer) {
        profilePicPicker = true
        let imageVC = UIImagePickerController()
        imageVC.delegate = self
        imageVC.allowsEditing = true
        imageVC.sourceType = .PhotoLibrary
        presentViewController(imageVC, animated: true, completion: nil) // FIXME: Causes warning 'Presenting view controllers on detached view controllers is discouraged'
    }
    
    // MARK: ImagePickerController
    
    // Triggered when the user finishes taking an image.  Saves the chosen image
    // to our temporary chosenImage variable, and dismisses the
    // image picker view controller.  Once the image picker view controller is
    // dismissed (a.k.a. inside the completion handler) we modally segue to
    // show the "Location selection" screen (WRITTEN BY NICK TROCCOLI)
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        uploadImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        dismissViewControllerAnimated(true, completion: { () -> Void in
            let imageData = UIImageJPEGRepresentation(self.uploadImage, 100)
            let imageFile = PFFile(name: (PFUser.currentUser()?.email)!+".jpeg", data: imageData)
            if self.profilePicPicker{
                self.realProfilePic.image = self.uploadImage
                PFUser.currentUser()?.setObject(imageFile, forKey: "photo")
                //todo: set "loading" picture when we're saving
                PFUser.currentUser()?.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                    if error==nil{
                        //println("successfully uploaded photo!")
                        self.viewDidLoad()
                    }else{
                        println("fubar")
                        println(error)
                    }
                    //nothing
                })
            }else{
                self.backgroundPhoto.image = self.uploadImage
                PFUser.currentUser()?.setObject(imageFile, forKey: "backgroundphoto")
                PFUser.currentUser()?.saveInBackgroundWithBlock({ (success:Bool, error:NSError?) -> Void in
                    if error==nil{
                        //println("successfully uploaded photo!")
                        self.viewDidLoad()
                    }else{
                        println("lol")
                        println(error)
                    }
                    //nothing
                })
                
            }
//            let imageData = UIImageJPEGRepresentation(self.uploadImage, 100)
//            let imageFile = PFFile(name: "image.jpeg", data: imageData)
//            
//            var photo = PFObject(className:"Photo")
//            photo["imageName"] = "Dis a picture!" // set to caption name
//            photo["imageFile"] = imageFile
//            
//            
            
//            photo.saveInBackgroundWithBlock(nil)
           
            
        })
        
        
    }

    @IBAction func changeBackgroundTapped(sender: UITapGestureRecognizer) {
         profilePicPicker = false
        println("hai")
        let imageVC = UIImagePickerController()
        imageVC.delegate = self
        imageVC.allowsEditing = false
        imageVC.sourceType = .PhotoLibrary
        presentViewController(imageVC, animated: true, completion: nil) // FIXME: Causes warning 'Presenting view controllers on detached view controllers is discouraged'
    }
   
    @IBAction func changeBackground(sender: UITapGestureRecognizer) {

    }
    
    @IBAction func quoteTapped(sender: UITapGestureRecognizer) {
        quote.hidden = true
        quoteText.hidden = false
        quoteText.becomeFirstResponder()
        quoteText.delegate = self
    }
    @IBAction func emailTapped(sender: UITapGestureRecognizer) {
        email.hidden = true
        emailText.hidden = false
        emailText.becomeFirstResponder()
        emailText.delegate = self
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
