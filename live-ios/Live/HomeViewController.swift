//
//  HomeViewController.swift
//  Live
//
//  Created by leo on 16/7/11.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit
import SVProgressHUD

class HomeViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    
    var rooms: [Room] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableFooterView = UIView()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        refresh()
    }
    
    @IBAction func newButtonPressed(sender: AnyObject) {
        createRoom()
    }
    
    @IBAction func refreshButtonPressed(sender: AnyObject) {
        refresh()
    }
    
    func refresh() {
        SVProgressHUD.show()
        let request = NSURLRequest(URL: NSURL(string: "\(Config.serverUrl)/rooms")!)
        NSURLConnection.sendAsynchronousRequest(request, queue: NSOperationQueue.mainQueue(), completionHandler: { resp, data, err in
            guard err == nil else {
                SVProgressHUD.showErrorWithStatus("Error")
                return
            }
            SVProgressHUD.dismiss()
            let rooms = try! NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as! [[String: AnyObject]]
            self.rooms = rooms.map {
                Room(dict: $0)
            }
            self.tableView.reloadData()
        })
    }
    
    func createRoom() {
        let vc = R.storyboard.main.broadcast()!
        presentViewController(vc, animated: true, completion: nil)
    }
    
    func joinRoom(room: Room) {
        let vc = R.storyboard.main.audience()!
        vc.room = room
        presentViewController(vc, animated: true, completion: nil)
    }
    
}

extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rooms.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("cell", forIndexPath: indexPath)
        let room = rooms[indexPath.row]
        cell.textLabel!.text = "Room: \(room.title != "" ? room.title : room.key)"
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let room = rooms[indexPath.row]
        joinRoom(room)
    }
    
}

