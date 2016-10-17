//
//  Model.swift
//  Live
//
//  Created by leo on 16/7/13.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import Foundation

struct Room {
    
    var key: String
    var title: String
    
    init(dict: [String: AnyObject]) {
        title = dict["title"] as! String
        key = dict["key"] as! String
    }
    
    func toDict() -> [String: AnyObject] {
        return [
            "title": title as AnyObject,
            "key": key as AnyObject
        ]
    }
}


struct Comment {
    
    var text: String
    
    init(dict: [String: AnyObject]) {
        text = dict["text"] as! String
    }
}


struct User {
    
    var id = Int(arc4random())
    
    static let currentUser = User()
}


class GiftEvent: NSObject {
    
    var senderId: Int
    
    var giftId: Int
    
    var giftCount: Int
    
    init(dict: [String: AnyObject]) {
        senderId = dict["senderId"] as! Int
        giftId = dict["giftId"] as! Int
        giftCount = dict["giftCount"] as! Int
    }
    
    func shouldComboWith(_ event: GiftEvent) -> Bool {
        return senderId == event.senderId && giftId == event.giftId
    }
    
}


