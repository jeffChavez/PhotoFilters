//
//  PinchGesture.swift
//  PhotoFilters
//
//  Created by Jeff Chavez on 10/16/14.
//  Copyright (c) 2014 Jeff Chavez. All rights reserved.
//

import UIKit

class PinchGesture : NSObject {
 
    var collectionView : UICollectionView?
    var flowLayout : UICollectionViewFlowLayout?
    
    override init () {
        
    }

    func handlePinch (gestureRecognizer: UIPinchGestureRecognizer) {
        println("gesture")
        if gestureRecognizer.state == UIGestureRecognizerState.Began {
            
        }
        if gestureRecognizer.state == UIGestureRecognizerState.Changed {
            
        }
        if gestureRecognizer.state == UIGestureRecognizerState.Ended {
            self.collectionView!.performBatchUpdates({ () -> Void in
                var currentSize = self.flowLayout!.itemSize
                if gestureRecognizer.velocity < 0 {
                    self.flowLayout!.itemSize = CGSize(width: currentSize.width * 2, height: currentSize.height * 2)
                } else {
                    self.flowLayout!.itemSize = CGSize(width: currentSize.width / 2, height: currentSize.height / 2)
                }
                }, completion: nil)
        }
    }
}