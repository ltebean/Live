//
//  GiftChooserViewController.swift
//  Live
//
//  Created by leo on 16/7/15.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit
import SocketIO

class GiftChooserViewController: UIViewController {
    
    
    var socket: SocketIOClient!
    var room: Room!
    
    override func viewDidLoad() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(GiftChooserViewController.handleTap(_:)))
        view.addGestureRecognizer(tap)

    }
    
    func handleTap(_ gesture: UITapGestureRecognizer) {
        guard gesture.state == .ended else {
            return
        }
        presentingViewController?.dismiss(animated: true, completion: nil)
    }

    @IBAction func giftButtonPressed(_ sender: UIButton) {
        
        socket.emit("gift", [
            "roomKey": room.key,
            "senderId": User.currentUser.id,
            "giftId": sender.tag,
            "giftCount": 1
        ])
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .lightContent
    }
}
