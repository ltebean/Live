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
import IHKeyboardAvoiding
import SVProgressHUD

class BroadcasterViewController: UIViewController, VCSessionDelegate {
        
    @IBOutlet weak var previewView: UIView!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var titleTextField: TextField!
    @IBOutlet weak var inputTitleOverlay: UIVisualEffectView!
    @IBOutlet weak var inputContainer: UIView!
    
    
    let socket = SocketIOClient(socketURL: NSURL(string: Config.serverUrl)!, options: [.Log(true), .ForceWebsockets(true)])

    let session = VCSimpleSession(videoSize: CGSize(width: 720, height: 1280), frameRate: 20, bitrate: 1000000, useInterfaceOrientation: false)
    var room: Room!
    
    var overlayController: LiveOverlayViewController!

    override func viewDidLoad() {
        super.viewDidLoad()
            // Do any additional setup after loading the view, typically from a nib.
        previewView.addSubview(session.previewView)
        session.previewView.frame = previewView.bounds
        
        IHKeyboardAvoiding.setAvoidingView(inputContainer)
    }
    
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        session.delegate = self
    }
    
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        session.delegate = nil
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "overlay" {
            overlayController = segue.destinationViewController as! LiveOverlayViewController
            overlayController.socket = socket
        }
    }

    func start() {
        room = Room(dict: [
            "title": titleTextField.text!,
            "key": String.random()
        ])
        
        overlayController.room = room
        
        session.startRtmpSessionWithURL(Config.rtmpPushUrl, andStreamKey: room.key)
        
        socket.connect()
        socket.once("connect") {[weak self] data, ack in
            guard let this = self else {
                return
            }
            this.socket.emit("create_room", this.room.toDict())
        }
        
        infoLabel.text = "Room: \(room.key)"
        IHKeyboardAvoiding.setAvoidingView(overlayController.inputContainer)
    }
    
    func stop() {
        guard room != nil else {
            return
        }
        session.endRtmpSession()
        socket.disconnect()
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
    
    
    @IBAction func startButtonPressed(sender: AnyObject) {
        titleTextField.resignFirstResponder()
        start()
        UIView.animateWithDuration(0.2, animations: {
            self.inputTitleOverlay.alpha = 0
        }, completion: { finished in
            self.inputTitleOverlay.hidden = true
        })
    }
        
    @IBAction func closeButtonPressed(sender: AnyObject) {
        stop()
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return .LightContent
    }
}
