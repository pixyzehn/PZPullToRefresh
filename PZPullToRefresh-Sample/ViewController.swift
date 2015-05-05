//
//  ViewController.swift
//  PZPullToRefresh-Sample
//
//  Created by pixyzehn on 3/21/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, PZPullToRefreshDelegate {
    
    var items = ["Evernote", "Dropbox", "Sketch", "Xcode", "Pocket", "Tweetbot", "Reeder", "LINE", "Slack", "Spotify", "Sunrise", "Atom", "Dash", "Reveal", "Alternote", "iTerm"]
    
    @IBOutlet weak var tableView: UITableView!
    
    var refreshHeaderView: PZPullToRefreshView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationController?.navigationBar.barTintColor = UIColor.whiteColor()
        
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.edgesForExtendedLayout = UIRectEdge.None
        
        if refreshHeaderView == nil {
            var view = PZPullToRefreshView(frame: CGRectMake(0, 0 - tableView.bounds.size.height, tableView.bounds.size.width, tableView.bounds.size.height))
            view.delegate = self
            self.tableView.addSubview(view)
            refreshHeaderView = view
        }
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
    
    // MARK:UIScrollViewDelegate
    
    func scrollViewDidScroll(scrollView: UIScrollView) {
        refreshHeaderView?.refreshScrollViewDidScroll(scrollView)
    }
    
    func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        refreshHeaderView?.refreshScrollViewDidEndDragging(scrollView)
    }
    
    // MARK:PZPullToRefreshDelegate

    func pullToRefreshDidTrigger(view: PZPullToRefreshView) -> () {
        refreshHeaderView?.isLoading = true
        
        let delay = 3.0 * Double(NSEC_PER_SEC)
        let time  = dispatch_time(DISPATCH_TIME_NOW, Int64(delay))
        dispatch_after(time, dispatch_get_main_queue(), {
            println("Complete loading!")
            self.refreshHeaderView?.isLoading = false
            self.refreshHeaderView?.refreshScrollViewDataSourceDidFinishedLoading(self.tableView)
        })
    }

    // Optional method
    
    func pullToRefreshLastUpdated(view: PZPullToRefreshView) -> NSDate {
        return NSDate()
    }
    
}
