//
//  CoreDataSeeder.swift
//  PhotoFilters
//
//  Created by Jeff Chavez on 10/14/14.
//  Copyright (c) 2014 Jeff Chavez. All rights reserved.
//

import Foundation
import CoreData

class CoreDataSeeder {
    
    var managedObjectContext : NSManagedObjectContext!
    
    init (context: NSManagedObjectContext) {
        self.managedObjectContext = context
    }
    
    func seedCoreData() {
        var sepia = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        sepia.name = "CISepiaTone"
        
        var gaussianBlur = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: self.managedObjectContext) as Filter
        gaussianBlur.name = "CIGaussianBlur"
        gaussianBlur.favorited = true
        
        var pixellate = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
        pixellate.name = "CIPixellate"
        
        var gammaAdjust = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
        gammaAdjust.name = "CIGammaAdjust"
        
        var exposureAdjust = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
        exposureAdjust.name = "CIExposureAdjust"
        
        var chrome = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
        chrome.name = "CIPhotoEffectChrome"
        
        var instant = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
        instant.name = "CIPhotoEffectInstant"
        
        var mono = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
        mono.name = "CIPhotoEffectMono"
        
        var noir = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
        noir.name = "CIPhotoEffectNoir"
        
        var tonal = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
        tonal.name = "CIPhotoEffectTonal"
        
        
        var error: NSError?
        self.managedObjectContext?.save(&error)
    }
}