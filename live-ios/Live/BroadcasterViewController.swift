//
//  BroadcasterViewController.swift
//  Live
//
//  Created by leo on 16/7/11.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit
import VideoCore
import SocketIOClientSwift

class BroadcasterViewController: UIViewController, VCSessionDelegate {
        
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    let socket = SocketIOClient(socketURL: NSURL(string: Config.serverUrl)!, options: [.Log(true), .ForceWebsockets(true)])

    let session = VCSimpleSession(videoSize: CGSize(width: 720, height: 1280), frameRate: 20, bitrate: 1000000, useInterfaceOrientation: false)
    var room: Room!
    
    var overlayController: LiveOverlayViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
            // Do any additional setup after loading the view, typically from a nib.
        previewView.addSubview(session.previewView)
        session.previewView.frame = previewView.bounds
        session.delegate = self
        
        socket.on("connect") {data, ack in
            self.socket.emit("create_room", self.room.key)
        }
        infoLabel.text = "room: \(room.key)"
          
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        socket.connect()
        session.startRtmpSessionWithURL(Config.rtmpPushUrl, andStreamKey: room.key)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        socket.emitWithAck("close_room", room.key)(timeoutAfter: 0) {data in
            self.socket.disconnect()
        }
        
        session.endRtmpSession()

    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "overlay" {
            overlayController = segue.destinationViewController as! LiveOverlayViewController
            overlayController.socket = socket
            overlayController.room = room
        }
    }

    
        
    func connectionStatusChanged(sessionState: VCSessionState) {
        switch session.rtmpSessionState {
        case .Starting:
            statusLabel.text = "Starting"
        case .Started:
            statusLabel.text = "Started"
        case .Ended:
            statusLabel.text = "Ended"
        case .Error:
            statusLabel.text = "Error"
        case .PreviewStarted:
            statusLabel.text = "PreviewStarted"
        case .None:
            statusLabel.text = "None"
        }
    }
        
    @IBAction func closeButtonPressed(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
