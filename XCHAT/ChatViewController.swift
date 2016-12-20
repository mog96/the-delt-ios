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
    
    var refreshTimer: Timer!
    var presentedConnectionError = false
    
    // This should be changed if we want to allow thread selection
    var threadId: String = "AtsDDF0sUK"
    
    let kMessageDraftKey = "ChatMessageDraft"
    let kLastSentMessageKey = "ChatLastSentMessage"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        UIApplication.shared.setStatusBarStyle(.default, animated: true)
        self.setMenuButton(withColor: "red")
        
        // Setup TableView.
        messageTableView.delegate = self
        messageTableView.dataSource = self
        messageTableView.rowHeight = UITableViewAutomaticDimension
        messageTableView.estimatedRowHeight = 90
        messageTableView.tableFooterView = UIView(frame: CGRect.zero)
        
        // Setup message view.
        self.messageView = Bundle.main.loadNibNamed("MessageView", owner: self, options: nil)![0] as! MessageView
        self.messageView.frame = CGRect(x: 0, y: UIScreen.main.bounds.height - self.messageView.frame.height, width: self.messageView.frame.height, height: UIScreen.main.bounds.width)
        if let messageDraft = UserDefaults.standard.object(forKey: self.kMessageDraftKey) as? String {
            self.messageView.messageTextView.text = messageDraft
        }
        self.messageView.delegate = self
        self.view.addSubview(self.messageView)
        self.messageView.autoPinEdge(toSuperviewEdge: .left)
        self.messageView.autoPinEdge(toSuperviewEdge: .right)
        self.messageViewBottomConstraint = self.messageView.autoPinEdge(toSuperviewEdge: .bottom)
        self.messageView.autoPinEdge(.top, to: .bottom, of: self.messageTableView)
        
        // Add keyboard observers.
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        // Notify when app going into background to save message drafts.
        NotificationCenter.default.addObserver(self, selector: #selector(self.saveMessageDraft), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.willEnterForeground), name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.willEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
        
        // Fetch messages.
        self.fetchMessages()
        
        // SET MESSAGE REFRESH
        // Refetch messages every 15 seconds. 
        self.refreshTimer = Timer.scheduledTimer(timeInterval: 15, target: self, selector: #selector(ChatViewController.fetchMessages), userInfo: nil, repeats: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.clearApplicationIconBadge()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
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
            let bottomRow = messageTableView.numberOfRows(inSection: bottomSection) - 1
            // let lastIndexPath = NSIndexPath(forRow: bottomRow, inSection: bottomSection)
            if bottomRow >= 1 {
                
                let lastIndexPath = IndexPath(row: bottomRow, section: bottomSection)
                
                messageTableView.layoutIfNeeded()
                messageTableView.scrollToRow(at: lastIndexPath, at: UITableViewScrollPosition.bottom, animated: true)
            }
        }
    }
    
    func trimmedMessage(_ message: String, placeholder: String?) -> String? {
        let trimmedMessage = message.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        if trimmedMessage.characters.count > 0 && trimmedMessage != placeholder {
            return trimmedMessage
        } else {
            return nil
        }
    }
    
    @objc fileprivate func saveMessageDraft() {
        if let messageDraft = self.trimmedMessage(self.messageView.messageTextView.text, placeholder: self.messageView.placeholder) {
            UserDefaults.standard.set(messageDraft, forKey: self.kMessageDraftKey)
        } else {
            UserDefaults.standard.removeObject(forKey: self.kMessageDraftKey)
        }
    }
}


// MARK: - Keyboard Helpers

