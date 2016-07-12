//
//  WaveEmitterView.swift
//  Live
//
//  Created by leo on 16/7/12.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit

public class WaveEmitterView : UIView {
    
    public var amplitudeRange = 12
    public var amplitude = 3
    
    public var duration: CFTimeInterval = 4
    public var durationRange: CFTimeInterval = 1
    
    public var maximumCount = 100
    
    var currentCount = 0
    var unusedLayers: [CALayer] = []
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.setup()
    }
    
    func setup() {
        
    }
    
    func getPathInRect(rect: CGRect) -> UIBezierPath {
        let centerX = CGRectGetMidX(rect);
        let height = CGRectGetHeight(rect);
        let path = UIBezierPath();
        let offset = Float(arc4random() % 1000);
        let finalAmplitude = amplitude + Int(arc4random()) % amplitudeRange * 2 - amplitudeRange;
        var delta = CGFloat(0);
        var y = height
        while y >= 0  {
            let x = Float(finalAmplitude) * sinf((Float(y) + offset) * Float(M_PI) / 180);
            if y == height {
                delta = CGFloat(x)
                path.moveToPoint(CGPoint(x:centerX, y: y))
            } else {
                path.addLineToPoint(CGPoint(x:CGFloat(x) + centerX - delta, y: y))
            }
            y = y - 1
        }
        return path
    }
    
    public func emitImage(image: UIImage) {
        guard currentCount < maximumCount else {
            return
        }
        currentCount = currentCount + 1
        
        let height = CGRectGetHeight(bounds)
        let percent = Double(arc4random() % 100) / 100.0
        let duration = self.duration + percent * durationRange * 2 - durationRange
        var layer: CALayer
        if unusedLayers.count > 0 {
            layer = unusedLayers.last!
            unusedLayers.removeLast()
        } else {
            layer = CALayer();
        }
        layer.contents = image.CGImage
        layer.opacity = 1;
        layer.frame = CGRectMake(0, 0, image.size.width, image.size.height)
        layer.position = CGPointMake(CGRectGetMidX(self.bounds), height)
        self.layer.addSublayer(layer)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            layer.removeFromSuperlayer()
            self.unusedLayers.append(layer)
            self.currentCount = self.currentCount - 1
        }
        
        let position = CAKeyframeAnimation(keyPath: "position")
        position.path = getPathInRect(bounds).CGPath
        position.duration = duration
        layer.addAnimation(position, forKey: "position")
        
        let delay = duration / 2;
        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.fromValue = 1
        opacity.toValue = 0
        opacity.beginTime = CACurrentMediaTime() + delay
        opacity.removedOnCompletion = false
        opacity.fillMode = kCAFillModeForwards
        opacity.duration = duration - delay - 0.1
        layer.addAnimation(opacity, forKey: "opacity")
        
        CATransaction.commit()
    }
    
}