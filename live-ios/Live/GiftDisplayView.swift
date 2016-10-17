//
//  GiftDisplayView.swift
//  Live
//
//  Created by leo on 16/7/15.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit

class GiftDisplayView: XibBasedView {
    
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var comboLabel: UILabel!
    @IBOutlet weak var textContainer: UIView!
    @IBOutlet weak var imageView: UIImageView!
    
    var currentCombo = 0 {
        didSet {
            comboLabel.text = "x\(currentCombo)"
        }
    }
    var initialGiftEvent: GiftEvent! {
        didSet {
            textLabel.text = "Sent a gift"
            imageView.image = UIImage(named: "gift-\(initialGiftEvent.giftId)")
        }
    }
    
    var finalCombo = 0
    var timer: Timer?
    
    var lastEventTime: TimeInterval!
    var maximumStaySeconds: TimeInterval = 5
    
    var needsDismiss: ((_ view: GiftDisplayView) -> ())!
    
    override func load() {
        super.load()
        textContainer.layer.cornerRadius = 3
    }

    func startAnimateCombo() {
        if timer == nil {
            timer = Timer.scheduledTimer(timeInterval: 0.2, target: self, selector: #selector(GiftDisplayView.tick(_:)), userInfo: nil, repeats: true)
        }
    }
    
    func prepareForReuse() {
        currentCombo = 0
        finalCombo = 0
    }
    
    
    func tick(_ timer: Timer) {
        let now = Date().timeIntervalSince1970
        guard (now - lastEventTime) < maximumStaySeconds else {
            self.timer?.invalidate()
            self.timer = nil
            needsDismiss(self)
            return
        }
        guard finalCombo > currentCombo else {
            return
        }
        self.currentCombo += 1

        UIView.animate(withDuration: 0.1, animations: {
            self.comboLabel.scale = 3
        }, completion: { finished in
            UIView.animate(withDuration: 0.1, animations: {
                self.comboLabel.scale = 1
            }, completion: { finished in
            
            })
        })
        
    }
    
    
}
