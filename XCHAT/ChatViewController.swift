//
//  MessageViewController.swift
//  xchat-pat
//
//  Created by Pat Boonyarittipong on 5/13/15.
//  Copyright (c) 2015 patboony. All rights reserved.
//

import UIKit
import Darwin
import Parse
import ParseUI

class ChatViewController: ContentViewController {
    
    @IBOutlet weak var messageTableView: UITableView!
    var messageView: MessageView!
    var messageViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var welcomeLabel: UILabel!
    @IBOutlet weak var subWelcomeLabel: UILabel!
    
    var pictures = NSMutableDictionary()
    var messages = [PFObject]()
    var numOfMessagesToLoad: Int = 20
    var numOfTotalMessages: Int?
    
    var refreshTimer: NSTimer!
    var presentedConnectionError = false
    
    // This should be changed if we want to allow thread selection
    var threadId: String = "AtsDDF0sUK"
    
    let kMessageDraftKey = "ChatMessageDraft"
    let kLastSentMessageKey = "ChatLastSentMessage"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.sharedApplication().setStatusBarStyle(.Default, animated: true)
        self.setMenuButton(withColor: "red")
        
        // Setup TableView.
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 90
        messageTableView.tableFooterView = UIView(frame: CGRectZero)
        
        // Setup message view.
        self.messageView = NSBundle.mainBundle().loadNibNamed("MessageView", owner: self, options: nil)![0] as! MessageView
        self.messageView.frame = CGRectMake(0, UIScreen.mainScreen().bounds.height - self.messageView.frame.height, self.messageView.frame.height, UIScreen.mainScreen().bounds.width)
        if let messageDraft = NSUserDefaults.standardUserDefaults().objectForKey(self.kMessageDraftKey) as? String {
            self.messageView.messageTextView.text = messageDraft
        }
        self.messageView.delegate = self
        self.view.addSubview(self.messageView)
        self.messageView.autoPinEdgeToSuperviewEdge(.Left)
        self.messageView.autoPinEdgeToSuperviewEdge(.Right)
        self.messageViewBottomConstraint = self.messageView.autoPinEdgeToSuperviewEdge(.Bottom)
        self.messageView.autoPinEdge(.Top, toEdge: .Bottom, ofView: self.messageTableView)
        
        // Add keyboard observers.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: UIKeyboardWillHideNotification, object: nil)
        
        // Notify when app going into background to save message drafts.
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(self.saveMessageDraft), name: UIApplicationDidEnterBackgroundNotification, object: nil)
        
        // Fetch messages.
        self.fetchMessages()
        
        // SET MESSAGE REFRESH
        // Refetch messages every 15 seconds. 
        self.refreshTimer = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: #selector(ChatViewController.fetchMessages), userInfo: nil, repeats: true)
    }
    
    override func viewWillDisappear(animated: Bool) {
        self.saveMessageDraft()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Helpers

extension ChatViewController {
    func scrollToBottom() {
        let bottomSection = messageTableView.numberOfSections - 1
        if bottomSection >= 0 {
            let bottomRow = messageTableView.numberOfRowsInSection(bottomSection) - 1
            // let lastIndexPath = NSIndexPath(forRow: bottomRow, inSection: bottomSection)
            if bottomRow >= 1 {
                
                let lastIndexPath = NSIndexPath(forRow: bottomRow, inSection: bottomSection)
                
                messageTableView.layoutIfNeeded()
                messageTableView.scrollToRowAtIndexPath(lastIndexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
            }
        }
    }
    
    func trimmedMessage(message: String, placeholder: String?) -> String? {
        let trimmedMessage = message.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet())
        if trimmedMessage.characters.count > 0 && trimmedMessage != placeholder {
            return trimmedMessage
        } else {
            return nil
        }
    }
    
    @objc private func saveMessageDraft() {
        if let messageDraft = self.trimmedMessage(self.messageView.messageTextView.text, placeholder: self.messageView.placeholder) {
            NSUserDefaults.standardUserDefaults().setObject(messageDraft, forKey: self.kMessageDraftKey)
        } else {
            NSUserDefaults.standardUserDefaults().removeObjectForKey(self.kMessageDraftKey)
        }
    }
}


// MARK: - Keyboard Helpers

extension ChatViewController {
    func keyboardWillShow(notification: NSNotification){
        let userInfo = notification.userInfo
        let kbSize = userInfo?[UIKeyboardFrameBeginUserInfoKey]?.CGRectValue
        self.messageViewBottomConstraint.constant = -kbSize!.height
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
            }, completion: { (Bool) -> Void in
                self.scrollToBottom()
        })
    }
    
    func keyboardWillHide(notification: NSNotification){
        
        self.messageViewBottomConstraint.constant = 0
        
        UIView.animateWithDuration(0.2, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
            }, completion: { (Bool) -> Void in
                self.scrollToBottom()
        })
    }
}


// MARK: - Fetch Helpers