extension ChatViewController {
    func keyboardWillShow(_ notification: Notification){
        let userInfo = notification.userInfo
        let kbSize = (userInfo?[UIKeyboardFrameBeginUserInfoKey] as AnyObject).cgRectValue
        self.messageViewBottomConstraint.constant = -kbSize!.height
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            
            self.view.layoutIfNeeded()
            }, completion: { (Bool) -> Void in
                self.scrollToBottom()
        })
    }
    
    func keyboardWillHide(_ notification: Notification){
        
        self.messageViewBottomConstraint.constant = 0
        
        UIView.animate(withDuration: 0.2, animations: { () -> Void in
            
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
        query.order(byDescending: "createdAt")
        
        query.limit = self.numOfMessagesToLoad
        
        // Server side code that checks whether there are any messages and retrieves them if so.
        query.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if let objects = objects {
                if self.messages.count - 1 < objects.count {
                    self.messages = objects.reversed()
                    
                    // get rid of the welcome message
                    // self.messageTableView.tableHeaderView = UIView(frame: CGRectZero)
                    self.fetchUserPics()
                    self.messageTableView.reloadData()
                    self.messageTableView.layoutIfNeeded()
                    self.scrollToBottom()
                }
                
            } else {
                
                // Print error message.
                print("Error fetching Chat messages:", error?.localizedDescription)
                if let errorString = error?.localizedDescription {
                    if errorString == "Could not connect to the server." && !self.presentedConnectionError {
                        self.refreshTimer.invalidate()
                        
                        self.view.endEditing(true)
                        let alertVC = UIAlertController(title: "Unable to Connect", message: "Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                        self.present(alertVC, animated: true, completion: nil)
                        
                        self.presentedConnectionError = true
                    }
                }
            }
        }
    }
    
    // Refreshes messages.
    func delay(_ delay: Double, closure: @escaping () -> ()) {
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: closure)
    }
    
    // FIXME: ENCAPSULATE
    func fetchUserPics(){
        let usernames = NSMutableSet()
        for message in self.messages{
            usernames.add((message["authorUsername"] as? String)!)
        }
        
        let username_list = usernames.allObjects as! [NSString]
        let userQuery = PFUser.query()
        
        //userQuery?.whereKey("username", containedIn: username_list)
        userQuery?.whereKey("username", containedIn: username_list)
        
        //print(userQuery?.getFirstObject())
        userQuery!.findObjectsInBackground { (objects: [PFObject]?, error: Error?) -> Void in
            if let objects = objects {
                let profiles = objects as! [PFUser]
                for profile in profiles {
                    if  let pic = profile["photo"] as? PFFile {
                        
                        print("PHOTO FOUND")
                        let pfImageView = PFImageView()
                        pfImageView.file = pic
                        pfImageView.load { (image: UIImage?, error: Error?) -> Void in
                            if let error = error {
                                self.messageTableView.reloadData()
                                
                                // Log details of the failure
                                print("Error: \(error) \(error.localizedDescription)")
                                
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count + 1// + 1
    }
    
    // NOTE: LoadMessagesCell code commented out.
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.row {
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "MessageLeadingSpaceCell") as! MessageLeadingSpaceCell
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
            let cell = tableView.dequeueReusableCell(withIdentifier: "FirstMessageCell", for: indexPath) as! FirstMessageCell
            cell.usernameLabel.profilePresenterDelegate = self
            cell.authorProfileImageView.profilePresenterDelegate = self
            cell.setUpCellWithPictures(message, pictures: self.pictures)
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        
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
            
            var cellSize: CGSize = textInCell.boundingRect(with: CGSize(width: 200, height: CGFloat(MAXFLOAT)), options: NSStringDrawingOptions.usesLineFragmentOrigin, context: nil).size
            
            if cellSize.height == 0 {
                cellSize.height = 80
            }
            
            return cellSize.height
        }
    }
}


// MARK: Load More Messages Delegate

extension ChatViewController: LoadMoreMessagesDelegate {
    
    func LoadMoreMessages(_ messageLoadMoreCell: MessageLoadMoreCell) {
        
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
            if let username = PFUser.current()?.value(forKey: "username") as? String {
                message["authorUsername"] = username
            }
            message["threadId"] = self.threadId
            message["content"] = sentMessage
            
            UserDefaults.standard.set(sentMessage, forKey: self.kLastSentMessageKey)
            
            self.messageView.messageTextView.text = ""
            
            message.saveInBackground { (result: Bool, error: Error?) -> Void in
                if error != nil {
                    print("Error sending message \"\(sentMessage)\":", error?.localizedDescription)
                    
                    if self.trimmedMessage(self.messageView.messageTextView.text, placeholder: self.messageView.placeholder) == nil {
                        self.messageView.messageTextView.text = UserDefaults.standard.object(forKey: self.kLastSentMessageKey) as? String
                    }
                    let alertVC = UIAlertController(title: "Send Failed", message: "Please try again later.", preferredStyle: UIAlertControllerStyle.alert)
                    alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                    self.present(alertVC, animated: true, completion: nil)
                } else {
                    // Succeed - reload
                    self.fetchMessages()
                }
            }
            
        }
    }
}


// MARK: - Application Icon Badge Helpers

extension ChatViewController {
    func willEnterForeground() {
        // Only clear badge if Chat vc onscreen.
        if self.isViewLoaded && self.view.window != nil {
            self.clearApplicationIconBadge()
        }
    }
    
    func clearApplicationIconBadge() {
        let installation = PFInstallation.current()!
        let badge = installation.badge
        print("BADGE NUM", badge)
        if installation.badge != 0 {
            installation.badge = 0
            installation.saveInBackground(block: { (saved: Bool, error: Error?) in
                print("BADGE SAVED")
            })
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}


// MARK: - Actions

extension ChatViewController {
    @IBAction func onScreenTapped(_ sender: AnyObject) {
        self.view.endEditing(true)
        self.messageView.resetMessageTextView()
    }
}
