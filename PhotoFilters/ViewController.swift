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
import Social
import Photos

class ViewController: UIViewController, PassToVCDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate {
 
    @IBOutlet var photoImageView : UIImageView!
    @IBOutlet var collectionView : UICollectionView!
    @IBOutlet var collectionViewBottomConstraint : NSLayoutConstraint!
    @IBOutlet var imageViewLeadingConstraint : NSLayoutConstraint!
    @IBOutlet var imageViewTrailingConstraint : NSLayoutConstraint!
    @IBOutlet var imageViewBottomConstraint : NSLayoutConstraint!
    @IBOutlet var photoButtonPressed : UIButton!
    
    var managedObjectContext : NSManagedObjectContext!
    var filterArray : [Filter]?
    var thumbnailContainers = [ThumbnailContainer]()
    var originalThumbnail : UIImage?
    var gpuContext : CIContext?
    var imageQueue = NSOperationQueue()
    var originalImage : UIImage?
    var filteredImage : UIImage?
    var tweetNavButton : UIBarButtonItem!
    var saveToPhotoAlbumNavButton : UIBarButtonItem!
    
    var redBox : UIView!
    var blueBox : UIView!
    var greenBox : UIView!
    
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
        monochromeUI()
    }

    override func viewWillAppear(animated: Bool) {
        if self.photoImageView.image != nil {
            tweetNavButton = UIBarButtonItem(title: "Tweet", style: UIBarButtonItemStyle.Done, target: self, action: "postTweet")
            self.navigationItem.rightBarButtonItem = tweetNavButton

            saveToPhotoAlbumNavButton = UIBarButtonItem(title: "Save to Album", style: UIBarButtonItemStyle.Done, target: self, action: "saveToPhotosAlbum")
            self.navigationItem.leftBarButtonItem = saveToPhotoAlbumNavButton
        }
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
        
        var monochrome = NSEntityDescription.insertNewObjectForEntityForName("Filter", inManagedObjectContext: managedObjectContext) as Filter
        monochrome.name = "CIColorMonochrome"
        
        var error: NSError?
        self.managedObjectContext?.save(&error)
    }
    
    func resetThumbnails() {
        
        //create a thumbnail from the image selected
        var size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        self.photoImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        //create an array of instances of ThumbnailContainers with different filters for each instance
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
        let photoFrameworkAction = UIAlertAction(title: "Photos Framework", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("SHOW_PHOTO_FRAMEWORK", sender: self)
        }
        let avFoundationAction = UIAlertAction(title: "AVFoundation", style: UIAlertActionStyle.Default) { (action) -> Void in
            self.performSegueWithIdentifier("SHOW_AV", sender: self)
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
            self.navigationItem.rightBarButtonItem = nil
            self.navigationItem.leftBarButtonItem = nil
        }
        let cancelAction = UIAlertAction(title: "cancel", style: UIAlertActionStyle.Cancel, handler: nil)
        alertControlller.addAction(galleryAction)
        alertControlller.addAction(photoFrameworkAction)
        alertControlller.addAction(photoAlbumAction)
        alertControlller.addAction(cameraAction)
        alertControlller.addAction(avFoundationAction)
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
        self.originalImage = info[UIImagePickerControllerEditedImage] as? UIImage
        self.resetThumbnails()
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "SHOW_GALLERY"{
            let destinationVC = segue.destinationViewController as GalleryViewController
            destinationVC.delegate = self
        } else if segue.identifier == "SHOW_PHOTO_FRAMEWORK" {
            let destinationVC = segue.destinationViewController as PhotoFrameworkViewController
            destinationVC.delegate = self
            destinationVC.vcCellSize = self.photoImageView.frame.size
        } else {
            let destinationVC = segue.destinationViewController as AVFoundationCameraViewController
            destinationVC.delegate = self
        }
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
        self.imageQueue.addOperationWithBlock(
            { () -> Void in
                var image = CIImage(image: self.originalImage)
                var imageFilter = CIFilter(name: self.filterArray![indexPath.row].name)
                imageFilter.setDefaults()
                imageFilter.setValue(image, forKey: kCIInputImageKey)
                if imageFilter.name() == "CIColorMonochrome" {
                    var color = CIColor(color: UIColor.redColor())
                    var intensity = 1.5
                    imageFilter.setValue(image, forKey: kCIInputImageKey)
                    imageFilter.setValue(color, forKey: kCIInputColorKey)
                    imageFilter.setValue(intensity, forKey: kCIInputIntensityKey)
                }
                var result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
                var extent = result.extent()
                var imageRef = self.gpuContext!.createCGImage(result, fromRect: extent)
                
                NSOperationQueue.mainQueue().addOperationWithBlock(
                    { () -> Void in
                        var filteredImage = UIImage(CGImage: imageRef)
                        self.photoImageView.image = filteredImage
                })
        })
        self.collectionView.reloadData()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.thumbnailContainers.count
    }
    
    func didTapOnPicture(image: UIImage) {
        self.photoImageView.image = image
        self.originalImage = image
        self.resetThumbnails()
    }
    
    //HELPER FUNCTIONS
    func enterFilterMode () {
        self.photoButtonPressed.hidden = true
        self.collectionViewBottomConstraint.constant = 100
        self.imageViewBottomConstraint.constant = self.imageViewBottomConstraint.constant * 2
        self.imageViewLeadingConstraint.constant = self.imageViewLeadingConstraint.constant * 2
        self.imageViewTrailingConstraint.constant = self.imageViewTrailingConstraint.constant * 2
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.redBox.center.x = self.view.center.x - 50
            self.blueBox.center.x = self.view.center.x
            self.greenBox.center.x = self.view.center.x + 50
        })
        
        var doneButton = UIBarButtonItem(title: "Done", style: UIBarButtonItemStyle.Done, target: self, action: "doneFilterMode")
        self.navigationItem.rightBarButtonItem = doneButton
        
        var cancelButton = UIBarButtonItem(title: "Cancel", style: UIBarButtonItemStyle.Done, target: self, action: "cancelFilterMode")
        self.navigationItem.leftBarButtonItem = cancelButton
    }

    func doneFilterMode () {
        self.photoButtonPressed.hidden = false
        self.collectionViewBottomConstraint.constant = -100
        self.imageViewBottomConstraint.constant = self.imageViewBottomConstraint.constant / 2
        self.imageViewLeadingConstraint.constant = self.imageViewLeadingConstraint.constant / 2
        self.imageViewTrailingConstraint.constant = self.imageViewTrailingConstraint.constant / 2
        self.navigationItem.rightBarButtonItem = tweetNavButton
        self.navigationItem.leftBarButtonItem = saveToPhotoAlbumNavButton
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.redBox.frame.origin.x = -100
            self.blueBox.frame.origin.x = -100
            self.greenBox.frame.origin.x = -100
        })
        
        self.originalImage = self.photoImageView.image
    }
    
    func cancelFilterMode () {
        self.photoButtonPressed.hidden = false
        self.collectionViewBottomConstraint.constant = -100
        self.imageViewBottomConstraint.constant = self.imageViewBottomConstraint.constant / 2
        self.imageViewLeadingConstraint.constant = self.imageViewLeadingConstraint.constant / 2
        self.imageViewTrailingConstraint.constant = self.imageViewTrailingConstraint.constant / 2
        self.navigationItem.rightBarButtonItem = tweetNavButton
        self.navigationItem.leftBarButtonItem = saveToPhotoAlbumNavButton
        
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.layoutIfNeeded()
            self.redBox.frame.origin.x = -100
            self.blueBox.frame.origin.x = -100
            self.greenBox.frame.origin.x = -100
        })
        
        self.photoImageView.image = self.originalImage
    }
    
    func postTweet () {
        if SLComposeViewController.isAvailableForServiceType(SLServiceTypeTwitter) {
            var tweetBox = SLComposeViewController(forServiceType:SLServiceTypeTwitter)
            tweetBox.setInitialText("Post a Tweet")
            tweetBox.addImage(self.photoImageView.image)
            self.presentViewController(tweetBox, animated: true, completion: nil)
        }
    }
    
    func saveToPhotosAlbum () {
        let alertController = UIAlertController(title: "Save", message: "Would you like to save this photo to your library?", preferredStyle: UIAlertControllerStyle.Alert)
        alertController.addAction(UIAlertAction(title: "Yes", style: UIAlertActionStyle.Default, handler: { (action) -> Void in
            PHPhotoLibrary.sharedPhotoLibrary().performChanges({
                let changeRequest = PHAssetChangeRequest.creationRequestForAssetFromImage(self.photoImageView.image)
                }, completionHandler: { (action) -> Void in
                    let alertView = UIAlertView()
                    alertView.title = "Success"
                    alertView.message = "Your photo has been saved to your Library"
                    alertView.addButtonWithTitle("OK")
                    alertView.show()
                })
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: UIAlertActionStyle.Cancel, handler: nil))
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    //WARNING: SMELLY CODE BELOW, HOLD BREATH WHILE READING
    func monochromeUI () {
        self.redBox = UIView(frame: CGRectMake(self.view.bounds.origin.x - 100, self.view.bounds.height - 75, self.view.bounds.width / 10, self.view.bounds.width / 10))
        self.redBox.backgroundColor = UIColor(red: 0.85, green: 0.17, blue: 0.21, alpha: 1)
        self.view.addSubview(self.redBox)
        
        var tapRed = UITapGestureRecognizer(target: self, action: "setRed:")
        tapRed.numberOfTapsRequired = 1
        self.redBox.addGestureRecognizer(tapRed)
        
        self.blueBox = UIView(frame: CGRectMake(self.redBox.bounds.origin.x - 100, self.view.bounds.height - 75, self.view.bounds.width / 10, self.view.bounds.width / 10))
        self.blueBox.backgroundColor = UIColor(red: 0, green: 0.62, blue: 0.75, alpha: 1)
        self.view.addSubview(self.blueBox)
        
        var tapBlue = UITapGestureRecognizer(target: self, action: "setBlue:")
        tapBlue.numberOfTapsRequired = 1
        self.blueBox.addGestureRecognizer(tapBlue)
        
        self.greenBox = UIView(frame: CGRectMake(self.blueBox.bounds.origin.x - 100, self.view.bounds.height - 75, self.view.bounds.width / 10, self.view.bounds.width / 10))
        self.greenBox.backgroundColor = UIColor(red: 0.51, green: 0.75, blue: 0.34, alpha: 1)
        self.view.addSubview(self.greenBox)
        
        var tapGreen = UITapGestureRecognizer(target: self, action: "setGreen:")
        tapGreen.numberOfTapsRequired = 1
        self.greenBox.addGestureRecognizer(tapGreen)
    }
    
    func setRed (gestureRecognizer: UIPinchGestureRecognizer) {
        self.imageQueue.addOperationWithBlock(
            { () -> Void in
                var image = CIImage(image: self.originalImage)
                var imageFilter = CIFilter(name: "CIColorMonochrome")
                imageFilter.setDefaults()
                var color = CIColor(color: self.redBox.backgroundColor!)
                var number = 1 * 1.25
                imageFilter.setValue(image, forKey: kCIInputImageKey)
                imageFilter.setValue(color, forKey: kCIInputColorKey)
                imageFilter.setValue(number, forKey: kCIInputIntensityKey)
                var result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
                var extent = result.extent()
                var imageRef = self.gpuContext!.createCGImage(result, fromRect: extent)
                
                NSOperationQueue.mainQueue().addOperationWithBlock(
                    { () -> Void in
                        var filteredImage = UIImage(CGImage: imageRef)
                        self.photoImageView.image = filteredImage
                })
        })
    }
    
    func setBlue (gestureRecognizer: UIPinchGestureRecognizer) {
        self.imageQueue.addOperationWithBlock(
            { () -> Void in
                var image = CIImage(image: self.originalImage)
                var imageFilter = CIFilter(name: "CIColorMonochrome")
                imageFilter.setDefaults()
                var color = CIColor(color: self.blueBox.backgroundColor!)
                var number = 1 * 1.25
                imageFilter.setValue(image, forKey: kCIInputImageKey)
                imageFilter.setValue(color, forKey: kCIInputColorKey)
                imageFilter.setValue(number, forKey: kCIInputIntensityKey)
                var result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
                var extent = result.extent()
                var imageRef = self.gpuContext!.createCGImage(result, fromRect: extent)
                
                NSOperationQueue.mainQueue().addOperationWithBlock(
                    { () -> Void in
                        var filteredImage = UIImage(CGImage: imageRef)
                        self.photoImageView.image = filteredImage
                })
        })
    }
    
    func setGreen (gestureRecognizer: UIPinchGestureRecognizer) {
        self.imageQueue.addOperationWithBlock(
            { () -> Void in
                var image = CIImage(image: self.originalImage)
                var imageFilter = CIFilter(name: "CIColorMonochrome")
                imageFilter.setDefaults()
                var color = CIColor(color: self.greenBox.backgroundColor!)
                var number = 1 * 1.25
                imageFilter.setValue(image, forKey: kCIInputImageKey)
                imageFilter.setValue(color, forKey: kCIInputColorKey)
                imageFilter.setValue(number, forKey: kCIInputIntensityKey)
                var result = imageFilter.valueForKey(kCIOutputImageKey) as CIImage
                var extent = result.extent()
                var imageRef = self.gpuContext!.createCGImage(result, fromRect: extent)
                
                NSOperationQueue.mainQueue().addOperationWithBlock(
                    { () -> Void in
                        var filteredImage = UIImage(CGImage: imageRef)
                        self.photoImageView.image = filteredImage
                })
        })
    }
}














