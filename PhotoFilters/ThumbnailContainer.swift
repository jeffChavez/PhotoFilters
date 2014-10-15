//
//  FilterThumbnail.swift
//  PhotoFilters
//
//  Created by Jeff Chavez on 10/14/14.
//  Copyright (c) 2014 Jeff Chavez. All rights reserved.
//

import UIKit

class ThumbnailContainer {
    
    var originalThumbnail : UIImage
    var filteredThumbnail : UIImage?
    var imageQueue : NSOperationQueue
    var ciFilter : CIFilter?
    var gpuContext : CIContext
    var filterName : String
    
    init(filterName : String, thumbnail : UIImage, queue : NSOperationQueue, context : CIContext) {
        self.filterName = filterName
        self.originalThumbnail = thumbnail
        self.imageQueue = queue
        self.gpuContext = context
    }
    
    func generateFilterThumbnail (completionHandler: (filteredThumb: UIImage) -> Void) {
        self.imageQueue.addOperationWithBlock({ () -> Void in
            //set up filter with a CIImage
            var image = CIImage(image: self.originalThumbnail)
            var imageFilter = CIFilter(name: self.filterName)
            imageFilter.setDefaults()
            imageFilter.setValue(image, forKey: kCIInputImageKey)
            
            //generate the results
            var result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
            var extent = result.extent()
            var imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
            self.ciFilter = imageFilter
            
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                self.filteredThumbnail = UIImage(CGImage: imageRef)
                completionHandler(filteredThumb: self.filteredThumbnail!)
            })
        })
    }
}