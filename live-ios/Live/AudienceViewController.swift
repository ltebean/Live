
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
    @IBOutlet weak var statusLabel: UILabel!
    
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
        
        socket.on("connect") {[weak self] data, ack in
            self?.joinRoom()
        }
        
    }
    
    func joinRoom() {
        socket.emit("join_room", room.key)
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
        
        NSNotificationCenter.defaultCenter().addObserverForName(IJKMPMoviePlayerLoadStateDidChangeNotification, object: player, queue: NSOperationQueue.mainQueue(), usingBlock: { [weak self] notification in
            
            guard let this = self else {
                return
            }
            let state = this.player.loadState
            switch state {
            case IJKMPMovieLoadState.Playable:
                this.statusLabel.text = "Playable"
            case IJKMPMovieLoadState.PlaythroughOK:
                this.statusLabel.text = "Playing"
            case IJKMPMovieLoadState.Stalled:
                this.statusLabel.text = "Buffering"
            default:
                this.statusLabel.text = "Playing"
            }
        })

    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        player.shutdown()
        socket.disconnect()
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    @IBAction func closeButtonPressed(sender: AnyObject) {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
}
