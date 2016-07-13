//
//  String.swift
//  Todotrix
//
//  Created by leo on 16/7/4.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit
import TextAttributes

public extension NSAttributedString {
    
    func heightWithConstrainedWidth(width: CGFloat) -> CGFloat {
        let boundingSize = CGSize(width: width, height: CGFloat.max)
        let options = NSStringDrawingOptions.UsesLineFragmentOrigin
        let size = boundingRectWithSize(boundingSize, options: options, context: nil)
        return ceil(size.height)
    }
}

public extension String {
    
    func attributedComment() -> NSAttributedString {
        let attrs = TextAttributes()
            .font(UIFont.defaultFont(size: 13))
            .foregroundColor(UIColor.whiteColor())
            .alignment(.Left)
            .lineSpacing(1)
            .dictionary
        return NSAttributedString(string: self, attributes: attrs)
    }
    
    static func random(length: Int = 4) -> String {
        let base = "abcdefghijklmnopqrstuvwxyz"
        var randomString: String = ""
        for _ in 0..<length {
            let randomValue = arc4random_uniform(UInt32(base.characters.count))
            randomString += "\(base[base.startIndex.advancedBy(Int(randomValue))])"
        }
        return randomString
    }
    
}