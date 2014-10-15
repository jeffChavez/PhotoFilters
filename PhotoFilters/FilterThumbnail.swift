//
//  FilterThumbnail.swift
//  PhotoFilters
//
//  Created by Jeff Chavez on 10/14/14.
//  Copyright (c) 2014 Jeff Chavez. All rights reserved.
//

import UIKit

class FilterThumbnail {
    
    var originalThumbnail : UIImage
    var filteredThumbnail : UIImage?
    var imageQueue : NSOperationQueue?
    var gpuContext : CIContext
    var filter : CIFilter?
    var filterName : String
    
    init (name: String, thumbnail: UIImage, queue: NSOperationQueue, context: CIContext) {
        self.filterName = name
        self.originalThumbnail = thumbnail
        self.imageQueue = queue
        self.gpuContext = context
    }
    
    func generateThumbnail (completionHandler: (image: UIImage) -> Void) {
        self.imageQueue?.addOperationWithBlock({ () -> Void in
            //set up filter with a CIImage
            var image = CIImage(image: self.originalThumbnail)
            var imageFilter = CIFilter(name: self.filterName)
            imageFilter.setDefaults()
            imageFilter.setValue(image, forKey: kCIInputImageKey)
            
            //generate the results
            var result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
            var extent = result.extent()
            var imageRef = self.gpuContext.createCGImage(result, fromRect: extent)
            self.filter = imageFilter
            self.filteredThumbnail = UIImage(CGImage: imageRef)
            NSOperationQueue.mainQueue().addOperationWithBlock({ () -> Void in
                completionHandler(image: self.filteredThumbnail!)
            })
        })
    }
}