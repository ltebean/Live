//
//  GiftChooserViewController.swift
//  Live
//
//  Created by leo on 16/7/15.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit
import SocketIOClientSwift

class GiftChooserViewController: UIViewController {
    
    
    var socket: SocketIOClient!
    var room: Room!
    
    override func viewDidLoad() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(GiftChooserViewController.handleTap(_:)))
        view.addGestureRecognizer(tap)

    }
    
    func handleTap(gesture: UITapGestureRecognizer) {
        guard gesture.state == .Ended else {
            return
        }
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }

    @IBAction func giftButtonPressed(sender: UIButton) {
        
        socket.emit("gift", [
            "roomKey": room.key,
            "senderId": User.currentUser.id,
            "giftId": sender.tag,
            "giftCount": 1
        ])
    }
}
