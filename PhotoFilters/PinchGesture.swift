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
                
                var minItemSizeWidth = self.collectionView!.bounds.width / 15
                var maxItemSizeWidth = self.collectionView!.bounds.width / 2
        
                var currentSize = self.flowLayout!.itemSize
                if gestureRecognizer.velocity < 0 {
                    if self.flowLayout!.itemSize.width * 2 < maxItemSizeWidth {
                    self.flowLayout!.itemSize = CGSize(width: currentSize.width * 2, height: currentSize.height * 2)
                    }
                } else {
                    if self.flowLayout!.itemSize.width / 2 > minItemSizeWidth {
                    self.flowLayout!.itemSize = CGSize(width: currentSize.width / 2, height: currentSize.height / 2)
                    }
                }
            }, completion: nil)
        }
    }
}