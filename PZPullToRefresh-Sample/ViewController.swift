//
//  ViewController.swift
//  PZPullToRefresh-Sample
//
//  Created by pixyzehn on 3/21/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PZPullToRefreshDelegate {
    
    var items = [
        "Evernote", "Dropbox", "Sketch", "Xcode", "Pocket",
        "Tweetbot", "Reeder", "LINE", "Slack", "Spotify",
        "Sunrise", "Atom", "Dash", "Reveal", "Alternote", "iTerm"
    ]
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshHeaderView: PZPullToRefreshView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.barTintColor = UIColor.white

        if refreshHeaderView == nil {
            let view = PZPullToRefreshView(frame: CGRect(x: 0, y: 0 - tableView.bounds.size.height, width: tableView.bounds.size.width, height: tableView.bounds.size.height))
            view.delegate = self
            tableView.addSubview(view)
            refreshHeaderView = view
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: .subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = items[(indexPath as NSIndexPath).row]
        return cell
    }
    
    // MARK:UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        refreshHeaderView?.refreshScrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refreshHeaderView?.refreshScrollViewDidEndDragging(scrollView)
    }
    
    // MARK:PZPullToRefreshDelegate

    func pullToRefreshDidTrigger(_ view: PZPullToRefreshView) -> () {
        refreshHeaderView?.isLoading = true
        
        let delay = 3.0 * Double(NSEC_PER_SEC)
        let time  = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            print("Complete loading!")
            self.refreshHeaderView?.isLoading = false
            self.refreshHeaderView?.refreshScrollViewDataSourceDidFinishedLoading(self.tableView)
        })
    }

    func pullToRefreshLastUpdated(_ view: PZPullToRefreshView) -> Date {
        return Date()
    }
    
}
