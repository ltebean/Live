//
//  GiftDisplayArea.swift
//  Live
//
//  Created by leo on 16/7/15.
//  Copyright © 2016年 io.ltebean. All rights reserved.
//

import UIKit

class GiftDisplayArea: UIView {
    
    var eventQueue: [GiftEvent] = []
    var availablePositions = [0, 1]
    var reusableViews: [GiftDisplayView] = []
    var currentViews: [GiftDisplayView] = []
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        
    }
    
    func pushGiftEvent(_ event: GiftEvent) {
        if let queuedEvent = eventQueue.filter({ $0.shouldComboWith(event)}).first {
            queuedEvent.giftCount += event.giftCount
        } else {
            eventQueue.insert(event, at: 0)
        }
        handleNextEvent()
    }
    
    func handleNextEvent() {
        guard let event = eventQueue.popLast() else {
            return
        }

        if let view = currentViews.filter({ $0.initialGiftEvent.shouldComboWith(event)}).first {
            view.finalCombo += event.giftCount
            view.lastEventTime = Date().timeIntervalSince1970
            return
        }
        
        if availablePositions.count == 0 {
            eventQueue.append(event)
            return
        }
        
        let position = availablePositions.popLast()!
        
        let view = dequeueResuableView()
        currentViews.append(view)
        view.initialGiftEvent = event
        view.lastEventTime = Date().timeIntervalSince1970
        view.currentCombo = 1
        view.finalCombo = event.giftCount
        view.frame.origin.y = view.frame.height * CGFloat(position)
        view.tag = position
        view.transform.tx = -200
        addSubview(view)
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            view.transform.tx = 0
        }, completion: { finished in
            view.startAnimateCombo()
            self.handleNextEvent()
        })
        
    }
    
    func dismissView(_ view: GiftDisplayView) {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: [], animations: {
            view.transform.ty = -20
            view.alpha = 0
        }, completion: { finished in
            view.removeFromSuperview()
            view.alpha = 1
            view.transform.ty = 0
            self.currentViews = self.currentViews.filter({ $0 != view })
            self.availablePositions.append(view.tag)
            view.prepareForReuse()
            self.enqueueResuableView(view)
            self.handleNextEvent()
        })
    }
    
    func dequeueResuableView() -> GiftDisplayView {
        if let view = reusableViews.popLast() {
            return view
        } else {
            let view = GiftDisplayView(frame: CGRect(x: 0,  y: 0, width: 100, height: 60))
            view.needsDismiss = { [weak self] view in
                self?.dismissView(view)
            }
            return view
        }
    }
    
    func enqueueResuableView(_ view: GiftDisplayView)  {
        reusableViews.append(view)
    }
    
    
}



