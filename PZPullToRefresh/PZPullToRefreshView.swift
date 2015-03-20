//
//  PZPullRefreshView.swift
//  PZPullToRefresh
//
//  Created by pixyzehn on 3/19/15.
//  Copyright (c) 2015 pixyzehn. All rights reserved.
//

import UIKit
import QuartzCore

@objc protocol PZPullToRefreshDelegate: NSObjectProtocol {
    func pullToRefreshDidTrigger(view: PZPullToRefreshView) -> ()
    func pullToRefreshIsLoading(view: PZPullToRefreshView) -> Bool
    optional func pullToRefreshLastUpdated(view: PZPullToRefreshView) -> NSDate
}

class PZPullToRefreshView: UIView {
    
    enum RefreshState {
        case Normal
        case Pulling
        case Loading
    }
    
    let TEXTCOLOR = UIColor(red:0.95, green:0.95, blue:0.95, alpha:1)
    let FLIP_ANIMATION_DURATION: CFTimeInterval = 0.18
    
    var _state: RefreshState = .Normal
    var state: RefreshState {
        get {
           return _state
        }
        set {
            switch newValue {
            case .Pulling:
                statusLabel?.text = "Release to refresh..."
                CATransaction.begin()
                CATransaction.setAnimationDuration(FLIP_ANIMATION_DURATION)
                arrowImage?.transform = CATransform3DMakeRotation(CGFloat(M_PI), 0.0, 0.0, 1.0)
                CATransaction.commit()
            case .Normal:
                if state == .Pulling {
                    CATransaction.begin()
                    CATransaction.setAnimationDuration(FLIP_ANIMATION_DURATION)
                    arrowImage?.transform = CATransform3DIdentity
                    CATransaction.commit()
                }
                statusLabel?.text = "Pull down to refresh..."
                activityView?.stopAnimating()
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                arrowImage?.hidden = false
                arrowImage?.transform = CATransform3DIdentity
                CATransaction.commit()
                refreshLastUpdatedDate()
            case .Loading:
                statusLabel?.text = "Loading..."
                activityView?.startAnimating()
                CATransaction.begin()
                CATransaction.setValue(kCFBooleanTrue, forKey: kCATransactionDisableActions)
                arrowImage?.hidden = true
                CATransaction.commit()
            }
            _state = newValue
        }
    }
    
    var lastUpdatedLabel: UILabel?
    var statusLabel: UILabel?
    var arrowImage: CALayer?
    var activityView: UIActivityIndicatorView?
    var delegate: AnyObject?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        self.backgroundColor = UIColor(red:0, green:0.22, blue:0.35, alpha:1)
        
        let label: UILabel = UILabel(frame: CGRectMake(0, frame.size.height - 30.0, self.frame.size.width, 20.0))
        label.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        label.font = UIFont.systemFontOfSize(12.0)
        label.textColor = TEXTCOLOR
        label.shadowColor = UIColor(white: 0.9, alpha: 1.0)
        label.shadowOffset = CGSizeMake(0.0, 1.0)
        label.backgroundColor = UIColor.clearColor()
        label.textAlignment = .Center
        lastUpdatedLabel = label
        self.addSubview(label)
        
        let label2: UILabel = UILabel(frame: CGRectMake(0, frame.size.height - 48.0, self.frame.size.width, 20.0))
        label2.autoresizingMask = UIViewAutoresizing.FlexibleWidth
        label2.font = UIFont.systemFontOfSize(13.0)
        label2.textColor = TEXTCOLOR
        label2.shadowColor = UIColor(white: 0.9, alpha: 1.0)
        label2.shadowOffset = CGSizeMake(0.0, 1.0)
        label2.backgroundColor = UIColor.clearColor()
        label2.textAlignment = .Center
        statusLabel = label2
        self.addSubview(label2)
        
        let layer: CALayer = CALayer()
        layer.frame = CGRectMake(25.0, frame.size.height - 65.0, 30.0, 55.0)
        layer.contentsGravity = kCAGravityResizeAspect;
        layer.contents = UIImage(named: "blueArrow")?.CGImage
        self.layer.addSublayer(layer)
        arrowImage = layer
        
        let view: UIActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.Gray)
        view.frame = CGRectMake(25.0, frame.size.height - 38.0, 20.0, 20.0)
        self.addSubview(view)
        activityView = view

        state = .Normal
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func refreshLastUpdatedDate() {
        if let update = delegate?.respondsToSelector("pullToRefreshLastUpdated:") {
            var date = delegate?.pullToRefreshLastUpdated!(self)
            let formatter = NSDateFormatter()
            formatter.AMSymbol = "AM"
            formatter.PMSymbol = "PM"
            formatter.dateFormat = "MM/dd/yyyy hh:mm:a"
            lastUpdatedLabel?.text = "Last Updated: \(formatter.stringFromDate(date!))"
            NSUserDefaults.standardUserDefaults().setObject(lastUpdatedLabel?.text, forKey: "RefreshTableView_LastRefresh")
            NSUserDefaults.standardUserDefaults().synchronize()
        } else {
            lastUpdatedLabel?.text = nil
        }
    }
    
    // MARK:ScrollView Methods
    
    func refreshScrollViewDidScroll(scrollView: UIScrollView) {
        
        println(scrollView.contentOffset.y)
        
        if state == .Loading {
            
            var offset = max(scrollView.contentOffset.y * -1, 0)
            offset = min(offset, 60)
            scrollView.contentInset = UIEdgeInsetsMake(offset, 0.0, 0.0, 0.0)
            
        } else if scrollView.dragging {
            
            var loading: Bool = false
            if let load = delegate?.respondsToSelector("pullToRefreshIsLoading:") {
                loading = delegate!.pullToRefreshIsLoading(self)
            }
            
            if state == .Pulling && scrollView.contentOffset.y > -140.0 && scrollView.contentOffset.y < 0.0
                && !loading {
                state = .Normal
            } else if state == .Normal && scrollView.contentOffset.y < -140.0 && !loading {
                state = .Pulling
            }
            
//            if scrollView.contentInset.top != 0 {
//                scrollView.contentInset = UIEdgeInsetsZero
//            }
            
        }
    }
    
    func refreshScrollViewDidEndDragging(scrollView: UIScrollView) {
        var loading: Bool = false
        if let load = delegate?.respondsToSelector("pullToRefreshIsLoading:") {
            loading = delegate!.pullToRefreshIsLoading(self)
        }

        if (scrollView.contentOffset.y <= -140.0 && !loading) {
            if let load = delegate?.respondsToSelector("pullToRefreshDidTrigger:") {
                delegate?.pullToRefreshDidTrigger(self)
            }
            
            state = .Loading
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(3.0)
            //scrollView.contentInset = UIEdgeInsetsMake(140.0, 0.0, 0.0, 0.0)
            scrollView.setContentOffset(scrollView.contentOffset, animated: true)
            UIView.commitAnimations()
        }

    }
    
    func refreshScrollViewDataSourceDidFinishedLoading(scrollView: UIScrollView) {
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationDuration(0.3)
        scrollView.contentInset = UIEdgeInsetsMake(0.0, 0.0, 0.0, 0.0)
        UIView.commitAnimations()
        
        state = .Normal
    }
    
    deinit {
        delegate = nil
        activityView = nil
        statusLabel = nil
        arrowImage = nil
        lastUpdatedLabel = nil
    }
    
}
