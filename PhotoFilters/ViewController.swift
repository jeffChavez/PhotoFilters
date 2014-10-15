//
//  ViewController.swift
//  PhotoFilters
//
//  Created by Jeff Chavez on 10/13/14.
//  Copyright (c) 2014 Jeff Chavez. All rights reserved.
//

import UIKit
import CoreData
import CoreImage
import OpenGLES

class ViewController: UIViewController, GalleryDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
 
    @IBOutlet var photoImageView : UIImageView!
    @IBOutlet var collectionView : UICollectionView!
    @IBOutlet var collectionViewBottomConstraint : NSLayoutConstraint!
    @IBOutlet var imageViewLeadingConstraint : NSLayoutConstraint!
    @IBOutlet var imageViewTrailingConstraint : NSLayoutConstraint!
    @IBOutlet var imageViewBottomConstraint : NSLayoutConstraint!
    
    var managedObjectContext : NSManagedObjectContext!
    var filterArray : [Filter]?
    var thumbnailContainers = [ThumbnailContainer]()
    var originalThumbnail : UIImage?
    var gpuContext : CIContext?
    var imageQueue = NSOperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //get gpu context
        var options = [kCIContextWorkingColorSpace : NSNull()]
        var myEAGLContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        self.gpuContext = CIContext(EAGLContext: myEAGLContext, options: options)
        
        let appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        self.managedObjectContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest(entityName: "Filter")
        var error : NSError?
        if let filters = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [Filter] {
            if filters.isEmpty {
                self.seedCoreData()
                self.filterArray = self.managedObjectContext.executeFetchRequest(fetchRequest, error: &error) as? [Filter]
            } else {
                self.filterArray = filters
            }
        }
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
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
    
    func resetThumbnails() {
        
        //first we generate the thumbnail from the image that was selected
        var size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        self.photoImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //now we need to setup our thumbnail containers
        var newThumbnailContainers = [ThumbnailContainer]()
        for var index = 0; index < self.filterArray?.count; ++index {
            let filter = self.filterArray![index]
            var thumbnailContainer = ThumbnailContainer(filterName: filter.name, thumbnail: self.originalThumbnail!, queue: self.imageQueue, context: self.gpuContext!)
            newThumbnailContainers.append(thumbnailContainer)
        }
        self.thumbnailContainers = newThumbnailContainers
        self.collectionView.reloadData()
    }

    @IBAction func photoButtonPressed (sender: AnyObject) {
        let alertControlller = UIAlertController(title: nil, message: "Choose an option", preferredStyle: UIAlertControllerStyle.ActionSheet)
        let galleryAction = UIAlertAction(title: "Gallery", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("SHOW_GALLERY", sender: self)
        }
        let photoAlbumAction = UIAlertAction(title: "Album", style: UIAlertActionStyle.Default) { (action) -> Void in
            let imagePicker = UIImagePickerController()
            imagePicker.allowsEditing = true
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.SavedPhotosAlbum
            self.presentViewController(imagePicker, animated: true, completion:nil)
        }
        let cameraAction = UIAlertAction(title: "Camera", style: UIAlertActionStyle.Default) { (action) -> Void in
            let imagePicker = UIImagePickerController()
            if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
                imagePicker.allowsEditing = true
                imagePicker.delegate = self
                imagePicker.sourceType = UIImagePickerControllerSourceType.Camera
                self.presentViewController(imagePicker, animated: true, completion: nil)
            } else {
                let alertView = UIAlertView()
                alertView.title = "Error"
                alertView.message = "You do not have a camera available"
                alertView.addButtonWithTitle("OK")
                alertView.show()
            }
        }
        
        let filterAction = UIAlertAction(title: "Filter", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.enterFilterMode()
        }
        let deleteAction = UIAlertAction(title: "Delete Photo", style: UIAlertActionStyle.Destructive) { (action) -> Void in
            self.photoImageView.image = nil
        }
        let cancelAction = UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        
        alertControlller.addAction(galleryAction)
        alertControlller.addAction(photoAlbumAction)
        alertControlller.addAction(cameraAction)
        if self.photoImageView.image != nil {
            alertControlller.addAction(filterAction)
            alertControlller.addAction(deleteAction)
        }
        alertControlller.addAction(cancelAction)
        
        //when the view controller is presented a strong reference is created.
        self.presentViewController(alertControlller, animated: true, completion: nil)
    }
    
    //IMAGEPICKER DELEGATE
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.photoImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        self.resetThumbnails()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as GalleryViewController
        destinationVC.delegate = self
    }
    
    //COLLECTIONVIEW DATASOURCE & DELEGATE
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("THUMBNAIL_CELL", forIndexPath: indexPath) as ThumbnailCell
        var thumbnailContainer = self.thumbnailContainers[indexPath.row]
        if thumbnailContainer.filteredThumbnail != nil {
            cell.imageView.image = thumbnailContainer.filteredThumbnail
        } else {
            cell.imageView.image = thumbnailContainer.originalThumbnail
            thumbnailContainer.generateFilterThumbnail({ (filteredThumb) -> Void in
                
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? ThumbnailCell {
                    cell.imageView.image = filteredThumb
                }
            })
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var thumbnailContainer = ThumbnailContainer(filterName: self.filterArray![indexPath.row].name, thumbnail: self.photoImageView.image!, queue: self.imageQueue, context: self.gpuContext!)
        thumbnailContainer.generateFilterThumbnail { (filteredthumb) -> Void in
            self.photoImageView.image = filteredthumb
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.thumbnailContainers.count
    }
    
    func didTapOnPicture(image: UIImage) {
        self.photoImageView.image = image
        self.resetThumbnails()
    }
    
    //HELPER FUNCTIONS
    func enterFilterMode () {
        self.collectionViewBottomConstraint.constant = 100
        self.imageViewBottomConstraint.constant = self.imageViewBottomConstraint.constant * 3
        self.imageViewLeadingConstraint.constant = self.imageViewLeadingConstraint.constant * 3
        self.imageViewTrailingConstraint.constant = self.imageViewTrailingConstraint.constant * 3
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
        
        var doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "exitFilterMode")
        self.navigationItem.rightBarButtonItem = doneButton
    }
    
    func exitFilterMode () {
        self.collectionViewBottomConstraint.constant = -100
        self.imageViewBottomConstraint.constant = self.imageViewBottomConstraint.constant / 3
        self.imageViewLeadingConstraint.constant = self.imageViewLeadingConstraint.constant / 3
        self.imageViewTrailingConstraint.constant = self.imageViewTrailingConstraint.constant / 3
        self.navigationItem.rightBarButtonItem = nil
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
        })
    }
}