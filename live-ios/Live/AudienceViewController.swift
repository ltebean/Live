
//
//  AudienceViewController.swift
//  Live
//
//  Created by leo on 16/7/11.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit
import SocketIOClientSwift

class AudienceViewController: UIViewController {

    @IBOutlet weak var previewView: UIView!
    
    var room: Room!
    
    var player: IJKFFMoviePlayerController!
    let socket = SocketIOClient(socketURL: NSURL(string: Config.serverUrl)!, options: [.Log(true), .ForcePolling(true)])
    
    var overlayController: LiveOverlayViewController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        player = IJKFFMoviePlayerController(contentURL: NSURL(string: Config.rtmpPlayUrl + room.key), withOptions: IJKFFOptions.optionsByDefault())
        
        player.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        player.view.frame = previewView.bounds
        previewView.addSubview(player.view)
        
        player.prepareToPlay()
        
        socket.on("connect") {data, ack in
            self.socket.emit("join_room", self.room.key)
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "overlay" {
            overlayController = segue.destinationViewController as! LiveOverlayViewController
            overlayController.socket = socket
            overlayController.room = room
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        player.play()
        socket.connect()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        player.shutdown()
        socket.disconnect()
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