extension ChatViewController {
    func fetchMessages() {
        let query = PFQuery(className: "message")
        query.whereKey("threadId", equalTo: self.threadId)
        query.orderByDescending("createdAt")
        
        query.limit = self.numOfMessagesToLoad
        
        // Server side code that checks whether there are any messages and retrieves them if so.
        query.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                if self.messages.count - 1 < objects.count {
                    self.messages = objects.reverse()
                    
                    // get rid of the welcome message
                    // self.messageTableView.tableHeaderView = UIView(frame: CGRectZero)
                    self.fetchUserPics()
                    self.messageTableView.reloadData()
                    self.messageTableView.layoutIfNeeded()
                    self.scrollToBottom()
                }
                
            } else {
                
                // Print error message.
                print("Error fetching Chat messages:", error?.userInfo["error"] as? String)
                if let errorString = error?.userInfo["error"] as? String {
                    if errorString == "Could not connect to the server." && !self.presentedConnectionError {
                        self.refreshTimer.invalidate()
                        
                        self.view.endEditing(true)
                        let alertVC = UIAlertController(title: "Unable to Connect", message: "Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                        alertVC.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                        self.presentViewController(alertVC, animated: true, completion: nil)
                        
                        self.presentedConnectionError = true
                    }
                }
            }
        }
    }
    
    // Refreshes messages.
    func delay(delay: Double, closure: () -> ()) {
        dispatch_after(
            dispatch_time(
                DISPATCH_TIME_NOW,
                Int64(delay * Double(NSEC_PER_SEC))
            ),
            dispatch_get_main_queue(), closure)
    }
    
    // FIXME: ENCAPSULATE
    func fetchUserPics(){
        let usernames = NSMutableSet()
        for message in self.messages{
            usernames.addObject((message["authorUsername"] as? String)!)
        }
        
        let username_list = usernames.allObjects as! [NSString]
        let userQuery = PFUser.query()
        
        //userQuery?.whereKey("username", containedIn: username_list)
        userQuery?.whereKey("username", containedIn: username_list)
        
        //print(userQuery?.getFirstObject())
        userQuery!.findObjectsInBackgroundWithBlock { (objects: [PFObject]?, error: NSError?) -> Void in
            if let objects = objects {
                let profiles = objects as! [PFUser]
                for profile in profiles {
                    if  let pic = profile["photo"] as? PFFile {
                        
                        print("PHOTO FOUND")
                        let pfImageView = PFImageView()
                        pfImageView.file = pic
                        pfImageView.loadInBackground { (image: UIImage?, error: NSError?) -> Void in
                            if let error = error {
                                self.messageTableView.reloadData()
                                
                                // Log details of the failure
                                print("Error: \(error) \(error.userInfo)")
                                
                            } else {
                                self.pictures[profile.username!] = image
                            }
                        }
                    }
                }
            }
        }
    }
}


// MARK: - Table View

extension ChatViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count + 1// + 1
    }
    
    // NOTE: LoadMessagesCell code commented out.
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCellWithIdentifier("MessageLeadingSpaceCell") as! MessageLeadingSpaceCell
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
            // var username = message["authorUsername"] as! String
            
            /*
            // If not the first message.
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
            let cell = tableView.dequeueReusableCellWithIdentifier("FirstMessageCell", forIndexPath: indexPath) as! FirstMessageCell
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
            let messageForRow = messages[indexPath.row - 1]
            let textContent = messageForRow["content"] as! String
            let textInCell = NSMutableAttributedString(string: textContent)
            let all = NSMakeRange(0, textInCell.length)
            
            textInCell.addAttribute(NSFontAttributeName, value: UIFont(name: "Helvetica Neue", size: 15)!, range: all)
            
            var cellSize: CGSize = textInCell.boundingRectWithSize(CGSizeMake(200, CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.UsesLineFragmentOrigin, context: nil).size
            
            if cellSize.height == 0 {
                cellSize.height = 80
            }
            
            return cellSize.height
        }
    }
}


// MARK: Load More Messages Delegate

extension ChatViewController: LoadMoreMessagesDelegate {
    
    func LoadMoreMessages(messageLoadMoreCell: MessageLoadMoreCell) {
        
        // Do we need to impose the limit? Or it doesn't matter b/c parse
        print("LOAD MORE MESSAGES")
        
        numOfMessagesToLoad += 10
        fetchMessages()
    }
}


// MARK: - Message View Delegate

extension ChatViewController: MessageViewDelegate {
    func onSendButtonTapped() {
        if let sentMessage = self.trimmedMessage(self.messageView.messageTextView.text, placeholder: self.messageView.placeholder) {
            let message = PFObject(className: "message")
            
            // FIXME: CACHE USERNAME in NSUserDefaults.
            // Dummy authorId and threadId
            if let username = PFUser.currentUser()?.valueForKey("username") as? String {
                message["authorUsername"] = username
            }
            message["threadId"] = self.threadId
            message["content"] = sentMessage
            
            NSUserDefaults.standardUserDefaults().setObject(sentMessage, forKey: self.kLastSentMessageKey)
            
            self.messageView.messageTextView.text = ""
            
            message.saveInBackgroundWithBlock { (result: Bool, error: NSError?) -> Void in
                if error != nil {
                    print("Error sending message \"\(sentMessage)\":", error?.userInfo["error"] as? String)
                    
                    if self.trimmedMessage(self.messageView.messageTextView.text, placeholder: self.messageView.placeholder) == nil {
                        self.messageView.messageTextView.text = NSUserDefaults.standardUserDefaults().objectForKey(self.kLastSentMessageKey) as? String
                    }
                    let alertVC = UIAlertController(title: "Send Failed", message: "Please try again later.", preferredStyle: UIAlertControllerStyle.Alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .Cancel, handler: nil))
                    self.presentViewController(alertVC, animated: true, completion: nil)
                } else {
                    // Succeed - reload
                    self.fetchMessages()
                }
            }
            
        }
    }
}


// MARK: - Actions

extension ChatViewController {
    @IBAction func onScreenTapped(sender: AnyObject) {
        self.view.endEditing(true)
        self.messageView.resetMessageTextView()
    }
}
