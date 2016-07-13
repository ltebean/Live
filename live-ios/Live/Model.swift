//
//  Model.swift
//  Live
//
//  Created by leo on 16/7/13.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import Foundation

class Room: NSObject {
    
    var key: String
    
    init(dict: [String: AnyObject]) {
        key = dict["key"] as! String
    }
}

class Comment: NSObject {
    
    var text: String
    
    init(dict: [String: AnyObject]) {
        text = dict["text"] as! String
    }
}
