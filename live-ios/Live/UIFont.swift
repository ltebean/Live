//
//  UIFont.swift
//  Slowmo
//
//  Created by ltebean on 16/4/21.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit

extension UIFont {
    
    static func defaultFont(size: CGFloat) -> UIFont {
        return UIFont(name: UIFont.defaultFontName(), size: size)!
    }
    
    static func defaultFontName() -> String {
        return "Raleway-Regular"
    }
    
}
