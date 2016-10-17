//
//  WaveEmitterView.swift
//  Live
//
//  Created by leo on 16/7/12.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//



open class WaveEmitterView : UIView {
    
    open var amplitudeRange = 3
    open var amplitude = 12
    
    open var duration: CFTimeInterval = 4
    open var durationRange: CFTimeInterval = 1
    
    open var maximumCount = 100
    
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
    
    func getPathInRect(_ rect: CGRect) -> UIBezierPath {
        let centerX = rect.midX;
        let height = rect.height;
        let path = UIBezierPath();
        let offset = Float(arc4random() % 1000);
        let finalAmplitude = amplitude + Int(arc4random()) % amplitudeRange * 2 - amplitudeRange;
        var delta = CGFloat(0);
        var y = height
        while y >= 0  {
            let x = Float(finalAmplitude) * sinf((Float(y) + offset) * Float(M_PI) / 180);
            if y == height {
                delta = CGFloat(x)
                path.move(to: CGPoint(x:centerX, y: y))
            } else {
                path.addLine(to: CGPoint(x:CGFloat(x) + centerX - delta, y: y))
            }
            y = y - 1
        }
        return path
    }
    
    open func emitImage(_ image: UIImage) {
        guard currentCount < maximumCount else {
            return
        }
        currentCount = currentCount + 1
        
        let height = bounds.height
        let percent = Double(arc4random() % 100) / 100.0
        let duration = self.duration + percent * durationRange * 2 - durationRange
        var layer: CALayer
        if unusedLayers.count > 0 {
            layer = unusedLayers.last!
            unusedLayers.removeLast()
        } else {
            layer = CALayer();
        }
        layer.contents = image.cgImage
        layer.opacity = 1;
        layer.frame = CGRect(x: 0, y: 0, width: image.size.width, height: image.size.height)
        layer.position = CGPoint(x: self.bounds.midX, y: height)
        self.layer.addSublayer(layer)
        
        CATransaction.begin()
        CATransaction.setCompletionBlock {
            layer.removeFromSuperlayer()
            self.unusedLayers.append(layer)
            self.currentCount = self.currentCount - 1
        }
        
        let position = CAKeyframeAnimation(keyPath: "position")
        position.path = getPathInRect(bounds).cgPath
        position.duration = duration
        layer.add(position, forKey: "position")
        
        let delay = duration / 2;
        let opacity = CABasicAnimation(keyPath: "opacity")
        opacity.fromValue = 1
        opacity.toValue = 0
        opacity.beginTime = CACurrentMediaTime() + delay
        opacity.isRemovedOnCompletion = false
        opacity.fillMode = kCAFillModeForwards
        opacity.duration = duration - delay - 0.1
        layer.add(opacity, forKey: "opacity")
        
        CATransaction.commit()
    }
    
}
