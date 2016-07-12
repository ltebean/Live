
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
    
    let player = IJKFFMoviePlayerController(contentURL: NSURL(string: Config.rtmpPlayUrl + Config.rtmpKey), withOptions: IJKFFOptions.optionsByDefault())
    
    let socket = SocketIOClient(socketURL: NSURL(string: Config.socketUrl)!, options: [.Log(true), .ForcePolling(true)])
    
    var overlayController: LiveOverlayViewController!

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        player.view.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        player.view.frame = previewView.bounds
        previewView.addSubview(player.view)
        
        player.prepareToPlay()
        
        socket.on("connect") {data, ack in
            self.socket.emit("join")
        }
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "overlay" {
            overlayController = segue.destinationViewController as! LiveOverlayViewController
            overlayController.socket = socket
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
