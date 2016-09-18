//
//  QueueViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/13/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

class QueueViewController: ContentViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.allowsMultipleSelectionDuringEditing = false
        self.tableView.backgroundView = UIView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Table View

extension QueueViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.row {
        case 0:
            let cell = self.tableView.dequeueReusableCellWithIdentifier("SoundCloudCell")!
            return cell
        case 1:
            let cell = self.tableView.dequeueReusableCellWithIdentifier("SpotifyCell")!
            return cell
        default:
            let cell = self.tableView.dequeueReusableCellWithIdentifier("AppleMusicCell")!
            return cell
        }
    }
}
