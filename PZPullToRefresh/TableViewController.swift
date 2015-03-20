//
//  TableView.swift
//  PZPullToRefresh
//
//  Created by pixyzehn on 3/19/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit
import QuartzCore

class TableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PZPullToRefreshDelegate {
    
    var items = ["Evernote", "Dropbox", "Sketch", "Xcode", "Pocket", "Tweetbot", "Reeder", "LINE", "Slack", "Spotify", "Sunrise", "Atom", "Dash"]
    @IBOutlet weak var tableView: UITableView!
    
    var refreshHeaderView: PZPullToRefreshView?
    var reloading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
                
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        if refreshHeaderView == nil {
            var view = PZPullToRefreshView(frame: CGRectMake(0, 0 - tableView.bounds.size.height, tableView.bounds.size.width, tableView.bounds.size.height))
            view.delegate = self
            self.tableView.addSubview(view)
            refreshHeaderView = view
        }
        refreshHeaderView?.refreshLastUpdatedDate()
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell: UITableViewCell = UITableViewCell(style: UITableViewCellStyle.Subtitle, reuseIdentifier: "Cell")
        cell.textLabel?.text = items[indexPath.row]
        return cell
    }
    
    func reloadTableViewDataSource() {
        reloading = true
    }
    
    func doneLoadingTableViewData() {
        reloading = false
        refreshHeaderView?.refreshScrollViewDataSourceDidFinishedLoading(self.tableView)
    }
    
    // MARK:UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        refreshHeaderView?.refreshScrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refreshHeaderView?.refreshScrollViewDidEndDragging(scrollView)
    }
    
    // MARK:PZPullToRefreshDelegate
    
    func pullToRefreshDidTrigger(view: PZPullToRefreshView) -> () {
        reloadTableViewDataSource()
        
        let delay = 3.0 * Double(NSEC_PER_SEC)
        let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            println("dispatch after!")
            self.doneLoadingTableViewData()
        })
    }
    
    func pullToRefreshIsLoading(view: PZPullToRefreshView) -> Bool {
        return reloading
    }
    
    // optional
    
    func pullToRefreshLastUpdated(view: PZPullToRefreshView) -> NSDate {
        return NSDate()
    }
    
}
