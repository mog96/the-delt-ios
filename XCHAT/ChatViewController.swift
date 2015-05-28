//
//  MessageViewController.swift
//  xchat-pat
//
//  Created by Pat Boonyarittipong on 5/13/15.
//  Copyright (c) 2015 patboony. All rights reserved.
//

import UIKit
import Darwin

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, LoadMoreMessagesDelegate {
    
    @IBOutlet weak var messageTableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    @IBOutlet weak var tableViewContainer: UIView!
    @IBOutlet weak var tableViewBottomLayoutConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var sendButton: UIButton!
    @IBOutlet weak var messageTextFieldTrailingSpace: NSLayoutConstraint!
    
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var subWelcomeLabel: UILabel!
    
    var pictures = NSMutableDictionary()
    
    // This should be changed if we want to allow thread selection
    var threadId: String = "AtsDDF0sUK"
    
    let animationTime: NSTimeInterval = 0.3
    
    var messages = [PFObject]()
    var numOfMessagesToLoad: Int = 20
    var numOfTotalMessages: Int?
    
    var originalWidth: CGFloat?
    var originalHeight: CGFloat?
    
    var firstLoad: Bool = true
    
    // This block main thread
    var query: PFQuery!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Setup TableView.
        messageTableView.delegate = self
        messageTableView.dataSource = self
        
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 90
        
        messageTableView.tableFooterView = UIView(frame: CGRectZero)
        
        originalWidth = messageTableView.frame.width
        originalHeight = messageTableView.frame.height
        
        sendButton.setTitleColor(UIColor.grayColor(), forState: UIControlState.Disabled)
        
        // Fetch messages.
        self.query = PFQuery(className: "message")
        self.query.whereKey("threadId", equalTo: self.threadId)
        self.query.orderByDescending("createdAt")
        self.fetchMessages()
        
        // Add keyboard observer.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillHide:", name: UIKeyboardWillHideNotification, object: nil)
        
        // Refetch messages every 15 seconds.
        var timer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: "fetchMessages", userInfo: nil, repeats: true)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // MARK: Welcome
    
    func insertWelcomeHeader(){
        var nib = UINib(nibName: "WelcomeChatView", bundle: nil)
        var objects = nib.instantiateWithOwner(self, options: nil)
        var headerView = objects[0] as! UIView
        
        messageTableView.tableHeaderView = headerView
    }
    
    
    // MARK: Load More Messages
    
    func LoadMoreMessages(messageLoadMoreCell: MessageLoadMoreCell) {
        
        // Do we need to impose the limit? Or it doesn't matter b/c parse
        println("LOAD MORE MESSAGES")
        
        numOfMessagesToLoad += 10
        fetchMessages()
    }
    
    
    // MARK: TableView
    // NOTE: LoadMessagesCell code commented out.
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count // + 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            var cell = tableView.dequeueReusableCellWithIdentifier("MessageLeadingSpaceCell") as! MessageLeadingSpaceCell
            /*
            var cell = tableView.dequeueReusableCellWithIdentifier("LoadMessagesCell") as! MessageLoadMoreCell
            if numOfTotalMessages <= numOfMessagesToLoad {
                var emptyCell = UITableViewCell(frame: CGRectZero)
                emptyCell.frame.size.height = 0
                return emptyCell
            } else {
                cell.delegate = self
            }
            */
            
            return cell
            
        default:
            let index = indexPath.row - 1
            let message = messages[index] as PFObject
            var username = message["authorUsername"] as! String
            
            // If not the first message.
            /*
            if index > 0 {
                let previousMessage = messages[index - 1] as PFObject
                var previousMessageUsername = previousMessage["authorUsername"] as! String
                
                // Message sent by same user as last message.
                if username != previousMessageUsername {
                    var cell = tableView.dequeueReusableCellWithIdentifier("MessageCell", forIndexPath: indexPath) as! MessageCell
                    cell.messageLabel.text = message["content"] as? String
                    return cell
                }
            }
            */
            
            // Message sent by different user.
            var cell = tableView.dequeueReusableCellWithIdentifier("FirstMessageCell", forIndexPath: indexPath) as! FirstMessageCell
            cell.setUpCellWithPictures(message, pictures: self.pictures)
            return cell
        }
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        
        switch indexPath.row {
        case 0:
            
            return 10
            /*
            if let x = numOfTotalMessages {
                if x > numOfMessagesToLoad {
                    return 25
                } else {
                    return 0
                }
            } else {
                return 0
            }
            */
        
        default:
            var messageForRow = messages[indexPath.row - 1]
            var textContent = messageForRow["content"] as! String
            var textInCell = NSMutableAttributedString(string: textContent)
            var all = NSMakeRange(0, textInCell.length)
            
            textInCell.addAttribute(NSFontAttributeName, value: UIFont(name: "Helvetica Neue", size: 15)!, range: all)
            
            var cellSize: CGSize = textInCell.boundingRectWithSize(CGSizeMake(200, CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil).size
            
            if cellSize.height == 0 {
                cellSize.height = 80
            }
            
            return cellSize.height
        }
    }
    
    
    // MARK: Text Field
    
    func resizeTextField(sender: UITextField) {
        
        if !validateMessage(sender.text){
            sendButton.enabled = false
        } else {
            sendButton.enabled = true
        }
        
        if sender.text != "" {
            self.messageTextFieldTrailingSpace.constant = 52
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { (completed: Bool) -> Void in
                    self.sendButton.alpha = 1
            })
            
        } else {
            self.sendButton.alpha = 0
            self.messageTextFieldTrailingSpace.constant = 8
            
            UIView.animateWithDuration(0.2, animations: { () -> Void in
                self.view.layoutIfNeeded()
                }, completion: { (completed: Bool) -> Void in
                    
            })
        }
    }
    
    func validateMessage(string: String) -> Bool {
        let whitespaceSet = NSCharacterSet.whitespaceCharacterSet()
        return string.stringByTrimmingCharactersInSet(whitespaceSet) != ""
    }
    
    
    // MARK: Keyboard
    
    func keyboardWillShow(notification: NSNotification){
        let userInfo = notification.userInfo
        let kbSize = userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue()
        let newHeight = tableViewContainer.frame.height - kbSize!.height
        
        self.tableViewBottomLayoutConstraint.constant = kbSize!.height
        println(kbSize!.height)
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
            }, completion: { (Bool) -> Void in
                self.scrollToBottom()
        })
        
    }
    
    func keyboardWillHide(notification: NSNotification){
        
        self.tableViewBottomLayoutConstraint.constant = 0
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
            }, completion: { (Bool) -> Void in
                self.scrollToBottom()
        })
    }
    
    
    // MARK: Actions
    
    @IBAction func onTableViewTap(sender: UITapGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    @IBAction func onMessageTextFieldEdit(sender: UITextField) {
        resizeTextField(sender)
    }
    
    @IBAction func sendMessageAction(sender: AnyObject) {
        
        if validateMessage(messageTextField.text) {
            var message = PFObject(className: "message")
            // Dummy authorId and threadId
            message["authorUsername"] = PFUser.currentUser()?.valueForKey("username") as! String
            message["threadId"] = threadId
            message["content"] = messageTextField.text
            
            
            // Clear the text field
            messageTextField.text = ""
            resizeTextField(messageTextField)
            
            message.saveInBackgroundWithBlock { (result: Bool, error: NSError?) -> Void in
                if error != nil {
                    // Print some kind of error to clients
                    println("unable to send this message")
                    println(error?.description)
                } else {
                    // Succeed - reload
                    self.fetchMessages()
                }
            }
        }
    }
    
    
    // MARK: Retreive Data
    
    func fetchMessages() {
        
        //numOfTotalMessages = query.countObjects()
        //println(numOfTotalMessages)
        //println(numOfMessagesToLoad)
        
        query.limit = numOfMessagesToLoad
        
        query.findObjectsInBackgroundWithBlock { (objects: [AnyObject]?, error: NSError?) -> Void in
            if objects != nil {
                if self.messages.count < objects?.count {
                    self.messages = ((objects as! [PFObject]?)!).reverse()
                    
                    // get rid of the welcome message
                    // self.messageTableView.tableHeaderView = UIView(frame: CGRectZero)
                    self.fetchUserPics()
                    self.messageTableView.reloadData()
                    
                    // Scroll to bottom
                    if self.firstLoad {
                        self.messageTableView.layoutIfNeeded()
                        self.scrollToBottom()
                        self.firstLoad = false
                    }
                }
                
            } else {
                
                // Print error message.
                println(error?.description)
            }
        }
    }
    
    // Refreshes messages.
    func delay(delay:Double, closure:()->()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    
    // MARK: Auto Scroll
    
    func scrollToBottom(){
        let bottomSection = messageTableView.numberOfSections() - 1
        if bottomSection >= 0 {
            let bottomRow = messageTableView.numberOfRowsInSection(bottomSection) - 1
            if bottomRow >= 1 {
                
                let lastIndexPath = NSIndexPath(forRow: bottomRow, inSection: bottomSection)
                
                messageTableView.layoutIfNeeded()
                messageTableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            }
        }
    }
    
    
    /*
    DEPRECATED

    */
    func fetchUserPics(){
        var usernames = NSMutableSet()
        for message in self.messages{
            usernames.addObject((message["authorUsername"] as? String)!)
        }
        
        var username_list = usernames.allObjects as! [NSString]
        var userQuery = PFUser.query()
        //userQuery?.whereKey("username", containedIn: username_list)
        userQuery?.whereKey("username", containedIn: username_list)
        //println(userQuery?.getFirstObject())
        userQuery!.findObjectsInBackgroundWithBlock { (objects:[AnyObject]?, error:NSError?) -> Void in
            if objects != nil{
                var profiles = objects as! [PFUser]
                for profile in profiles {
                    if  let pic = profile["photo"] as? PFFile {
                        
                        println("PHOTO FOUND")
                        var pfImageView = PFImageView()
                        pfImageView.file = pic
                        pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
                            if error == nil {
                                self.pictures[profile.username!] = image
                            } else {
                                // Log details of the failure
                                self.messageTableView.reloadData()
                                println("Error: \(error!) \(error!.userInfo!)")
                            }
                        }
                    }
                }
            }
        }
        
        
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
