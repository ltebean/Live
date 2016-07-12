//
//  LiveOverlayViewController.swift
//  Live
//
//  Created by leo on 16/7/12.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit
import SocketIOClientSwift
import IHKeyboardAvoiding

class LiveOverlayViewController: UIViewController {
    
    @IBOutlet weak var emitterView: WaveEmitterView!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var inputContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var comments: [String] = []
    
    var socket: SocketIOClient! {
        didSet {
            setup()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.whiteColor().CGColor
        textField.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        IHKeyboardAvoiding.setAvoidingView(inputContainer)
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(LiveOverlayViewController.tick(_:)), userInfo: nil, repeats: true)
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.contentInset.top = tableView.bounds.height
        tableView.reloadData()
        
    }
    

    func setup() {
        socket.on("upvote") {data ,ack in
            self.emitterView.emitImage(UIImage(named: "image-2")!)
        }
        
        socket.on("comment") {data ,ack in
            let comment = data[0] as! String
            self.comments.append(comment)
            self.tableView.reloadData()
        }
    }

    
    func tick(timer: NSTimer) {
        guard comments.count > 0 else {
            return
        }
        if tableView.contentSize.height > tableView.bounds.height {
            tableView.contentInset.top = 0
        }
        tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: comments.count - 1, inSection: 0), atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
    }

    @IBAction func upvoteButtonPressed(sender: AnyObject) {
        socket.emit("upvote")
    }
}

extension LiveOverlayViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            if let text = textField.text where text != "" {
                socket.emit("comment", text)
            }
            textField.text = ""
            return false
        }
        return true
    }
}

extension LiveOverlayViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath) as! CommentCell
        cell.comment = comments[indexPath.row]
        return cell
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return CommentCell.heightForComment(comments[indexPath.row])
    }
}


class CommentCell: UITableViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    var comment: String = "" {
        didSet {
            updateUI()
        }
    }
    
    func updateUI() {
        titleLabel.text = " \(comment) "
    }
    
    static func heightForComment(comment: String) -> CGFloat {
        return 50
    }
}
