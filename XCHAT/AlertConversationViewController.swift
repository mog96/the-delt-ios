//
//  AlertConversationViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 12/25/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit
import Parse
import ParseUI

class AlertConversationViewController: ContentViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    var alert: PFObject!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}

// In query for AlertReply objects, include key User

// Incorporates reply view at the bottom.


// MARK: - Table View

extension AlertConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        default: // case 1:
            return 5 // FIXME: COUNT OF ALERT OBJECTS
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let detailCell = tableView.dequeueReusableCell(withIdentifier: "AlertDetailCell", for: indexPath)
            return detailCell
        default:
            let replyCell = tableView.dequeueReusableCell(withIdentifier: "ReplyCell", for: indexPath)
            return replyCell
        }
    }
}


// MARK: - Actions

extension AlertConversationViewController {
    @IBAction func onReplyButtonTapped(_ sender: Any) {
        // Present reply vc.
    }
}
