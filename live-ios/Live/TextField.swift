//
//  TextField.swift
//  Live
//
//  Created by leo on 16/7/13.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit

@IBDesignable
class TextField: UITextField {
    
    @IBInspectable var insetX: CGFloat = 0
    @IBInspectable var insetY: CGFloat = 0
    
    // placeholder position
    override func textRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , insetX , insetY)
    }
    
    // text position
    override func editingRectForBounds(bounds: CGRect) -> CGRect {
        return CGRectInset(bounds , insetX , insetY)
    }
}
