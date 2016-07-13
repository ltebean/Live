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
    
    var comments: [Comment] = []
    var room: Room!
    
    var socket: SocketIOClient!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 5
        textField.layer.borderColor = UIColor.whiteColor().CGColor
        
        textField.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        
        IHKeyboardAvoiding.setAvoidingView(inputContainer)
        
        NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: #selector(LiveOverlayViewController.tick(_:)), userInfo: nil, repeats: true)
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LiveOverlayViewController.handleTap(_:)))
        view.addGestureRecognizer(tap)
        
        socket.on("upvote") {data ,ack in
            self.emitterView.emitImage(R.image.heart()!)
        }
        
        socket.on("comment") {data ,ack in
            let comment = Comment(dict: data[0] as! [String: AnyObject])
            self.comments.append(comment)
            self.tableView.reloadData()
        }
        
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        tableView.contentInset.top = tableView.bounds.height
        tableView.reloadData()
    }
    
    func handleTap(gesture: UITapGestureRecognizer) {
        guard gesture.state == .Ended else {
            return
        }
        textField.resignFirstResponder()
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
        socket.emit("upvote", room.key)
    }
}

extension LiveOverlayViewController: UITextFieldDelegate {
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" {
            textField.resignFirstResponder()
            if let text = textField.text where text != "" {
                socket.emit("comment", [
                    "roomKey": room.key,
                    "text": text
                ])
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
    
    @IBOutlet weak var commentContainer: UIView!
    
    var comment: Comment! {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        commentContainer.layer.cornerRadius = 3
    }
    
    func updateUI() {
        titleLabel.attributedText = comment.text.attributedComment()
    }
    
    static func heightForComment(comment: Comment) -> CGFloat {
        return comment.text.attributedComment().heightWithConstrainedWidth(160 - 2 * 6) + (5 + 6) * 2
    }
}
