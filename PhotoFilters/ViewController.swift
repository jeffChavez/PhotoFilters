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
    
    var filterArray = [Filter]()
    var filterThumbnails = [FilterThumbnail]()
    var coreImageContext : CIContext?
    var originalThumbnail : UIImage?
    let imageQueue = NSOperationQueue()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Core Image Context
        var options = [kCIContextWorkingColorSpace : NSNull()]
        var myEAGLContext = EAGLContext(API: EAGLRenderingAPI.OpenGLES2)
        self.coreImageContext = CIContext(EAGLContext: myEAGLContext, options: options)
        
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var seeder = CoreDataSeeder(context: appDelegate.managedObjectContext!)
        
        self.fetchFilters()
        self.generateThumbnail()
        
        if filterArray.isEmpty {
            seeder.seedCoreData()
            self.fetchFilters()
        }
        
        self.resetFilterThumbnails()
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        let destinationVC = segue.destinationViewController as GalleryViewController
        destinationVC.delegate = self
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
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        self.photoImageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("FILTER_CELL", forIndexPath: indexPath) as FilterThumbnailCell
        var filterThumbnail = self.filterThumbnails[indexPath.row]
        if filterThumbnail.filteredThumbnail != nil {
            cell.imageView.image = filterThumbnail.filteredThumbnail
        } else {
            cell.imageView.image = filterThumbnail.originalThumbnail
            filterThumbnail.generateThumbnail({ (image) -> Void in
                
                if let cell = collectionView.cellForItemAtIndexPath(indexPath) as? FilterThumbnailCell {
                    cell.imageView.image = image
                }
            })
        }
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        var filteredThumbnail = FilterThumbnail(name: self.filterArray[indexPath.row].name, thumbnail: self.photoImageView.image!, queue: imageQueue, context: self.coreImageContext!)
        filteredThumbnail.generateThumbnail { (image) -> Void in
            self.photoImageView.image = image
        }
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return filterArray.count
    }
    
    func didTapOnPicture(image: UIImage) {
        self.photoImageView.image = image
        self.generateThumbnail()
        self.resetFilterThumbnails()
        self.collectionView.reloadData()
    }
    
    func generateThumbnail () {
        var size = CGSize(width: 100, height: 100)
        UIGraphicsBeginImageContext(size)
        self.photoImageView.image?.drawInRect(CGRect(x: 0, y: 0, width: 100, height: 100))
        self.originalThumbnail = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
    }
    
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
    
    func fetchFilters () {
        var fetchRequest = NSFetchRequest(entityName: "Filter")
        var appDelegate = UIApplication.sharedApplication().delegate as AppDelegate
        var context = appDelegate.managedObjectContext
        var error: NSError?
        var fetchResults = context?.executeFetchRequest(fetchRequest, error: &error)
        if let filters = fetchResults as? [Filter] {
            self.filterArray = filters
        }
    }
    
    func resetFilterThumbnails () {
        var newFilters = [FilterThumbnail]()
        for var index = 0; index < self.filterArray.count; ++index {
            var filter = self.filterArray[index]
            var filterName = filter.name
            var thumbnail = FilterThumbnail(name: filterName, thumbnail: self.originalThumbnail!, queue: self.imageQueue, context: self.coreImageContext!)
            newFilters.append(thumbnail)
        }
        self.filterThumbnails = newFilters
        self.collectionView.reloadData()
    }
}