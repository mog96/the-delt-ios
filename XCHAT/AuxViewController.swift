//
//  AuxViewController.swift
//  XCHAT
//
//  Created by Mateo Garcia on 9/18/16.
//  Copyright © 2016 Mateo Garcia. All rights reserved.
//

import UIKit

class AuxViewController: ContentViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setMenuButton(withColor: "white")
        UIApplication.shared.setStatusBarStyle(.lightContent, animated: true)
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedRowHeight = 44
        self.tableView.rowHeight = UITableViewAutomaticDimension
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}


// MARK: - Table View

extension AuxViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = Bundle.main.loadNibNamed("SettingsHeaderView", owner: self, options: nil)![0] as! SettingsHeaderView
        switch section {
        case 0:
            headerView.headerLabel.text = "QUEUE"
        default:
            headerView.headerLabel.text = "PLAYLISTS"
        }
        headerView.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: headerView.frame.height)
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch indexPath.section {
        case 0:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "CurrentQueueCell")!
            return cell
        default:
            let cell = self.tableView.dequeueReusableCell(withIdentifier: "PlaylistCell")!
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.section {
        case 0:
            self.performSegue(withIdentifier: "CurrentQueueSegue", sender: self)
        default:
            return
        }
    }
}
